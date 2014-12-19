package Pod::Knit::Plugin;

use strict;
use warnings;

use Pod::Knit::Doc;

use Moose::Role;

has "knit" => (
    isa => 'Pod::Knit',
    is => 'ro',
    required => 1,
    handles => {
        source_code => 'source_code',
    },
);


1;



