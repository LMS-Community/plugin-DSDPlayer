package Plugins::DSDPlayer::PlayerSettings;

use strict;

use base qw(Slim::Web::Settings);

use Slim::Utils::Prefs;
use Slim::Utils::Log;
use Slim::Player::CapabilitiesHelper;

use Plugins::DSDPlayer::Plugin;

my $prefs = preferences('plugin.playdsd');
my $log   = logger('plugin.playdsd');

sub getDisplayName {
    return 'PLUGIN_DSDPLAYER';
}

sub needsClient {
    return 1;
}

sub name {
    return Slim::Web::HTTP::CSRF->protectName('PLUGIN_DSDPLAYER');
}

sub page {
    return Slim::Web::HTTP::CSRF->protectURI('plugins/DSDPlayer/settings/player.html');
}

sub handler {
    my ($class, $client, $params, $callback, @args) = @_;
	
    if ($params->{'saveSettings'}) {

		$prefs->client($client)->set('usedop', $params->{'pref_usedop'} || 0);

		my $quality= $params->{'pref_quality'} || "";
		my $filter = $params->{'pref_filter'} || "";
		my $steep  = $params->{'pref_steep'} || "";
		my $flags  = $params->{'pref_flags'} || "";
		my $att    = $params->{'pref_att'} || "";
		my $precision = $params->{'pref_precision'} || "";
		my $end    = $params->{'pref_end'} || "";
		my $start  = $params->{'pref_start'} || "";
		my $phase  = $params->{'pref_phase'} || "";

		$prefs->client($client)->set('resample', "$quality$filter$steep:$flags:$att:$precision:$end:$start:$phase");

		$log->debug("usdop: " . $params->{'pref_usedop'});
		$log->debug("resample: $quality$filter$steep:$flags:$att:$precision:$end:$start:$phase");

		Plugins::DSDPlayer::Plugin::setupTranscoder($client);
    }
	
	my %formats = map { $_ => 1 } Slim::Player::CapabilitiesHelper::supportedFormats($client);
	
	$params->{'native'} = $formats{'dff'} && $formats{'dsf'} ? 1 : 0;
	$params->{'dsdplay'} = Slim::Utils::Misc::findbin('dsdplay') ? 1: 0;
	$params->{'dopavail'} = $client->maxSupportedSamplerate >= 176400 ? 1 : 0;

	$params->{'prefs'}->{'usedop'} = $prefs->client($client)->get('usedop');

	my $resample = $prefs->client($client)->get('resample');
	my ($recipe, $flags, $att, $precision, $end, $start, $phase) = split(":", $resample);

	my ($quality) = $recipe =~ /([vhmlq])/;
	my ($filter)  = $recipe =~ /([LIM])/;
	my ($steep)   = $recipe =~ /(s)/;

	$params->{'prefs'}->{'quality'}= $quality;
	$params->{'prefs'}->{'filter'} = $filter;
	$params->{'prefs'}->{'steep'}  = $steep;
	$params->{'prefs'}->{'flags'}  = $flags;
	$params->{'prefs'}->{'att'}    = $att;
	$params->{'prefs'}->{'precision'} = $precision;
	$params->{'prefs'}->{'end'}    = $end;
	$params->{'prefs'}->{'start'}  = $start;
	$params->{'prefs'}->{'phase'}  = $phase;
	
    return $class->SUPER::handler($client, $params);
}

1;
