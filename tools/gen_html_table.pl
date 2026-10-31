#!/usr/bin/env perl

# Copyright (c) 2026 Thomas Frohwein
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

use FindBin;
use lib $FindBin::Bin;

use Getopt::Std;

use Transform qw( db2dsc dsc2table );

sub usage() {
	say "Usage:	$PROGRAM_NAME filename";
	say "		$PROGRAM_NAME -h filename";
	say "		$PROGRAM_NAME -s <regex> filename";
	exit 1;
}

sub firstidx( $string, @list ) {
	for ( my $i = 0; $i < scalar( @list ); $i++) {
		if ( $list[$i] eq $string ) {
			return $i;
		}
	}
	return -1;
}

# -h:		only print header
# -s <regex>:	only print rows where 'Game' column matches <regex>
getopts('hs:', \my %opts);	

usage unless scalar( @ARGV ) == 1;

my $in = $ARGV[0];	# filename

my $dsc = db2dsc( $in );
my $field_type = 'th';
my @table = dsc2table( $dsc );

my @column_order = (
			'Id',
			'Game',
			'Version',
			'Status',
			'Store',
			'Hints',
			'Genre',
			'Tags',
			'Dev',
			'Pub',
			'Engine',
			'Setup',
			'Runtime',
			'Year',
			'Updated',
			'Added',
			'IgdbId',
		);

my @col_idxs = map { firstidx( $_, @{ $table[0] } ) } @column_order;
my $game_col = firstidx( 'Game', @column_order );

unless ( $opts{h} or $opts{s} ) {
	say '<table>';
}

foreach my $row ( @table ) {
	my @ordered_row;

	# reorder array based on @column_order ( via @col_idxs )
	foreach my $i ( @col_idxs ) {
		push @ordered_row, $$row[$i];
	}

	if ( $opts{s} and ( $ordered_row[$game_col] !~ /$opts{s}/ or $field_type eq 'th' ) ) {
		$field_type = 'td';
		next;
	}

	say '<tr>';
	print "  <${field_type}>";
	print join( "</${field_type}>\n  <${field_type}>", @ordered_row );
	say "</${field_type}>";
	say '</tr>';

	$field_type = 'td';

	last if $opts{h};
}

unless ( $opts{h} or $opts{s} ) {
	say '</table>';
}
