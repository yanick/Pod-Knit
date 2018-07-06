package Pod::Knit::Plugin::Sort;
# ABSTRACT: Reorder sections

use 5.10.0;
use strict;
use warnings;

use List::AllUtils qw/ part /;

use Moose;

extends 'Pod::Knit::Plugin';
with 'Pod::Knit::DOM::WebQuery';

use experimental 'signatures', 'postderef';

has "order" => (
    isa => 'ArrayRef',
    is => 'ro',
    lazy => 1,
    default => sub {
        []
    },
);

sub munge( $self, $doc ) {

    my $sections = $doc->dom->find( 'head1' )->map(sub{ $_->parent });

    my $i = 0;
    my %index = map { $_ => $i++ } $self->order->@*;
    my $rest = $index{'*'} || $i;

    my @order = 
        map { $_ ? @$_ : () } 
        part { $index{ $_->find('head1')->text } // $rest } @$sections;

    for( @order ) {
        $_->detach;
        $doc->dom->append($_);
    }
}




1;
