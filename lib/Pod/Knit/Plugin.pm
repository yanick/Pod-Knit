package Pod::Knit::Plugin;
# ABSTRACT: base class for Pod::Knit transforming modules

=synopsis

    use Pod::Knit::Document;
    use Pod::Knit::Plugin;

    my $doc = Pod::Knit::Document->new( file => 'Foo.pm' );

    my $new_doc = Pod::Knit::Plugin->new()->munge($doc);

=description

C<Pod::Knit::Plugin> is the base class for the transforming
modules of the L<Pod::Knit> system. 

A plugin should override the C<munge> method, and may implement a 
C<setup_podparser> method that is invoked when the C<podparser> of
a C<Pod::Knit::Document> is created. For example, if a plugin is
to introduce two new tags, C<method> and C<signature>, it should have

    sub setup_podparser ( $self, $parser ) {

        $parser->accept_directive_as_processed( qw/
            method signature
        /);

        $parser->commands->{method}    = { alias => 'head3' };
        $parser->commands->{signature} = { alias => 'verbatim' };
    }


Because munging XML with regular expressions and the like is no 
fun, you most probably want your plugins to consume either one 
of the L<Pod::Knit::DOM::WebQuery> or L<Pod::Knit::DOM::Mojo>
roles, which augment the doc passed to the plugin with 
yummilicious DOM manipulating methods.

=cut

use strict;
use warnings;

use Log::Any '$log';

use Moose;

use experimental qw/ signatures /;

=method munge

=signature $new_doc = $self->munge( $doc )

Takes in a L<Pod::Knit::Document>, and returns a new one.

For the base C<Pod::Knit::Plugin> class, the method is a pass-through
that returns the exact same document.

=cut

sub munge { return $_[1] }

=attribute knit

Orchestrating L<Pod::Knit> object. Optional.

=cut

has knit => (
    isa => 'Pod::Knit',
    is => 'ro',
    handles => {
    },
);

=attribute stash 

Hashref of variables typically passed by the C<knit> object.

=cut

has stash => (
    is => 'ro',
    lazy => 1,
    default => sub { {} },
);

1;



