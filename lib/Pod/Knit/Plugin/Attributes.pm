package Pod::Knit::Plugin::Attributes;
# ABSTRACT: POD structure for attributes

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
        attribute default
    /);

    $parser->commands->{attribute} = { alias => 'head3' };
    $parser->commands->{default} = { alias => 'head4' };
}

sub munge( $self, $doc ) {

    $doc->dom->find( 'section.attribute' )->each(sub{
        $_->detach;
        #$self->transform_attribute( $_, $doc );
        $self->attributes_section($doc)->append($_);
    });

}

sub attributes_section($self, $doc) {
    return $doc->find_or_create_section('attributes');
}

sub transform_attribute ($self,$doc) {
    $doc->dom->find( '.default' )->each(sub{
        $_->detach;
        $doc->dom->find('.')->filter('head3')->after($_);
    });
}

1;
