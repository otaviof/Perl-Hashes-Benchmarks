#!/usr/bin/env perl

#
#  Author: Otavio Fernandes <otavio.fernandes@locaweb.com.br>
# Created: 09/22/2009 17:03:04
#

use strict;
use warnings;

use Benchmark qw( timediff timestr );
use Data::Dumper;

# ---------------------------------------------------------------------------
#                             -- Subroutines --
# ---------------------------------------------------------------------------

sub shard {
    my ($str) = @_;
    my (@a) = split( //, $str );
    return [
        ( ( $a[0] ) ? $a[0] : 0 ) . ( ( $a[1] ) ? $a[1] : 0 ),
        ( ( $a[2] ) ? $a[2] : 0 ) . ( ( $a[3] ) ? $a[3] : 0 ),
        ( ( $a[4] ) ? $a[4] : 0 ) . ( ( $a[5] ) ? $a[5] : 0 )
    ];
}

# ---------------------------------------------------------------------------
#                                -- Main --
# ---------------------------------------------------------------------------

$|++;

my %hash;
my @srch;
my $cntr      = 1;
my $use_shard = 1;

# --
# Creating an big hash
# --

my $hops = 1000000;

foreach my $h ( 1 .. $hops ) {
    my $r = int( rand( 10**10 ) );

    push @srch, $r
        if ( ( $h % ( 5**2 ) == 0 ) && ( $h <= 40000 ) );

    my ( $p1, $p2, $p3 ) = ( @{ shard($r) } );

    if ($use_shard) {
        $hash{$p1}->{$p2}->{$p3}->{$r} = 1;
    } else {
        $hash{$r} = 1;
    }
}

print scalar %hash, "\n";

if ($use_shard) {
    foreach my $k ( keys %hash ) {
        print scalar %{ $hash{$k} }, "\n";
        foreach my $j ( keys %{ $hash{$k} } ) {
            print scalar %{ $hash{$k}->{$j} }, "\n";
        }
    }
}

# --
# Searching some values inside the big hash
# --

my $t0 = new Benchmark;

foreach my $v (@srch) {
    my ( $p1, $p2, $p3 ) = ( @{ shard($v) } );

    if ($use_shard) {
        $cntr++
            if ( $hash{$p1}->{$p2}->{$p3}->{$v} );
    } else {
        $cntr++
            if ( $hash{$v} );
    }
}

my $t1 = new Benchmark;

# --
# Showing the results
# --

my $td = timediff( $t1, $t0 );

print( ( ($use_shard) ? "" : "NOT " ), "using shard", "\n" );
print "counter: ", $cntr, "\n";
print "timestr: ", timestr($td), "\n";

__END__

Sem sharding:
    timestr:  1 wallclock secs ( 1.30 usr +  0.07 sys =  1.37 CPU)
    timestr:  0 wallclock secs ( 0.12 usr +  0.01 sys =  0.13 CPU)
    timestr:  0 wallclock secs ( 0.12 usr +  0.00 sys =  0.12 CPU)
    timestr:  0 wallclock secs ( 0.11 usr +  0.00 sys =  0.11 CPU)
    timestr:  0 wallclock secs ( 0.11 usr +  0.00 sys =  0.11 CPU)
    timestr:  0 wallclock secs ( 0.11 usr +  0.00 sys =  0.11 CPU)

