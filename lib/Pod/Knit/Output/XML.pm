package Pod::Knit::Output::XML;

use strict;
use warnings;

use Moose::Role;

sub as_xml {
    $_[0]->document->as_html;
}

1;



