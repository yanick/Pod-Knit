package Pod::Knit;

use 5.20.0;

use warnings;

use Pod::Simple::DumpAsXML;
use Path::Tiny;
use Web::Query;
use YAML;
use Class::Load qw/ load_class /;

use Moose;

use experimental 'signatures';

with 'Pod::Knit::Output::POD';
with 'Pod::Knit::Output::XML';

has "config_file" => (
    isa => 'Str',
    is => 'ro',
);

has "config" => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        YAML::LoadFile($self->config_file);
    },
);

has "source_file" => (
    isa => 'Str',
    is => 'ro',
);

has "source_code" => (
    is => 'ro',
    lazy => 1,
    default => sub($self) {
        path( $self->source_file )->slurp;
    },
);

has "_plugins" => (
    traits => [ 'Array' ],
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        load_class( 'Pod::Knit::Plugin::HeadsToSections' );

        my @plugins = (
            Pod::Knit::Plugin::HeadsToSections->new(
                knit => $self
            )
        );

        if( my $plugins = $self->config->{plugins} ) {
            for my $p ( @$plugins ) {
                my( $plugin, $args ) = ref $p ? %$p : ( $p );

                $plugin = 'Pod::Knit::Plugin::' . $plugin;

                load_class( $plugin );

                push @plugins, $plugin->new( %$args, knit => $self );
            }
        }

        \@plugins;
    },
    handles => {
        plugins => 'elements',
    },
);

has "parser" => (
    is => 'ro',
    lazy => 1,
    default => sub {
        Pod::Simple::DumpAsXML->new;
    },
);

has "document" => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $parser = $self->parser;
        $parser->output_string( \my $xml );

        for my $plugin ( $self->plugins ) {
            next unless $plugin->can( 'setup_parser' );
            $plugin->setup_parser( $parser );
        }

        $parser->parse_string_document( $self->source_code );

        my $doc = Pod::Knit::Doc->new_from_html($xml, { no_space_compacting
            => 1 });

        $doc = bless $doc, 'Pod::Knit::Doc';

        for my $plugin ( $self->plugins ) {
            next unless $plugin->can( 'preprocess' );
            $plugin->preprocess( $doc );
        }

        for my $plugin ( $self->plugins ) {
            next unless $plugin->can( 'transform' );
            $plugin->transform( $doc );
        }

        $doc;
    },
);


1;
