package Pod::Knit::Doc;

use strict;
use warnings;

use parent 'Web::Query';

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


1;



