# $Id: Makefile.PL,v 1.0 1998/01/16 06:30:12 Madsen Exp $

use ExtUtils::MakeMaker;

print 'Looking for MSDOS::Attrib...';
eval { require MSDOS::Attrib };
if ($@) {
    print "not found\a\n";
    if ($^O =~ /os2|win32/i) {
        print <<'';
	Although MSDOS::Descript will work without MSDOS::Attrib, any
	DESCRIPT.ION files that it alters will be visible, because I can't
	hide files without MSDOS::Attrib.  If you have a C compiler,
	I suggest you get MSDOS::Attrib from CPAN and install it.

    } else {
        print <<'';
        However, you don't seem to be running on an MS-DOS style operating
        system, so MSDOS::Attrib wouldn't work anyway.  Don't worry about
        this warning.  But, if you change any DESCRIPT.ION files on an MS-DOS
        style system (via a network, for example) they won't be hidden.

    }
    print "\n"; #'}
} else { print "found version $MSDOS::Attrib::VERSION\n" }

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'MSDOS::Descript',
    'PREREQ_PM' => { 'Tie::CPHash' => 1.0 },
    'VERSION_FROM' => 'Descript.pm', # finds $VERSION
    'dist'	=> {COMPRESS => 'gzip -9f', SUFFIX => 'gz', ZIPFLAGS => '-9r',
# This next line is just for my own use, you should comment it out:
                    PREOP => 'cjm_fixup $(DISTVNAME)' # Converts CRLF to LF
                   }
);

exit;

$MSDOS::Attrib::VERSION = $MSDOS::Attrib::VERSION; # Avoid 'one use' warning
