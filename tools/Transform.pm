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

package Transform;

use strict;
use warnings;
use v5.36;
use autodie;
use English;

use base qw( Exporter );
our @EXPORT_OK = qw( db2dsc dsc2table );

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

#
# db2dsc - convert the openbsd-games.db file format into Perl data structure
# $in: filename
#

sub db2dsc( $in ) {
	my $out;
	my $counter;

	open ( my $fh, '<', $in );
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
				my ( $key, $val ) = ( $1, $2 );
				# ISO8601 strings or empty
				if ( $val =~ /^[0-9]{4}$/ ) {
					# only year given, add January 1st
					$out->[ $counter ]{ $key } = $val . '-01-01' . $midnight;
				}
				elsif ( $val ) {
					$out->[ $counter ]{ $key } = $val . $midnight;
				}
				else {
					$out->[ $counter ]{ $key } = '';
				}

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
				}
				$out->[ $counter ]{ $1 } = $2;
			}
			elsif ( $hints{$1} == COMMAS ) {
				foreach ( split( /\,\s*/, $2 ) ) {
					push( @{ $out->[$counter]{$1} }, $_ );
				}
				# if nothing added, still create an empty list
				unless ( $out->[$counter]{$1} ) {
					$out->[$counter]{$1} = [];
				}
			}
			elsif ( $hints{$1} == SPECIAL ) {
				if ( $1 eq 'Store' ) {
					foreach ( split /\s+/, $2 ) {
						push( @{ $out->[$counter]{$1} }, $_ );
					}
					# if nothing added, still create an empty list
					unless ( $out->[$counter]{$1} ) {
						$out->[$counter]{$1} = [];
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

	return $out;
}

#
# data2cell - turn array or hash into string for table cell
#

sub data2cell( $data ) {
	my @out = ();
	my $r = ref( $data );

	if ( $r eq 'ARRAY' ) {
		@out = @$data;
	}
	elsif ( $r eq 'HASH' ) {
		my @new_out;
		for my $k ( keys %$data ) {
			next unless $$data{ $k };
			push @new_out, "$k: $$data{ $k }";
		}
		@new_out = sort @new_out;
		push @out, @new_out;
	}
	else {
		@out = ( scalar $data );
	}

	return join( ', ', @out );
}

#
# dsc2table - data structure to table conversion
# $dsc: reference to the data structure (hash or array base type)
# Creates 2-dimensional table in the form of an array of arrays
#

sub dsc2table ( $dsc ) {
	my $r0 = ref $dsc;
	my @rows;
	my @cols;	# this is returned as the first row

	if ( $r0 eq 'ARRAY' ) {
		my $r1 = ref $$dsc[0];
		if ( $r1 eq 'HASH' ) {
			# array of hashes
			@cols = sort ( keys %{ $$dsc[0] } );
			push @rows, [ @cols ];
			for my $d ( @$dsc ) {
				my @new_row;
				for my $col ( sort ( keys %$d ) ) {
					push @new_row, data2cell( $$d{ $col } );
				}
				push @rows, [ @new_row ];
			}
		}
		else {
			die "expected HASH, found: $r1 at $$dsc[0]";
		}
	}
	elsif ( $r0 eq 'HASH' ) {
		foreach ( keys %$dsc ) {
			# XXX: this won't work; where is flatten_recursive from?
			push @rows, ( $_, flatten_recursive ( $$dsc{ $_ } ) );
		}
	}
	else {
		die "incompatible data structure: $dsc -> $r0";
	}

	return @rows;
}

1;
