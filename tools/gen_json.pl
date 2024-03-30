#!/usr/bin/env perl

# Copyright (c) 2024 Thomas Frohwein
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use strict;
use warnings;
use v5.36;
use autodie;
use English;
use JSON;

sub usage() {
	say "Usage:	$PROGRAM_NAME filename";
	exit 1;
}

usage unless scalar( @ARGV ) == 1;

my $in = $ARGV[0];	# filename
my $out;		# arrayref to convert to JSON output

my $midnight = 'T00:00:00.000Z';	# for ISO8601 dates

use constant {
	SKIP	=> 0,
	NUMERIC	=> 1,
	DATE	=> 2,
	STRING	=> 3,
	COMMAS	=> 4,	# comma-separated
	SPECIAL	=> 5,	# needs specific processing
};

# hints to process the different fields
my %hints = (
	Game	=> STRING,
	Cover	=> SKIP,
	Engine 	=> STRING,
	Setup	=> STRING,
	Runtime	=> STRING,
	Store	=> SPECIAL,
	Hints	=> STRING,
	Genre	=> COMMAS,	# XXX: or STRING? need more than 1?
	Tags	=> COMMAS,
	Year	=> DATE,
	Dev	=> STRING,
	Pub	=> STRING,
	Version	=> STRING,
	Status	=> SPECIAL,
	Added	=> DATE,
	Updated	=> DATE,
	IgdbId	=> NUMERIC,
);

my @statustext = (
	'doesn\'t launch',	# 0
	'launches',		# 1
	'major bugs',		# 2
	'intermediate bugs',	# 3
	'minor bugs',		# 4
	'completable',		# 5
	'everything works',	# 6
);

open ( my $fh, '<', $in );
my $counter;
while ( <$fh> ) {

	next if /^\s*#/;		# skip if line starts with '#'

	if ( /^([^\t\n]*)\t?(.*)/ ) {
		if ( $hints{$1} == SKIP ) {
			next;
		}
		elsif ( $hints{$1} == NUMERIC ) {
			$out->[ $counter ]{ $1 } = $2;
		}
		elsif ( $hints{$1} == DATE ) {
			# ISO8601 string
			$out->[ $counter ]{ $1 } = $2 . $midnight;
		}
		elsif ( $hints{$1} == STRING ) {
			if ( $1 eq "Game" ) {
				# new Game entry starts with this line
				if (defined $counter) {
					$counter++;
				}
				else {
					$counter = 0;
				}
				push( @{ $out }, {} );
				$out->[ $counter ]{ $1 } = $2;
			}
		}
		elsif ( $hints{$1} == COMMAS ) {
			foreach ( split( /\,\s*/, $2 ) ) {
				push( @{ $out->[$counter]{$1} }, $_ );
			}
		}
		elsif ( $hints{$1} == SPECIAL ) {
			if ( $1 eq 'Store' ) {
				foreach ( split /\s+/, $2 ) {
					push( @{ $out->[$counter]{$1} }, $_ );
				}
			}
			elsif ( $1 eq 'Status' ) {
				my $val = $2;

				if ( $val =~ s/^([0-9])// ) {
					my $statnum = $1;
					$out->[ $counter ]{ Status }{ StatusNumber } =
						$statnum;
					$out->[ $counter ]{ Status }{ StatusText } =
						$statustext[ $statnum ];
				}
				else {
					$out->[ $counter ]{ Status }{ StatusNumber } =
						'';
					$out->[ $counter ]{ Status }{ StatusText } =
						'';
				}

				if ( $val =~ s/\(?([0-9]{4}(\-[0-9]{2}){2})\)?// ) {
					$out->[ $counter ]{ Status }{ StatusDate } =
						$1 . $midnight;
				}
				else {
					$out->[ $counter ]{ Status }{ StatusDate } =
						'';
				}


				$val =~ s/^\s*//;
				$out->[ $counter ]{ Status }{ StatusComment } =
					$val;
			}
			else {
				die "unrecognized special entry: $_";
			}
		}
		else {
			die "unrecognized entry: $_";
		}
	}
}
close $fh;

# sort main array levels
@$out = sort { $a->{ Game } cmp $b->{ Game } } @$out;
foreach my $e ( @$out ) {
	foreach my $k ( keys %$e ) {
		if ( $hints{ $k } eq COMMAS ) {
			# sort COMMAS entries as arrays
			@{ $e->{ $k } } = sort @{ $e->{ $k } };
		}
	}
}

# set canonical so that JSON objects are ordered by keys
my $json = JSON->new->canonical;
say $json->encode( $out );
