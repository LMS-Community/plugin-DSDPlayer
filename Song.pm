package Slim::Player::Song;

use strict;

use Slim::Utils::Log;

my $log = logger('player.source');

sub handleSampleAndBitrate {
	my ($self, $transcoder) = @_;

	my $streamformat = $transcoder->{'streamformat'};

	# if transcoding from DSD in command pipeline set sample size to 24 bits etc.
	if ($transcoder->{'command'} =~ /\[dsdplay\]/ && !Slim::Music::Info::isLossy($streamformat)) {
		main::INFOLOG && $log->is_info && $log->info("This is likely DSF/DFF - fix sample size");

		return {
			sampleRate => $transcoder->{samplerateLimit},
			sampleSize => 24,
		};
	}

	return;
}

1;