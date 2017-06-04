#!/usr/bin/perl -w -T

# Generate names, for Internet domain names, with configured chars, suffixes and
# size.
# @author Marcio Ribeiro (mribeiro (a) gmail com)
# @version $Id: nameGenerator.pl,v 1.4 2006/01/03 00:45:10 mmr Exp $
# @created 2006-01-01

use strict;

# Possible suffixes for generated domain names.
# Example: my @SUFS = ("org", "net", "com", "com.br");
my @SUFS  = ("org");#, "com", "net");

# Possible chars in domain names.
# OBS: you can try to do fancy things like using words to represent one number
# intead of one char, this way you can search for domains that with mixed
# words.
# Example: my @CHARS = ("=", "mmr", "b1n", "foo", "bar");
# IMPORTANT: do not change the first char, keep it the = char.
# If you want to know why you should keep the = char, read the comments below.
my @CHARS = ("=", "a".."z", 0..9, "_");

# Minimum of chars in the generated domain names.
my $MIN_SIZE = 3;

# Maximum of chars in the generated domain names.
my $MAX_SIZE = 3;

#=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-=_-
# Business Logic, you are not supposed to change the code below here.
my $BASE = @CHARS;
my $CALC_MIN_SIZE = $BASE ** ($MIN_SIZE - 1);
my $CALC_MAX_SIZE = ($BASE ** $MAX_SIZE) + 1;

# Iterate over the configured suffixes and characteres, printing all possible
# domain names.
#
# Observation about the implementation: As you probably guessed by now, we are
# using a "fake" numeric base to represent each of the generated domains as
# decimal numbers. This approach is quite tricky, because, despite being
# simple, it has some hidden side effects. Like the left zeroes. For example,
# how would the decimal number 0001 be represented in a fake base which 
# has just the chars abc? aaab? No! Just b. Because left zeroes are ignored.
# That is why we need the "=" char over there, to represent the 0.
foreach my $suf (@SUFS) {
    for (my $i = $CALC_MIN_SIZE; $i < $CALC_MAX_SIZE; $i++) {
        my $domain = toBase($i) . ".$suf";
        next if $domain =~ "=";
        print "$domain\n";
    }
}

# Converts a given decimal number to an arbitrary base, represented  by the
# configured chars above.
# @param $n Number in decimal to convert to arbitrary base.
# @return the string with the decimal number converted to the arbitrary base.
sub toBase {
    my $n = shift;
    my $r = $n % $BASE;
    if ($n - $r == 0) {
        return toChar($r);
    } else {
        return toBase(($n - $r) / $BASE) . toChar($r);
    }
}

# Get the equivalent char in the CHARS array, given an integer.
# @param $n Index for CHARS.
# @return the char from CHARS.
sub toChar {
    my $n = shift;
    return $CHARS[$n];
}
