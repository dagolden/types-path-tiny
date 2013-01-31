use 5.006;
use strict;
use warnings;
use Test::More 0.96;
use File::Temp;
use File::pushd qw/tempd/;
use Path::Tiny;

{
  package Foo;
  use Moose;
  use MooseX::Types::Path::Tiny qw/Path/;

  has temp_file => ( is => 'ro', isa => Path, coerce => 1 );
}

{
  package AbsFoo;
  use Moose;
  use MooseX::Types::Path::Tiny qw/AbsPath/;

  has temp_file => ( is => 'ro', isa => AbsPath, coerce => 1 );
}

my $tf = File::Temp->new;

subtest "coerce stringable objects" => sub {
  my $obj = eval {
    Foo->new(
      temp_file => $tf,
    )
  };

  is( $@, '', "object created without exception" );
  isa_ok( $obj->temp_file, "Path::Tiny", "temp_file" );
  is( $obj->temp_file, $tf, "temp_file set correctly" );
};

subtest "coerce strings" => sub {
  my $wd = tempd;
  my $obj = eval {
    Foo->new(
      temp_file => "./foo",
    )
  };
  is( $@, '', "object created using strings without exception" );
  isa_ok( $obj->temp_file, "Path::Tiny", "temp_file" );
  is( $obj->temp_file, path("./foo"), "temp_file set correctly" );
};

subtest "coerce arrayref" => sub {
  my $wd = tempd;
  my $obj = eval {
    Foo->new(
      temp_file => [qw/foo bar/]
    )
  };
  is( $@, '', "object created using arrayref without exception" );
  isa_ok( $obj->temp_file, "Path::Tiny", "temp_file" );
  is( $obj->temp_file, path(qw/foo bar/), "temp_file set correctly" );
};

subtest "coerce to absolute from strings" => sub {
  my $wd = tempd;
  my $obj = eval {
    AbsFoo->new(
      temp_file => "./foo",
    )
  };
  is( $@, '', "absolute path object created" );
  isa_ok( $obj->temp_file, "Path::Tiny", "temp_file" );
  is( $obj->temp_file, path("./foo")->absolute, "temp_file set correctly as absolute" );
};

subtest "coerce to absolute from arrayref" => sub {
  my $wd = tempd;
  my $obj = eval {
    AbsFoo->new(
      temp_file => [qw/foo bar/]
    )
  };
  is( $@, '', "object created using arrayref without exception" );
  isa_ok( $obj->temp_file, "Path::Tiny", "temp_file" );
  is( $obj->temp_file, path(qw/foo bar/)->absolute, "temp_file set correctly" );
};

subtest "coerce to absolute from stringables" => sub {
  my $obj = eval {
    AbsFoo->new(
      temp_file => $tf,
    )
  };
  is( $@, '', "absolute path object created" );
  isa_ok( $obj->temp_file, "Path::Tiny", "temp_file" );
  is( $obj->temp_file, $tf, "temp_file set correctly" );
};

subtest "coerce to absolute from Path::Tiny" => sub {
  my $wd = tempd;
  my $obj = eval {
    AbsFoo->new(
      temp_file => path("./foo"),
    )
  };
  is( $@, '', "absolute path object created" );
  isa_ok( $obj->temp_file, "Path::Tiny", "temp_file" );
  is( $obj->temp_file, path("./foo")->absolute, "temp_file set correctly as absolute" );
};

done_testing;
# COPYRIGHT
