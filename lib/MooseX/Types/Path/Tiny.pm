use 5.008001;
use strict;
use warnings;

package MooseX::Types::Path::Tiny;
# ABSTRACT: Path::Tiny types and coercions for Moose
# VERSION

use Moose;
use MooseX::Types::Stringlike qw/Stringable/;
use Path::Tiny ();
use MooseX::Types::Moose qw/Str ArrayRef/;
use MooseX::Types -declare => [qw( Path AbsPath File AbsFile Dir AbsDir )];

subtype Path,    as 'Path::Tiny';
subtype File,    as Path, where { $_->is_file };
subtype Dir,     as Path, where { $_->is_dir };
subtype AbsPath, as Path, where { $_->is_absolute };
subtype AbsFile, as Path, where { $_->is_absolute && $_->is_file };
subtype AbsDir,  as Path, where { $_->is_absolute && $_->is_dir };

for my $type ( 'Path::Tiny', Path, File, Dir ) {
    coerce(
        $type,
        from Str()        => via { Path::Tiny::path($_) },
        from Stringable() => via { Path::Tiny::path($_) },
        from ArrayRef()   => via { Path::Tiny::path(@$_) },
    );
}

for my $type ( AbsPath, AbsFile, AbsDir ) {
    coerce(
        $type,
        from Str()        => via { Path::Tiny::path($_)->absolute },
        from Stringable() => via { Path::Tiny::path($_)->absolute },
        from ArrayRef()   => via { Path::Tiny::path(@$_)->absolute },
    );
}

### optionally add Getopt option type (adapted from MooseX::Types:Path::Class
##eval { require MooseX::Getopt; };
##if ( !$@ ) {
##    MooseX::Getopt::OptionTypeMap->add_option_type_to_map( $_, '=s', )
##      for ( 'Path::Tiny', Path );
##}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  ### specification of type constraint with coercion

  package Foo;

  use Moose;
  use MooseX::Types::Path::Tiny qw/Path AbsPath/;

  has filename => (
    is => 'ro',
    isa => Path,
    coerce => 1,
  );

  has directory => (
    is => 'ro',
    isa => AbsPath,
    coerce => 1,
  );

  ### usage in code

  Foo->new( filename => 'foo.txt' ); # coerced to Path::Tiny
  Foo->new( directory => '.' ); # coerced to path('.')->absolute

=head1 DESCRIPTION

This module provides L<Path::Tiny> types for Moose.  It handles
two important types of coercion:

=for :list
* coercing objects with overloaded stringification
* coercing to absolute paths

=head1 SUBTYPES

This module uses L<MooseX::Types> to define the following subtypes.

=head2 Path

C<Path> ensures an attribute is a L<Path::Tiny> object.  Strings and
objects with overloaded stringification may be coerced.

=head2 AbsPath

C<AbsPath> is a subtype of C<Path> (above), but coerces to an absolute path.

=head1 CAVEATS

=head2 Usage with File::Temp

Be careful if you pass in a File::Temp object. Because the argument is
stringified during coercion into a Path::Tiny object, no reference to the
original File::Temp argument is held.  Be sure to hold an external reference to
it to avoid immediate cleanup of the temporary file or diretory at the end of
the enclosing scope.

A better approach is to use Path::Tiny's own C<tempfile> or C<tempdir>
constructors, which hold the reference for you.

    Foo->new( filename => Path::Tiny->tempfile );

=head1 SEE ALSO

=for :list
* L<Path::Tiny>
* L<Moose::Manual::Types>

=cut

# vim: ts=4 sts=4 sw=4 et:
