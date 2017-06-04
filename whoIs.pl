#!/usr/bin/perl -w

# Check each of the domain names in the given file and print out
# the available ones.
# @author Marcio Ribeiro (mribeiro (a) gmail com)
# @version $Id: whoIs.pl,v 1.5 2006/01/03 04:09:20 mmr Exp $
# @created 2006-01-01

use strict;
use POSIX ":sys_wait_h";

use constant MAX_KIDS => 20;

# Check if we got the filename, if not, bail out
if (@ARGV == 0) {
    die("Usage: $0 file\n");
}

# Set autoflush, so we can see output ASAP
$| = 1;

# Iterate over all domain names in the given file.
# Every domain name is checked by a forked child.
my $i = 0;
my %kids = ();
my $fileName = $ARGV[0];
open(FD, "<", $fileName);
foreach my $domain (<FD>) {
    chomp($domain);

    waitForKids(\%kids);

    if ($i > MAX_KIDS) {
        waitForKids(\%kids, 0);
        $i = 0;
    }

    my $kidPid = fork();
    if ($kidPid) {
        $kids{$kidPid} = 1;
    } elsif (!defined $kidPid) {
        waitForKids(\%kids, 0);
        redo;
    } elsif ($kidPid == 0) {
        # Inside kid fork
        if (isAvailable($domain)) {
            print "$domain is available!\n";
        }
        exit;
    }
    $i++;
}
close(FD);
waitForKids(\%kids, 0);

# Check if kids are done with the job they were doing and, if so, remove
# them from the hash.
# @param $kids hash with the pid of the kids.
# @param $flags Optionally, pass flags to waitpid, if undef, WNOHANG is used.
sub waitForKids {
    my ($kids, $flags) = @_;

    if (!defined $flags) {
        $flags = WNOHANG;
    }

    foreach my $kidPid (keys %{$kids}) {
        next if waitpid($kidPid, $flags) != -1;
        delete $kids->{$kidPid};
    }
}

# Check if the given domain is available in a whois service.
# @param $domain domain name to check.
# @return 1 if is available, 0 if not.
sub isAvailable {
    my ($domain) = @_;
    my $ret = `whois $domain`;
    return $ret =~ /^NOT FOUND$/;
}
