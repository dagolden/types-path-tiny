use 5.010;
use strict;
use warnings;
use Test::More 0.96;
use File::Temp 0.18;
use File::pushd qw/tempd/;
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

my $tf = File::Temp->new;
my $td = File::Temp->newdir;

my @cases = (
    {
        label    => "coerce string to path",
        absolute => 0,
        attr     => "a_path",
        input    => "./foo",
    },
    {
        label    => "coerce object to path",
        absolute => 0,
        attr     => "a_path",
        input    => $tf,
    },
    {
        label    => "coerce array ref to path",
        absolute => 0,
        attr     => "a_path",
        input    => [qw/foo bar/],
    },
    {
        label    => "coerce string to absolute path",
        absolute => 1,
        attr     => "a_path",
        input    => "./foo",
    },
    {
        label    => "coerce object to absolute path",
        absolute => 1,
        attr     => "a_path",
        input    => $tf,
    },
    {
        label    => "coerce array ref to absolute path",
        absolute => 1,
        attr     => "a_path",
        input    => [qw/foo bar/],
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
