package Pod::Knit::Plugin::Authors;

use strict;
use warnings;

use Web::Query;
use Moose;

extends 'Pod::Knit::Plugin';
with 'Pod::Knit::DOM::WebQuery';

use experimental 'signatures';

has "authors" => (
    traits => [ 'Array' ],
    isa => 'ArrayRef',
    is => 'ro',
    lazy => 1,
    handles => {
        all_authors => 'elements',
    },
    default => sub {
        my $self = shift;
        [];
    },
);

sub munge($self, $doc) {

    my @authors = $self->all_authors
        or return;

    my $title = 'AUTHORS';

    if ( @authors == 1 ) {
        chop $title;
        $doc->find_or_create_section(
            $title,
            1,
            $title,
            para => @authors
        );
    }
    else {
        $doc->dom->append(
            $self->xml_write( section => [
                head1 => $title,
                'over-text' => [
                    map { ('item-text' => $_) } @authors
                ]
            ])
        )
    }
} 

1;
