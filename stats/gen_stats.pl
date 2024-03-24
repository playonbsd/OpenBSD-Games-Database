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

my %out;		# structure to convert to JSON

use constant {
	SKIP	=> 0,
	UNIQUE	=> 1,
	COUNT	=> 2,
	DATE	=> 3,
	COMMAS	=> 4,	# comma-separated
	SPECIAL	=> 5,	# needs specific processing
};

# hints to process the different fields
my %hints = (
	Game	=> UNIQUE,
	Cover	=> SKIP,
	Engine 	=> COUNT,
	Setup	=> COUNT,
	Runtime	=> SKIP,
	Store	=> SPECIAL,
	Hints	=> SKIP,
	Genre	=> COMMAS,
	Tags	=> COMMAS,
	Year	=> COUNT,
	Dev	=> SKIP,
	Pub	=> SKIP,
	Version	=> SKIP,
	Status	=> SPECIAL,
	Added	=> DATE,
	Updated	=> DATE,
	IgdbId	=> SKIP,
);

open ( my $fh, '<', $in );
while ( <$fh> ) {
	if ( /^([^\t]*)\t(.*)/ ) {
		if ( $hints{$1} == SKIP ) {
			next;
		}
		elsif ( $hints{$1} == UNIQUE ) {
			push( @{ $out{$1} }, $2 );
		}
		elsif ( $hints{$1} == COUNT ) {
			$out{$1}{$2}++;
		}
		elsif ( $hints{$1} == DATE ) {
			# XXX: what to do with dates?
			#      Array of datetime objects?
			# note Year only is 4 digits (e.g. '1970')
		}
		elsif ( $hints{$1} == COMMAS ) {
			# count entries of each element
			my @elements = split( /\,\s*/, $2 );
			foreach my $e ( @elements ) {
				$out{$1}{$e}++;
			}
		}
		elsif ( $hints{$1} == SPECIAL ) {
			if ( $1 eq 'Store' ) {
				# XXX: recognize store URLs, then count those
			}
			elsif ( $1 eq 'Status' ) {
				# XXX: count each status number; separately
				# also status dates
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

say encode_json \%out;
