package Pod::Knit::Plugin::Abstract;

use strict;
use warnings;

use Moose;

use Web::Query;

with 'Pod::Knit::Plugin';

sub transform {
    my( $self, $doc ) = @_;

    my( $package, $abstract ) = 
        $self->source_code =~ /^\s*package\s+(\S+);\s*^\s*#\s*ABSTRACT:\s*(.*?)\s*$/m
            or return;

    $doc->section( 'name' )->append( 
        '<para>'.
        join( ' - ', $package, $abstract )
        .'</para>'
    );
}




1;
