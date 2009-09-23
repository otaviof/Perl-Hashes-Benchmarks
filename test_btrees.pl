#!/usr/bin/env perl

#
#  Author: Otavio Fernandes <otavio.fernandes@locaweb.com.br>
# Created: 09/23/2009 10:41:26
#

use strict;
use warnings;

use Benchmark qw( timediff timestr );

my $DEBUG = 0;
my ( $root, $n );
my (@srch);

# first generate 20 random inserts
foreach my $h ( 1 .. 1000000 ) {
    my $r = int( rand( 10**10 ) );
    insert( $root, $r );
    push @srch, $r
        if ( ( $h % ( 5**2 ) == 0 ) && ( $h <= 40000 ) );
}

# now dump out the tree all three ways
print "Pre order:  " if ($DEBUG);
pre_order($root);
print "\n"           if ($DEBUG);
print "In order:   " if ($DEBUG);
in_order($root);
print "\n"           if ($DEBUG);
print "Post order: " if ($DEBUG);
post_order($root);
print "\n" if ($DEBUG);

# prompt until EOF

=cut
for ( print "Search? "; <>; print "Search? " ) {
    chomp;
    my $found = search( $root, $_ );
    if   ($found) { print "Found $_ at $found, $found->{VALUE}\n" }
    else          { print "No $_ in tree\n" }
}
=cut

my $t0 = new Benchmark;

foreach my $v (@srch) {
    my $f = search( $root, $v );
    print "Found $v at $f, $f->{VALUE}\n" if ($f);
}

my $t1 = new Benchmark;

my $td = timediff( $t1, $t0 );

print "timestr: ", timestr($td), "\n";

exit;

#########################################

# insert given value into proper point of
# provided tree.  If no tree provided,
# use implicit pass by reference aspect of @_
# to fill one in for our caller.
sub insert {
    my ( $tree, $value ) = @_;
    unless ($tree) {
        $tree          = {};       # allocate new node
        $tree->{VALUE} = $value;
        $tree->{LEFT}  = undef;
        $tree->{RIGHT} = undef;
        $_[0]          = $tree;    # $_[0] is reference param!
        return;
    }

    if ( $tree->{VALUE} > $value ) {
        insert( $tree->{LEFT}, $value );
    } elsif ( $tree->{VALUE} < $value ) {
        insert( $tree->{RIGHT}, $value );
    } else {
        warn "dup insert of $value\n"
            if ($DEBUG);
    }

    # XXX: no dups
}

# recurse on left child,
# then show current value,
# then recurse on right child.
sub in_order {
    my ($tree) = @_;
    return unless $tree;
    in_order( $tree->{LEFT} );
    print $tree->{VALUE}, " " if ($DEBUG);
    in_order( $tree->{RIGHT} );
}

# show current value,
# then recurse on left child,
# then recurse on right child.
sub pre_order {
    my ($tree) = @_;
    return unless $tree;
    print $tree->{VALUE}, " " if ($DEBUG);
    pre_order( $tree->{LEFT} );
    pre_order( $tree->{RIGHT} );
}

# recurse on left child,
# then recurse on right child,
# then show current value.
sub post_order {
    my ($tree) = @_;
    return unless $tree;
    post_order( $tree->{LEFT} );
    post_order( $tree->{RIGHT} );
    print $tree->{VALUE}, " " if ($DEBUG);
}

# find out whether provided value is in the tree.
# if so, return the node at which the value was found.
# cut down search time by only looking in the correct
# branch, based on current value.
sub search {
    my ( $tree, $value ) = @_;
    return unless $tree;
    if ( $tree->{VALUE} == $value ) {
        return $tree;
    }
    search( $tree->{ ( $value < $tree->{VALUE} ) ? "LEFT" : "RIGHT" },
        $value );
}

__END__
