package Pod::Knit::Plugin::Abstract;

use strict;
use warnings;

use Log::Any '$log', prefix => 'Knit::Abstract: ';

use XML::Writer::Simpler;

use Moose;

extends 'Pod::Knit::Plugin'; 
with 'Pod::Knit::DOM::WebQuery';

use experimental qw/
    signatures
    postderef
/;

sub munge($self,$doc) {

    $log->debug( 'transforming' );

    my ( $package, $abstract );
    for ( $doc->content ) {
        no warnings 'uninitialized';
        ( $package )  = /^ \s* package \s+ (\S+);/mx;
        ( $abstract ) = /^ \s* \# \s* ABSTRACT: \s* (.*?) $/mx;
    }

    my $section = XML::Writer::Simpler->new( OUTPUT => 'self' );

    no warnings 'uninitialized';

    $section->tag( section => sub {
            $section->tag( 'section', [ class => 'name' ], sub {
                $section->tag( 'head1' => 'NAME' );
                $section->tag( 'para' => join ' - ', $package, $abstract );
            });
    });

    $doc->dom->append( $section->to_string );
}




1;
