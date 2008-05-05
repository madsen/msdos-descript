#---------------------------------------------------------------------
# $Id$
package My_Build;
#
# Copyright 2007 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created: 18 Feb 2007
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# Customize Module::Build for MSDOS::Descript
#---------------------------------------------------------------------

use strict;
use File::Spec ();
use Module::Build ();

# Use Module::Build::DistVersion if we can get it:
BEGIN {
  eval q{ use base 'Module::Build::DistVersion'; };
  eval q{ use base 'Module::Build'; } if $@;
  die $@ if $@;
}

#=====================================================================
# Package Global Variables:

our $VERSION = '1.03';

#=====================================================================
sub ACTION_distdir
{
  my $self = shift @_;

  print STDERR <<"END" unless $self->isa('Module::Build::DistVersion');
\a\a\a\n
MSDOS::Descript uses Module::Build::DistVersion to automatically copy
version numbers to the appropriate places.  You might want to install
that and re-run Build.PL if you intend to create a distribution.
\n
END

  $self->SUPER::ACTION_distdir(@_);
} # end ACTION_distdir

#---------------------------------------------------------------------
# Explain what missing MSDOS::Attrib means:

sub prereq_failures
{
  my $self = shift @_;

  my $out = $self->SUPER::prereq_failures(@_);

  return $out unless $out;

  if (my $attrib = $out->{recommends}{'MSDOS::Attrib'}) {
    my $message;

    if ($^O =~ /os2|win32|cygwin/i) {
      $message = <<'';
   Although MSDOS::Descript will work without MSDOS::Attrib, any
   DESCRIPT.ION files that it alters will be visible, because I can't
   hide files without MSDOS::Attrib.  If you have a C compiler,
   I suggest you get MSDOS::Attrib from CPAN and install it.

    } else {
      $message = <<'';
   However, you don't seem to be running on an MS-DOS style operating
   system, so MSDOS::Attrib wouldn't work anyway.  Don't worry about
   this warning.  But, if you change any DESCRIPT.ION files on an MS-DOS
   style system (via a network, for example) they won't be hidden.

    }

    $attrib->{message} .= "\n\n$message";
  } # end if MSDOS::Attrib failed

  return $out;
} # end prereq_failures

#=====================================================================
# Package Return Value:

1;
