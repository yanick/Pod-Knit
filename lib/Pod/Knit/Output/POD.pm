package Pod::Knit::Output::POD;

use strict;
use warnings;

use Moose::Role;

use XML::XSS;

sub as_pod {
    my $self = shift;
    
    my $xss = XML::XSS->new;

    $xss->set( 'document' => {
        pre => "=pod\n\n",
        post => "=cut\n\n",
    });

    $xss->set( "head$_" => {
        pre => "=head$_ ",
    }) for 1..4;

    $xss->set( 'title' => {
        pre => '',
        post => "\n\n",
    });

    $xss->set( 'verbatimformatted' => {
        pre => '',
        content => sub {
            my( $self, $node ) = @_;
            my $output = $self->render( $node->childNodes );
            $output =~ s/^/    /mgr;
        },
        post => "\n\n",
    });

    $xss->set( 'item-text' => {
        pre => "=item ",
        post => "\n\n",
    });

    $xss->set( 'over-text' => {
        pre => "=over\n\n",
    });

    $xss->set( '#text' => {
        filter => sub {
            s/^\s+|\s+$//mgr;
        }
    } );

    $xss->set( 'para' => {
        content => sub {
            my( $self, $node ) = @_;
            my $output = $self->render( $node->childNodes );
            $output =~ s/^\s+|\s+$//g;
            return $output . "\n\n";
        },
    } );

    $xss->render( $self->as_xml );

}

1;





