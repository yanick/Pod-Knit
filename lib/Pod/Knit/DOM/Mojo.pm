package Pod::Knit::DOM::Mojo;

use Moose::Util qw/ apply_all_roles /;

use Moose::Role;

use experimental qw/
    signatures
    postderef
/;

requires 'munge';

around munge => sub($orig, $self,$doc) {
    apply_all_roles( $doc, 'Pod::Knit::Document::Mojo' );

    $orig->($self,$doc);

    $doc->xml_pod( "" . ( $doc->dom ));

    return $doc;
};

1;
