package Pod::Knit::Plugin::Authors;

use strict;
use warnings;

use Moose;

use Web::Query;

with 'Pod::Knit::Plugin';

has "authors" => (
    isa => 'ArrayRef',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        [];
    },
);

sub transform {
    my( $self, $doc ) = @_;

    my $section = wq( '<over-text>' );
    for ( @{ $self->authors } ) {
        $section->append(
            '<item-text>' . $_ . '</item-text>'
        );
    }

    $doc->section( 'authors' )->append(
        $section
    );
}




1;
