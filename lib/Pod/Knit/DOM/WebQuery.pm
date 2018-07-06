package Pod::Knit::DOM::WebQuery;

use Moose::Util qw/ apply_all_roles /;

use HTML::TreeBuilder::LibXML;

use Moose::Role;

use experimental qw/
    signatures
    postderef
/;

requires 'munge';

around munge => sub($orig, $self,$doc) {
    apply_all_roles( $doc, 'Pod::Knit::Document::WebQuery' );

    $orig->($self,$doc);

    $doc->xml_pod( $doc->dom->as_html );

    return $doc;
};

1;
