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

	my $js = '
	<style type="text/css">
		#LoginButton {
			
		}
		#glogin {
			margin-top:	10px;
			margin-left: auto;
			margin-right: auto;
			display: table;
		}
		.AltTextLogin {
			margin-top: 22px;
			color: #777;
			text-align:center;
			width: 100%;
			margin-bottom: 10px;
		}
	</style>
	<meta name="google-signin-client_id" content="'.$WebClientID.'">';

    ${ $Param{Data} } =~ s{(</head>)}{$js $1 }xms;
    


	if ($Param{TemplateFile} eq 'Login'){
		my $button =''.
		'<div class="Clear"></div>'.
		"<div class=\"AltTextLogin\">Alternative Login</br>".
			'<div id="glogin"></div>'.
		'</div>';
		${ $Param{Data} } =~ s{(</fieldset>)}{$button $1 }xms;
	} else {
		my $button =''
		.'<div class="Clear"></div>'
		."<div class=\"AltTextLogin\">Alternative Login</br>".
			'<div id="glogin"></div>'.
		'</div>';
		${ $Param{Data} } =~ s{(</div>\n\s*<div\sid="Reset">)}{$button $1}xms;
	}

	my $Action = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'Action' ) || "";

	if($Action eq "Logout"){
		$Kernel::OM->Get('Kernel::Output::HTML::Layout')->Block(
			Name => 'Logout',
			Data => {
			},
		);
	}
	
	my $Script = $LayoutObject->Output(
	    	 TemplateFile => 'OutputFilterGoogleLogin',
		     Data         => {
				 GoogleClientID => $WebClientID
			 },
    	);

    ${ $Param{Data} } .= $Script;
    	
}
1;
