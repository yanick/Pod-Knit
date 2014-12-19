package Pod::Knit::Plugin::Methods;

use strict;
use warnings;

use Moose;

with 'Pod::Knit::Plugin';

sub setup_parser {
    my( $self, $parser ) = @_;

    $parser->accept_directive_as_processed( 'method' );
}

sub preprocess {
    my( $self, $doc ) = @_;

    $doc->find( 'method' )->each(sub{
            $_->html(
                '<title>'. $_->html . '</title>'
            );
            my $done = 0;
            my $method = $_;
            $_->find( \'./following::*' )->each(sub{ 
                return if $done;
                my $tagname = $_->tagname;
                if ( not grep { $tagname eq $_ } qw/ para verbatimformatted /) {
                    return $done = 1;
                }
                $_->detach;
                $method->append($_);
            });
    });

}

sub transform {
    my( $self, $doc ) = @_;

    my $section = $doc->section( 'methods' );

    # die $doc->as_html;

    $doc->find( 'method' )->each(sub{
        $_->detach;
        $_->tagname( 'head2' );
        $section->append($_);
    });

}




1;
