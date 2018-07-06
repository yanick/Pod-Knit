package Pod::Knit::Plugin::Abstract;

use strict;
use warnings;

use Log::Any '$log', prefix => 'Knit::Abstract: ';

use Moose;

extends 'Pod::Knit::Plugin'; 
with 'Pod::Knit::DOM::Mojo';

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

    no warnings 'uninitialized';

    $doc->find_or_create_section( 'NAME', 1, undef, 
        para => join ' - ', grep { $_ } $package, $abstract 
    );

}




1;
