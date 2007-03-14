#---------------------------------------------------------------------
package MSDOS::Descript;
#
# Copyright 1997 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created: 09 Nov 1997
# $Id$
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
require Tie::CPHash;
use strict;
use vars qw($VERSION $hide_descriptions);

#=====================================================================
# Package Startup:

BEGIN
{
    $VERSION = '1.02';

    # Try to load MSDOS::Attrib, but keep going without it:
    eval { require MSDOS::Attrib };
    $hide_descriptions = 1 unless $@;
    MSDOS::Attrib->import('set_attribs') if $hide_descriptions;
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
# Destructor:

sub DESTROY
{
    $_[0]->update if $_[0]->{autoupdate};
} # end DESTROY

#---------------------------------------------------------------------
# Enable or disable automatic updates:

sub autoupdate
{
    $_[0]->{autoupdate} = (($#_ > 0) ? $_[1] : 1);
} # end autoupdate

#---------------------------------------------------------------------
# Return true if the descriptions have changed:

sub changed
{
  $_[0]->{changed};
} # end changed

#---------------------------------------------------------------------
# Read or update the description for a file:
#
# If DESC is the null string or undef, then delete FILE's description.

sub description
{
    my ($self, $file, $desc) = @_;

    $file =~ s/\.+$//;          # Trailing dots don't count in MS-DOS
    if ($#_ > 1) {
        my $old = $self->{desc}{$file};
        if (not defined($desc) or $desc eq '') {
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
# Transfer the description when a file is renamed:

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

    %{$self->{desc}} = ();
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
        set_attribs('+h',$out) if $hide_descriptions;
    }
    $self->{changed} = 0 if $out eq $self->{file};
} # end write

#---------------------------------------------------------------------
# Save changes to descriptions:

sub update
{
    $_[0]->write if $_[0]->changed;
} # end update

#=====================================================================
# Package Return Value:

1;

__END__

=head1 NAME

MSDOS::Descript - Manage 4DOS style DESCRIPT.ION files

=head1 SYNOPSIS

    use MSDOS::Descript;
    $d = new MSDOS::Descript;
    print $d->description('foo.txt');
    $d->rename('foo.txt', 'bar.txt');
    $d->description('baz.txt','This is Baz.txt');
    $d->description('frotz.txt', ''); # Remove description for frotz.txt
    $d->update;

=head1 DESCRIPTION

B<MSDOS::Descript> provides access to 4DOS style DESCRIPT.ION files.

Remember that changes to the descriptions are B<not> saved unless you
call the C<update> or C<write> methods.

By default, B<MSDOS::Descript> uses relative paths, so if you change
the current directory between C<new> and C<update>, you'll be writing
to a different file.  To avoid this, you can pass an absolute path to
C<new>.

=head2 Methods

=over 4

=item C<< $d = MSDOS::Descript->new([$filename]) >>

Constructs a new C<MSDOS::Descript> object.  C<$filename> may be a
directory or a 4DOS DESCRIPT.ION format file.  If it's a directory,
looks for a DESCRIPT.ION file in that directory.  If C<$filename> is
omitted, it defaults to the current directory.

=item C<< $d->description($file, [$desc]) >>

Gets or sets the description of C<$file>.  If C<$desc> is omitted,
returns the description of C<$file> or C<undef> if it doesn't have
one.  Otherwise, sets the description of C<$file> to C<$desc> and
returns the old description.  (If C<$desc> is the null string or
C<undef>, the description is deleted.)

=item C<< $d->rename($old, $new) >>

Transfers the description of C<$old> (if any) to C<$new>.  This does
not actually rename the file on disk.

=item C<< $d->read([$file]) >>

Load the descriptions from C<$file>.  If C<$file> is omitted, then
re-read the original description file.  Since C<new> does this
automatically, you shouldn't have to call C<read> yourself.

=item C<< $d->read_add($file) >>

Add the descriptions from C<$file> to the current descriptions.

=item C<< $d->write([$file]) >>

Writes the descriptions to C<$file>, or the original description file
if C<$file> is omitted.  Marks the descriptions as unchanged if
writing to the original description file.  If the current directory
has changed since the descriptions were loaded, and the description
file was specified by a relative path (which is the default), you will
be writing to a different file.

=item C<< $d->changed >>

Returns a true value if the descriptions have changed since being
loaded from the file.

=item C<< $d->update >>

Saves the descriptions to the original file if any changes have been
made.  The same warning about the current directory applies (see
C<write>).  Equivalent to C<< $d->write if $d->changed >>.

=item C<< $d->autoupdate([$auto]) >>

Turns on automatic updates for C<$d> if C<$auto> is true or omitted.
Otherwise, turns automatic updates off.

When automatic updates are on, the descriptions are automatically
saved when the object is destroyed.  B<Beware of relative paths!>  If
the current directory changes before the object is destroyed, you're
going to be writing to a different file!  I strongly suggest that you
use absolute paths if you're going to use C<autoupdate>.

=back

=head1 REQUIREMENTS

B<MSDOS::Descript> requires the B<Tie::CPHash> module (a
case-insensitive hash).

It also uses B<MSDOS::Attrib> to hide DESCRIPT.ION files after it
changes them.  If you don't have B<MSDOS::Attrib>, it will still work,
but any DESCRIPT.ION files changed by B<MSDOS::Descript> will become
visible.

Both L<Tie::CPHash> and L<MSDOS::Attrib> are available from CPAN.

=head1 BUGS

Uses relative paths, so changing the current directory after loading a
description file can cause problems.

=head1 AUTHOR

Christopher J. Madsen E<lt>F<perl@cjmweb.net>E<gt>

=cut

# Local Variables:
# tmtrack-file-task: "MSDOS::Descript.pm"
# End:
