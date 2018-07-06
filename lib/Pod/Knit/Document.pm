package Pod::Knit::Document;

use strict;
use warnings;

use Log::Any '$log', prefix => 'PKnit::Doc: ';

use Web::Query::LibXML;
use Path::Tiny;

use List::Util qw/ reduce /;

use Pod::Knit;

use Moose;

with 'Pod::Knit::Output::Pod';

use experimental 'signatures';

=begin mapping

                       |   <Document>
    =headN Foo         |   <headN>
    =over ... =back    | <over-text>
    =item title        | <item-text>title</item-text>
    paragraph          |   <Para>
    verbatim        | <VerbatimFormatted>
    B<>, I<>, C<> | <B>, <I>, <C>
    L<> | <L>


All tags have the C<start_line> tag that indicates the first
line in the source file.

=end mapping

=cut

has knit => (
    is   => 'ro',
    predicate  => 'has_knit',
);

has plugins => (
    is => 'ro',
    lazy => 1, 
    traits => [ 'Array' ],
    default => sub {
        my $self = shift;
        $self->has_knit ? $self->knit->plugins : [];
    },
    handles => { all_plugins => 'elements' },
);

has file => (
    is => 'ro',
    predicate => 'has_file',
);

has content => (
    is => 'ro',
    lazy => 1,
    default => sub {
        $_[0]->has_file and path( $_[0]->file )->slurp;
    }
);

sub podparser {
    my $self = shift;
    
    use Pod::Knit::PodParser;
    my $parser = Pod::Knit::PodParser->new;
    $_->setup_podparser($parser) for grep { $_->can('setup_podparser') }
        $self->all_plugins;
    return $parser;
}

has xml_pod => (
    is => 'rw',
    lazy => 1,
    default => sub($self) {
        my $parser = $self->podparser;

        return $parser->parse($self->content)
            =~ s/(?<=<)(\w+)/\L$1/gr
            =~ s/(?<=<\/)(\w+)/\L$1/gr;
}
);


sub clone {
    my $self = shift;

    $self->new(
        plugins => [],
        map { $_ => $self-> $_ }  qw/ content xml_pod knit /
    );
}

sub _resolve_new {
    my( $class, $stuff, $options ) = @_;

    Web::Query->_resolve_new( $stuff, $options );
}

sub section {
    my( $self, $title, $level ) = @_;

    $level //= 1;

    my $section;

    $self->find( "head".$level )->each(sub{
        if( $_->find('title')->first->text =~ /^\s*\Q$title\E\s*$/i ) {
            $section = $_;
        }
    });

    return $section if $section;

    $section = Web::Query->new_from_html(
        "<head$level />"
    );
    $section->append( '<title>' . $title . '</title>' );

    $self->append($section);

    #die $self->as_html;

    # eeeurgh. Once appended, it's not the same node. 
    return $self->section(  $title, $level);
}

sub as_code ($self ) {
    return join "\n", grep { 
        not /^=/../^=cut/
    } split "\n", $self->content;
}

sub as_string ($self) {
    return join "\n\n__END__\n\n", $self->as_code, $self->as_pod;
}


use XML::Writer;
use XML::WriterX::Simple;

# util function
sub xml_write($self,@data) {
    my $writer = XML::Writer->new( OUTPUT => 'self' );
    $writer->produce(@data);
    $writer->to_string;
}

1;



