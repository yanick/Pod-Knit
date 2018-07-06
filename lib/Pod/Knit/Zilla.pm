package Pod::Knit::Zilla;

use strict;
use warnings;

use Moose::Role;

has zilla => (
    is       => 'ro',
    required => 1,
);

1;
