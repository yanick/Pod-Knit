package Pod::Knit::Plugin::HeadsToSections;

use strict;
use warnings;

use Web::Query;
use List::AllUtils qw/ part /;

use Moose;

extends 'Pod::Knit::Plugin';
with 'Pod::Knit::DOM::WebQuery';

sub preprocess {
    my( $self, $doc ) = @_;

    for my $level ( reverse 1..4 ) {
        my( $in_section, $index ) = (0,0);
        my @sections;

        $doc->find( \'./*' )->each(sub{
            if( $_->tagname =~ /^head(\d+)/ ) {
                if( $1 == $level ) {
                    $index++;
                    $in_section = 1;
                }
                elsif( $1 < $level ) {
                    $in_section = 0;
                }
            }
            push @{$sections[ $in_section && $index]}, $_;
        });

        for my $i ( 1..$#sections ) {
            my $s = shift @{ $sections[$i] };
            $s->html(
                '<title>'. $s->html . '</title>'
            );
            while( my $e = shift @{ $sections[$i] } ) {
                $e->detach;
                $s->append($e);
            }
        }
    }

}

1;



