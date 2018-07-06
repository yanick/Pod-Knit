package Pod::Knit::Manual;
# ABSTRACT: manual for the Pod::Knit system 

=description 

I love L<Dist::Zilla> and I adore the doc-munging that L<Pod::Weaver> does.
I'm, however, scared of its L<Pod::Elemental> guts. Hence C<Pod::Knit>, which 
is also a system to transform POD, but does it using an XML representation
of the document.


=head2 Using Pod::Knit 

To use C<Pod::Knit>, you need a F<knit.yml>
configuration file. That file has two main sections: the C<plugins> section 
listing all the plugins that you want to use, and the optional C<stash> section holding 
any variable you may want to pass to the knitter.

E.g.,

    ---
    stash:
        author: Yanick Champoux <yanick@cpan.org>
    plugins:
        - Abstract
        - Attributes
        - Methods
        - NamedSections:
            sections:
                - synopsis
                - description
        - Version
        - Authors
        - Legal
        - Sort:
            order:
            - NAME
            - VERSION
            - SYNOPSIS
            - DESCRIPTION
            - ATTRIBUTES
            - METHODS
            - '*'
            - AUTHORS
            - AUTHOR
            - COPYRIGHT AND LICENSE


Note that the plugins will be applied to the POD in the order in 
which they appear in the configuration file.


Then in that directory, use the script F<podknit> to munge a POD or Perl
file.

    $ podknit lib/My/Module.pm 

Magic!

=head2 Using Pod::Knit with Dist::Zilla 

See L<Dist::Zilla::Plugin::PodKnit>.

=head2 Writing a Pod::Knit plugin 

The documentation of L<Pod::Knit::Plugin> should 
give you a good idea how to do that. Looking at 
already-existing plugins for inspiration is also 
recommended.





=cut
