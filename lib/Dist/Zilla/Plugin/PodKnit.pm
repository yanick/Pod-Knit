package Dist::Zilla::Plugin::PodKnit;

use strict;
use warnings;

use Log::Any qw/ $log /, prefix => 'DZP::PK: ';
use Log::Any::Adapter 'Stderr';

use Moose::Util qw/ with_traits /;

use Moose;

with(
  'Dist::Zilla::Role::FileMunger',
  'Dist::Zilla::Role::FileFinderUser' => {
    default_finders => [ ':InstallModules', ':ExecFiles' ],
  },
);

has knit => (
    is   => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        my $knit = with_traits( 'Pod::Knit', 'Pod::Knit::Zilla' )->new(
            zilla => $self->zilla
        );

        $knit->stash->{$_} = $self->zilla->$_
            for qw/ version license authors distmeta /;

        return $knit;
    },
);



use experimental 'postderef';

sub munge_files {
  my ($self) = @_;

  $self->munge_file($_) for $self->found_files->@*;
}

sub munge_file {
  my ($self, $file) = @_;

  $self->log_debug([ 'knitting pod in %s', $file->name ]);

  $self->munge_pod($file);
}

sub munge_pod {
  my ($self, $file) = @_;

  $log->debugf( "munging '%s'", $file->name );

  my $doc = $self->knit->munge_document(
    path    => $file->name,
    content => $file->content,
  );

  # my $new_content = $self->munge_perl_string(
  #   $file->content,
  #   {
  #     zilla    => $self->zilla,
  #     filename => $file->name,
  #     version  => $self->zilla->version,
  #     license  => $self->zilla->license,
  #     authors  => $self->zilla->authors,
  #     distmeta => $self->zilla->distmeta,
  #   },
  # );

  $file->content( $doc->as_string );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
