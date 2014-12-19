package Pod::Knit::Plugin::Sort;

use strict;
use warnings;

use Moose;

with 'Pod::Knit::Plugin';

has "order" => (
    isa => 'ArrayRef',
    is => 'ro',
    lazy => 1,
    default => sub {
        []
    },
);

sub transform {
    my( $self, $doc ) = @_;

    my $i = 1;
    my %rank = map { uc($_) => $i++ } @{ $self->order };
    $rank{'*'} ||= $i;   # not given? all last

    my %sections;
    $doc->find('head1')->each(sub{
            $_->detach;

            my $title = uc $_->find('title')->first->text =~ s/^\s+|\s+$//gr;
            $sections{$title} = $_;
    });

    for my $s ( sort { ($rank{$a}||$rank{'*'}) <=> ($rank{$b}||$rank{'*'}) } keys %sections ) {
        $doc->append( $sections{$s} );
    }
}




1;
