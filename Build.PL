#! /usr/bin/perl
#---------------------------------------------------------------------
# $Id$
# Copyright 2007 Christopher J. Madsen
#
# Build.PL for MSDOS-Descript
#---------------------------------------------------------------------

use strict;
use warnings;

# Make sure we're using My_Build from our distribution:
use FindBin;
use lib "$FindBin::Bin/tools";

use My_Build;          # Our customized version of Module::Build

my $builder = My_Build->new(
  module_name        => 'MSDOS::Descript',
  license            => 'perl',
  dist_author        => 'Christopher J. Madsen <perl@cjmweb.net>',
  requires => {
      'perl'        => '5.006',
      'Tie::CPHash' => 1,
  },
  recommends => {
      'MSDOS::Attrib' => 1,
  },
  build_requires => {
      'FindBin'       => 0,
      'Module::Build' => 0.21,
      'Test::More'    => 0,
  },
  create_makefile_pl => 'passthrough',
  dynamic_config     => 0,
  meta_merge         => { no_index  => { directory => [ 'tools' ] }},
);

$builder->create_build_script();
