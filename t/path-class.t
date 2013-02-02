use strict;
use warnings;

use Test::More 0.96;
use File::Temp 0.18;
use File::pushd qw/tempd/;
use Path::Tiny;
use Path::Class;    # exports file(), dir()

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

my $tf = File::Temp->new;
my $td = File::Temp->newdir;

my @cases = (
    # Path
    {
        label    => "coerce Path::Class::File to Path",
        absolute => 0,
        attr     => "a_path",
        input    => file("./foo"),
    },
    {
        label    => "coerce Path::Class::Dir to Path",
        absolute => 0,
        attr     => "a_path",
        input    => dir("./foo"),
    },
    # AbsPath
    {
        label    => "coerce Path::Class::File to AbsPath",
        absolute => 1,
        attr     => "a_path",
        input    => file("./foo"),
    },
    {
        label    => "coerce Path::Class::Dir to AbsPath",
        absolute => 1,
        attr     => "a_path",
        input    => dir("./foo"),
    },
    # File
    {
        label    => "coerce Path::Class::File to File",
        absolute => 0,
        attr     => "a_file",
        input    => file("$tf"),
    },
    # Dir
    {
        label    => "coerce Path::Class::Dir to Dir",
        absolute => 0,
        attr     => "a_dir",
        input    => dir("$td"),
    },
    # AbsFile
    {
        label    => "coerce Path::Class::File to AbsFile",
        absolute => 1,
        attr     => "a_file",
        input    => file("$tf"),
    },
    # AbsDir
    {
        label    => "coerce Path::Class::Dir to AbsDir",
        absolute => 1,
        attr     => "a_dir",
        input    => dir("$td"),
    },
);

for my $c (@cases) {
    subtest $c->{label} => sub {
        my $wd       = tempd;
        my $class    = $c->{absolute} ? "AbsFoo" : "Foo";
        my $attr     = $c->{attr};
        my $input    = $c->{input};
        my $expected = path( ref $input eq 'ARRAY' ? @$input : $input );
        $expected = $expected->absolute if $c->{absolute};

        my $obj = eval { $class->new( $attr => $input ); };
        is( $@, '', "object created without exception" );
        isa_ok( $obj->$attr, "Path::Tiny", $attr );
        is( $obj->$attr, $expected, "$attr set correctly" );
    };
}

done_testing;
# COPYRIGHT

