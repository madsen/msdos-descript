#---------------------------------------------------------------------
package MSDOS::Descript;
#
# Copyright 1997 Christopher J. Madsen
#
# Author: Christopher J. Madsen <ac608@yfn.ysu.edu>
# Created: 09 Nov 1997
# Version: $Revision: 0.2 $ ($Date: 1998/01/07 02:44:04 $)
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# Manage 4DOS DESCRIPT.ION files
#---------------------------------------------------------------------

require 5.000;
use Carp;
use MSDOS::Attrib 'set_attribs';
require Tie::CPHash;
use strict;
use vars qw(@ISA $VERSION);

@ISA = ();

#=====================================================================
# Package Global Variables:

BEGIN
{
    # Convert RCS revision number to d.ddd format:
    $VERSION = sprintf('%d.%03d', '$Revision: 0.2 $ ' =~ /(\d+)\.(\d+)/);
} # end BEGIN

#=====================================================================
# Methods:
#---------------------------------------------------------------------
# Constructor

sub new
{
    my $self = {};
    $self->{file} = $_[1] || '.';
    $self->{file} =~ s![/\\]?$!/DESCRIPT.ION! if -d $self->{file};
    tie %{$self->{desc}},'Tie::CPHash';
    bless $self, $_[0];
    $self->read;
    return $self;
} # end new

#---------------------------------------------------------------------
sub description
{
    my ($self, $file, $desc) = @_;

    $file =~ s/\.+$//;          # Trailing dots don't count in MS-DOS
    if (defined $desc) {
        my $old = $self->{desc}{$file};
        if ($desc eq '') {
            $self->{changed} = 1 if defined delete $self->{desc}{$file};
        } else {
            $self->{desc}{$file} = $desc;
            $self->{changed} = 1 if not defined $old or $old ne $desc;
        }
        return $old;
    }
    $self->{desc}{$file};
} # end description

#---------------------------------------------------------------------
sub rename
{
    my ($self, $old, $new) = @_;
    $old =~ s/\.+$//;           # Trailing dots don't count in MS-DOS
    $new =~ s/\.+$//;
    my $desc = delete $self->{desc}{$old};
    if (defined $desc) {
        $self->{desc}{$new} = $desc;
        $self->{changed} = 1;
    }
} # end rename

#---------------------------------------------------------------------
# Read the 4DOS description file:

sub read
{
    my ($self,$in) = @_;
    $in = $self->{file} unless $in;

    $self->{desc} = ();
    $self->read_add($in);

    delete $self->{changed} if $in eq $self->{file};
} # end read

#---------------------------------------------------------------------
# Add descriptions from a file to the current database:
#
# Input:
#   IN:  The name of the file to read

sub read_add
{
    my ($self,$in) = @_;

    if (-r $in) {
        open(DESCRIPT, $in) or croak "Unable to open $in";
        while (<DESCRIPT>) {
            m/^\"([^\"]+)\" (.+)$/ or m/^([^ ]+) (.+)$/ or die;
            $self->{desc}{$1} = $2;
        }
        close DESCRIPT;
    }

    $self->{changed} = 1;
} # end read_add

#---------------------------------------------------------------------
# Write the 4DOS description file:
#
# Sets the CHANGED flag to 0 if writing to our FILE.

sub write
{
    my ($self, $out) = @_;
    $out = $self->{file} unless $out;
    my ($file, $desc);

    unlink $out;
    if (keys %{$self->{desc}}) {
        open(DESCRIPT,">$out") or croak "Unable to open $out for writing";
        while (($file,$desc) = each %{$self->{desc}}) {
            next unless $desc;
            $file = '"' . $file . '"' if $file =~ /\s/;
            print DESCRIPT $file,' ',$desc,"\n";
        }
        close DESCRIPT;
        set_attribs('+h',$out);
    }
    $self->{changed} = 0 if $out eq $self->{file};
} # end write

#---------------------------------------------------------------------
# Save changes to descriptions:

sub update
{
    $_[0]->write if $_[0]->{changed};
} # end update

#=====================================================================
# Package Return Value:

1;

__END__

# Local Variables:
# tmtrack-file-task: "MSDOS::Descript.pm"
# End:
