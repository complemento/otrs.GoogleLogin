# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterGoogleLogin;

use Data::Dumper;

use strict;
use warnings;
use Kernel::System::Encode;
use Kernel::System::DB;
sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $WebClientID = $Kernel::OM->Get('Kernel::Config')->Get( 'GoogleLogin::WebClientID' ) || '';
	my $js = '<script src="https://apis.google.com/js/platform.js" async defer></script>
	<meta name="google-signin-client_id" content="'.$WebClientID.'">';

    ${ $Param{Data} } =~ s{(</head>)}{$js $1 }xms;
    
    my $button ='</button><div class="Clear"><br/</div><div class="g-signin2" data-onsuccess="onSignIn"></div>';

    ${ $Param{Data} } =~ s{(</button>)}{$button $1 }xms;    
	
	my $Script = $LayoutObject->Output(
	    	 TemplateFile => 'OutputFilterGoogleLogin',
		     Data         => {},
    	);

    ${ $Param{Data} } .= $Script;
    	
}
1;
