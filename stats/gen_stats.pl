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

my $in =	$ARGV[0];	# filename

my $midnight = 'T00:00:00.000Z';	# for ISO8601 dates

my %out;		# structure to convert to JSON output

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

my @status = (
	'doesn\'t launch',		# 0
	'launches',		# 1
	'major bugs',		# 2
	'intermediate bugs',	# 3
	'minor bugs',		# 4
	'completable',		# 5
	'everything works',	# 6
);

open ( my $fh, '<', $in );
while ( <$fh> ) {
	next if /^\s*#/;		# skip if line starts with '#'
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
			my ( $year, $month, $day) = split( '-', $2 );
			next unless $year;
			# all entries as ISO8601 strings
			$out{$1}{ Year }{ $year . '-01-01' .
				$midnight }++;
			$out{$1}{ YearMonth }{ $year . '-' . $month . '-01' .
				$midnight }++;
			$out{$1}{ Date }{ $2 . $midnight }++;
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
				foreach my $link ( split ' ', $2 ) {
					# make itch.io links generic
					$link =~ s,[^/]*\.itch\.io,itch.io,;
					$link =~ s,^(([^/]*/){3}).*,$1,;
					$out{ Store }{$1}++;
				}
			}
			elsif ( $1 eq 'Status' ) {
				my $val = $2;
				if ( $val =~ /^([0-9])/ ) {
					$out{ Status }{ RatingNum }{ $1 }++;
					$out{ Status }{ Rating }{ $status[$1] }++;
				}
				if ( $val =~ /([0-9]{4}(\-[0-9]{2}){2})/ ) {
					$out{ Status }{ Date }{ $1 . $midnight }++;
				}
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

# set canonical so that JSON objects are ordered by keys
my $json = JSON->new->canonical;
say $json->encode( \%out );
