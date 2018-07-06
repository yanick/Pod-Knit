package Pod::Knit::Plugin;

use strict;
use warnings;

use Log::Any '$log';

use Moose;

use experimental qw/ signatures /;

sub munge { return $_[1] }

has knit => (
    isa => 'Pod::Knit',
    is => 'ro',
    handles => {
    },
);

has stash => (
    is => 'ro',
    lazy => 1,
    default => sub { {} },
);

0 and around transform => sub {
    my ( $orig, $self ) = @_;

    # $log->debugf( 'knit transform: %s', ref $self );
    # my $old;
    # if( $log->is_debug) {
    #     $old = $self->dom->as_html;
    # }

    my $return = $orig->($self);

    # if( $old ) {
    #     require XML::SemanticDiff;
    #     my $diff = XML::SemanticDiff->new;
    #     $log->debugf( "transformation: %s", { delta => [ $diff->compare( $old, $self->dom->as_html ) ] });
    # }

    return $return;
};



1;



