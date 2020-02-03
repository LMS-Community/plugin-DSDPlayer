package Plugins::DSDPlayer::Plugin;

use strict;

use base qw(Slim::Plugin::OPMLBased);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Player::TranscodingHelper;

use Plugins::DSDPlayer::PlayerSettings;

my $prefs = preferences('plugin.playdsd');

my $log = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.playdsd',
	'defaultLevel' => 'WARN',
	'description'  => 'PLUGIN_DSDPLAYER',
});

sub initPlugin {
	my $class = shift;

	Plugins::DSDPlayer::PlayerSettings->new;

	Slim::Control::Request::subscribe(\&initClientForDSD, [['client'],['new','reconnect']]);
}

sub setupTranscoder {
    my $client = $_[0] || return;

	my $usedop   = $prefs->client($client)->get('usedop');
	my $resample = $prefs->client($client)->get('resample') || "::::::";

	my $cmdTable    = "[dsdplay] -R $resample " . '$START$ $END$ $RESAMPLE$ $FILE$';
	my $cmdTableDoP = "[dsdplay] -R $resample -u " . '$START$ $END$ $RESAMPLE$ $FILE$';
	my $capabilities = { F => 'noArgs', T => 'START=-s %t', U => 'END=-e %v', D => 'RESAMPLE=-r %d' };

	my $dsf = 'dsf-flc-*-' . lc($client->macaddress);
	my $dff = 'dff-flc-*-' . lc($client->macaddress);

	if ($usedop) {

		$Slim::Player::TranscodingHelper::commandTable{ $dsf } = $cmdTableDoP;
		$Slim::Player::TranscodingHelper::capabilities{ $dsf } = $capabilities;
		$Slim::Player::TranscodingHelper::commandTable{ $dff } = $cmdTableDoP;
		$Slim::Player::TranscodingHelper::capabilities{ $dff } = $capabilities;

	} else {

		$Slim::Player::TranscodingHelper::commandTable{ $dsf } = $cmdTable;
		$Slim::Player::TranscodingHelper::capabilities{ $dsf } = $capabilities;
		$Slim::Player::TranscodingHelper::commandTable{ $dff } = $cmdTable;
		$Slim::Player::TranscodingHelper::capabilities{ $dff } = $capabilities;
	}
}

sub initClientForDSD {
    my $request = shift;
  
    setupTranscoder($request->client());
}

1;
