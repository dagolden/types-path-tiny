use 5.010;
use strict;
use warnings;
use Test::More 0.96;
use Test::Requires { "Test::Fatal" => 0 };
use Test::Requires { "Moose" => 2.0000 };
use Test::Fatal;

use Path::Tiny;

{

    package Foo;
    use Moose;
    use MooseX::Types::Path::Tiny qw/Path File Dir/;

    has a_path => ( is => 'ro', isa => Path, coerce => 1 );
    has a_file => ( is => 'ro', isa => File, coerce => 1 );
    has a_dir  => ( is => 'ro', isa => Dir,  coerce => 1 );
}

{

    package AbsFoo;
    use Moose;
    use MooseX::Types::Path::Tiny qw/AbsPath AbsFile AbsDir/;

    has a_path => ( is => 'ro', isa => AbsPath, coerce => 1 );
    has a_file => ( is => 'ro', isa => AbsFile, coerce => 1 );
    has a_dir  => ( is => 'ro', isa => AbsDir,  coerce => 1 );
}

my $err_re = qr/does not exist/;

like( exception { Foo->new( a_path => {} ) },
    qr{not isa Path::Tiny}, "Error on Path for {}" );

like( exception { Foo->new( a_file => "aalkdjalkdfs" ) },
    $err_re, "Error on File for nonexistent" );

like( exception { Foo->new( a_dir => "aalkdjalkdfs" ) },
    $err_re, "Error on Dir for nonexistent" );

like( exception { AbsFoo->new( a_path => {} ) },
    qr{not isa Path::Tiny}, "Error on Path for {}" );

like( exception { AbsFoo->new( a_file => "aalkdjalkdfs" ) },
    $err_re, "Error on File for nonexistent" );

like( exception { AbsFoo->new( a_dir => "aalkdjalkdfs" ) },
    $err_re, "Error on Dir for nonexistent" );

done_testing;
# COPYRIGHT
