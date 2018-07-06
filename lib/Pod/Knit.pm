package Pod::Knit;
# ABSTRACT: Stitches together POD documentation

=synopsis

    my $knit = Pod::Knit->new( config => {
        plugins => [
            'Abstract',
            'Version',
            { Sort => { order => [qw/ NAME * VERSION /] },
        ]
    });

    print $knit->munge_document( file => './lib/Pod/Knit.pm' )->as_string;


=description

C<Pod::Knit> is a POD processor heavily inspired by L<Pod::Weaver>. The main difference
being that C<Pod::Weaver> uses a L<Pod::Elemental> DOM to represent and transform
the POD document, whereas C<Pod::Knit> uses a XML representation and L<Web::Query>.

This module mostly take care of taking in the desired configuration, and
transform POD documents based on it.

=cut

use 5.20.0;
use warnings;

use Path::Tiny;
use YAML;

use List::Util qw/ reduce /;

use Pod::Knit::Document;

use Moose;

use experimental 'signatures', 'postderef';

=attribute config_file

Configuration file for the knit pipeline. Must be a YAML file.

=default F<./knit.yml> if the file exists.

=cut

has config_file => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {
        -f 'knit.yml' ? 'knit.yml' : undef;
    },
);

=attribute config

Hashref of the configuration for the knit pipeline. 

=default the content of the C<config_file>, if it exists.

=cut

has config => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        YAML::LoadFile($self->config_file);
    },
);

=attribute stash

Hashref of values accessible to the knit pipeline. 
Can be used to set values required by various plugins,
like the distribution's version, the list of authors, etc.

=default the C<stash> value of the config attribute, if presents. Else an
        empty hashref.

=cut

has stash => (
    is => 'ro',
    lazy => 1,
    default => sub {
        $_[0]->config->{stash} || {}
    },
);


has plugins => (
    traits => [ 'Array' ],
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my @plugins;
        if( my $plugins = $self->config->{plugins} ) {
            for my $p ( @$plugins ) {
                my( $plugin, $args ) = ref $p ? %$p : ( $p );

                $plugin = 'Pod::Knit::Plugin::' . $plugin;

                use Module::Runtime qw/ use_module /;
                use_module( $plugin );

                push @plugins, $plugin->new( 
                    stash => $self->stash,
                    %$args, knit => $self );
            }
        }

        \@plugins;
    },
    handles => {
        all_plugins => 'elements',
    },
);

sub munging_plugins ($self) {
    grep { $_->can( 'munge' ) } $self->all_plugins;
}

=method munge_document

=signature my $doc = $knit->munge_document( $original )

=signature my $doc = $knit->munge_document( %args )

Takes a L<Pod::Knit::Document> and returns a new document
munged by the plugins.

If the input is C<%args>, it is a shortcut for

    my $doc = $knit->munge_document( 
        Pod::Knit::Document->new( knit => $knit, %args )
    );

=cut

sub munge_document($self,@rest) {
    my( $doc ) = ( @rest == 1 ) ? @rest : ( Pod::Knit::Document->new( knit => $self, @rest ) );
    return reduce { $b->munge($a->clone) } $doc, $self->munging_plugins;
}

1;
