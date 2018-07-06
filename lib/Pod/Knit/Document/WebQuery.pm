package Pod::Knit::Document::WebQuery;     

use strict;
use warnings;

use Moose::Role;

use experimental qw/ signatures postderef /;

has dom => ( 
    is => 'ro',
    clearer => 'clear_dom',
    lazy => 1,
    default => sub ($self) {
        use DDP;
        my $x = $self->xml_pod;

        # https://github.com/tokuhirom/HTML-TreeBuilder-LibXML/pull/15
        HTML::TreeBuilder::LibXML::_parser->keep_blanks(1);
        Web::Query::LibXML->new_from_html(
            $x,
            { no_space_compacting => 1 },
        );
    },
);

sub find_or_create_section( $self, $name, $level = 1, $class = $name, @rest ) {

    $class //= $name;

    my $section = $self->dom->find( join '.', 'section', $name );

    return $section if $section->size;

    $self->dom->append(
        $self->xml_write( section => [
            ':class'        => lc($class),
            'head' . $level => $name,
            @rest,
        ])
    );

    return $self->dom->find( 'section.'. $name );
}

1;
