#! /usr/bin/perl
# One-time pad encrypter/decrypter
#
# TODO: Add help
#
# Copyright 2012 Jed Barlow
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use Getopt::Long;

my $DEFAULT_KEY_SOURCE = '/dev/random';
my $block_size = 1024 * 4;
my $key_out = '';
my $xor_out = '';

GetOptions('keyout=s'    => \$key_out,
           'xorout=s'    => \$xor_out,
           'blocksize=n' => \$block_size);
my ($datf, $keyf) = @ARGV;

unless (defined $datf) {
    die "Expecting at least one file as an argument.\n";
}


my $f1, $f2;
open $f1, $datf or die "Cannot open $datf for reading.\n";
binmode $f1;

my $xor_p = STDOUT;
if ($xor_out) {
    open $xor_p, ">", $xor_out or die "Cannot open $xor_out for writing.\n";
}

unless ((defined $keyf) or $key_out) {
    $key_out = "$datf.key";

}
my $key_p;
if ($key_out) {
    open $key_p, ">", $key_out or die "Cannot open $key_out for writing.\n";
}

# One args => xor with the default key source
# Two args => xor the two files (or file and stdin if '-' is given)
if (defined $keyf) {
    if ($keyf eq '-') {
        $f2 = STDIN;
    }
    else {
        open $f2, $keyf or die "Cannot open $keyf for reading.\n";
    }
}
else {
    open $f2, $DEFAULT_KEY_SOURCE
        or die "Cannot open $DEFAULT_KEY_SOURCE for reading.\n";
}


my $x, $k;
while (my $len = read $f1, $x, $block_size) {
    unless (read $f2, $k, $len) {
        die "warning: key not long enough, stopping xor.\n";
    }
    if ($key_out) {print $key_p $k}
    print $xor_p ($x ^ $k);
}
