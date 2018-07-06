package Pod::Knit::Document::Mojo;
# ABSTRACT: manipulate a Pod::Knit::Document using Mojo::DOM58

use strict;
use warnings;

use Mojo::DOM58;

use Moose::Role;

use MooseX::MungeHas { has_ro => [ 'is_ro' ] };

use experimental qw/ signatures /;

has_ro dom => sub ($self) {
    Mojo::DOM58->new( $self->xml_pod )
};

sub find_or_create_section( $self, $name, $level = 1, $class = $name, @rest ) {

    $class //= $name;

    my $section = $self->dom->find( join '.', 'section', $name );

    return $section if $section->size;

    $self->dom->find('document')->first->append_content(
        $self->xml_write( section => [
            ':class'        => lc($class),
            'head' . $level => $name,
            @rest,
        ])
    );

    return $self->dom->find( 'section.'. $name );
}

1;
