use 5.008001;
use strict;
use warnings;

package MooseX::Types::Path::Tiny;
# ABSTRACT: Shim around Types::Path::Tiny for backwards compatibility
# VERSION

use Type::Library -base;
use Type::Utils qw(extends);

extends "Types::Path::Tiny";

1;

