package Pod::Knit::Output::Pod;

use strict;
use warnings;

use Text::Wrap;

use Moose::Role;

use XML::XSS;

has as_pod => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
    
    my $xss = XML::XSS->new;

    $xss->set( 'document' => {
        pre => "=pod\n\n=encoding UTF-8\n\n",
        post => "=cut\n\n",
    });

    $xss->set( 'section' => { pre => '', post => '' } );

    $xss->set( "head$_" => {
        pre => "=head$_ ",
        post => "\n\n",
    }) for 1..4;

    $xss->set( 'title' => {
        pre => '',
        post => "\n\n",
    });

    $xss->set( 'verbatim' => {
        pre => '',
        content => sub {
            my( $self, $node ) = @_;
            my $output = $self->render( $node->childNodes );
            $output =~ s/^/    /mgr;
        },
        post => "\n\n",
    });

    $xss->set( $_ => { pre => uc($_).'<', post => '>' } ) for qw/ b i c f/;

    $xss->set(  l => {
            pre => 'L<',
            post => '>',
            content => sub {
                my ( $self, $node, $args ) = @_;
                return $node->getAttribute('raw');
            },
    });

    $xss->set( 'item-text' => {
        pre => "=item ",
        post => "\n\n",
    });

    $xss->set( 'over-text' => {
        pre => "=over\n\n",
        post => "=back\n\n",
    });

    $xss->set( 'over-bullet' => {
        pre => "=over\n\n",
        post => "=back\n\n",
    });

    $xss->set( 'item-bullet' => {
        pre => "=item *\n\n",
        post => "\n\n",
    });

    $xss->set( '#text' => {
    } );

    $xss->set( 'para' => {
        content => sub {
            my( $self, $node ) = @_;
            my $output = $self->render( $node->childNodes );
            $output =~ s/^\s+|\s+$//g;
            return wrap( '', '', $output ) . "\n\n";
        },
    } );

    $xss->render( $self->xml_pod );

}
);

1;





