package Pod::Knit::Plugin::Methods;
# ABSTRACT: POD structure for methods

use strict;
use warnings;

use XML::WriterX::Simple;

use Moose;

extends 'Pod::Knit::Plugin';
with 'Pod::Knit::DOM::WebQuery';

use experimental 'signatures';

sub setup_podparser {
    my( $self, $parser ) = @_;

    $parser->accept_directive_as_processed(  qw/
        method signature
    /);

    $parser->commands->{method} = { alias => 'head3' };
    $parser->commands->{signature} = { alias => 'verbatim' };
}

sub methods_section($self,$doc) {
    return $doc->find_or_create_section('methods');
}

sub munge( $self, $doc ) {

    $doc->dom->find( 'section.method' )->each(sub{
        $self->transform_method($_);
        $_->detach;
        $self->methods_section($doc)->append($_);
    });

}

sub transform_method ($self,$section) {
    $section->find( 'verbatim.signature' )->each(sub{
        $_->detach;
        $section->find('head3')->after($_);
    });
}


1;
