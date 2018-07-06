package Pod::Knit::Plugin::Version;

use strict;
use warnings;

use Moose;

extends 'Pod::Knit::Plugin';
with 'Pod::Knit::DOM::WebQuery';

use experimental 'signatures';

has "version" => (
    is => 'ro',
    lazy => 1,
    default => sub ($self) {
        $self->stash->{version};
    },
);

sub munge ($self,$doc) {
    no warnings 'uninitialized';

    $doc->find_or_create_section( 'VERSION', 1, undef, 
        'para' => 'version ' . ( $self->version // 'UNSPECIFIED' )
    );

} 

1;
