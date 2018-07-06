package Pod::Knit::Plugin::Legal;

use strict;
use warnings;

use Moose;

extends 'Pod::Knit::Plugin';
with 'Pod::Knit::DOM::WebQuery';

use experimental 'signatures';

has license => (
    is => 'ro',
);

sub munge ($self,$doc) {

    my $license = $self->license or return;

    $self->find_or_create_section( 'COPYRIGHT AND LICENSE', 1, undef,
        'para' => $license->notice,
        'para' => [
            '"' => 'Full text of the license can be found in the ',
            'f' => 'LICENSE',
            '"' => ' file included in this distribution.'
        ]
    );
} 

1;
