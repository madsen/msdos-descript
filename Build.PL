#! /usr/bin/perl
#---------------------------------------------------------------------
# $Id$
# Copyright 2007 Christopher J. Madsen
#
# Build.PL for MSDOS-Descript
#---------------------------------------------------------------------

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin; # Make sure we're using My_Build from our distribution

use My_Build;          # Our customized version of Module::Build

my $builder = My_Build->new(
  module_name        => 'MSDOS::Descript',
  license            => 'perl',
  dist_author        => 'Christopher J. Madsen <perl@cjmweb.net>',
  dist_version_from  => 'lib/MSDOS/Descript.pm',
  requires => {
      'Tie::CPHash' => 1,
  },
  recommends => {
      'MSDOS::Attrib' => 1,
  },
  build_requires => {
      'Module::Build' => 0.1,
      'Test::More'    => 0,
  },
  create_makefile_pl => 'passthrough',
);

$builder->create_build_script();
