# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Auth::Google;

use strict;
use warnings;

use GoogleIDToken::Validator;
use Data::Dumper;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::Encode',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Valid',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # Debug 0=off 1=on
    $Self->{Debug} = 0;

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get user table
    $Self->{WebClientID} = $ConfigObject->Get( 'GoogleLogin::WebClientID' ) || '';
    
    $Self->{TempFile} = $ConfigObject->Get( 'AuthModule::Google::TempFile' . $Param{Count} ) || '/tmp/google.crt';

    return $Self;
}

sub GetOption {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{What} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need What!"
        );
        return;
    }

    # module options
    my %Option = (
        PreAuth => 0,
    );

    # return option
    return $Option{ $Param{What} };
}

sub Auth {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{User} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need User!"
        );
        return;
    }

    if ($Self->{WebClientID} eq ''){
        $Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => "You need to specify Web Google Client ID");
        return;
    };

    # get params
    my $User       = $Param{User}      || '';
    my $Pw         = $Param{Pw}        || '';
    my $RemoteAddr = $ENV{REMOTE_ADDR} || 'Got no REMOTE_ADDR env!';

    my $validator = GoogleIDToken::Validator->new(
        #do_not_cache_certs => 1,                                       # will download google certificates from web every call of verify
        #google_certs_url       => 'https://some.domain.com/certs',     # in case they change URL in the future... default is: https://www.googleapis.com/oauth2/v1/certs
        certs_cache_file        => $Self->{TempFile},                   # will cache certs in this file for faster verify if you are using CGI
        web_client_id   => $Self->{WebClientID},   # Your Client ID for web applications received in Google APIs console
        app_client_ids  => [                                                            # Array of your Client ID for installed applications received in Google APIs console
            $Self->{WebClientID}, # for exm. your production keystore ID
        ]
    );
    
    # get the token from your mobile app somehow...
    my $token =  $Pw;

    my $payload = $validator->verify($token);
    if($payload) {
        ## token is OK, lets see what we have got
        my @List = $Kernel::OM->Get('Kernel::System::User')->UserSearch(
            PostMasterSearch => $payload->{email},
            Valid            => 1, # not required
        ) ;
        
        if ($List[0]){
            my %User = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                UserID => $List[0],
            );
            return $User{UserLogin};
        } else {
            $Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => "Google Authentication ok but user not found in this system");
        }
        
    }
     else {
        $Kernel::OM->Get('Kernel::System::Log')->Log(Priority => 'error',Message  => "Google Authentication Failed");
        return;
    }
    
    return;
}

1;
