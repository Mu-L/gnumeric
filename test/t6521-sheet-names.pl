#!/usr/bin/perl -w
# -----------------------------------------------------------------------------

use strict;
use lib ($0 =~ m|^(.*/)| ? $1 : ".");
use GnumericTest;

my $file = "$samples/sheet-names-tests.gnumeric";

if (&subtest ("gnumeric")) {
    &message ("Check sheet names gnumeric roundtrip.");
    &test_roundtrip ($file,
		     'format' => 'Gnumeric_XmlIO:sax',
		     'ext' => "gnm");
}

if (&subtest ("ods")) {
    &message ("Check sheet names ods roundtrip.");
    &test_roundtrip ($file,
		     'format' => 'Gnumeric_OpenCalc:odf',
		     'ext' => "ods",
		     'filter2' => 'std:drop_generator');
}

if (&subtest ("biff7")) {
    &message ("Check sheet names xls/BIFF7 roundtrip.");
    &test_roundtrip ($file,
		     'format' => 'Gnumeric_Excel:excel_biff7',
		     'ext' => "xls",
		     'resize' => '16384x256',
		     'filter2' => 'std:drop_codepage',
		     'ignore_failure' => 1);
}

if (&subtest ("biff8")) {
    &message ("Check sheet names xls/BIFF8 roundtrip.");
    &test_roundtrip ($file,
		     'format' => 'Gnumeric_Excel:excel_biff8',
		     'ext' => "xls",
		     'filter2' => 'std:drop_codepage',
		     'ignore_failure' => 1);
}

if (&subtest ("xlsx")) {
    &message ("Check sheet names xlsx roundtrip.");
    &test_roundtrip ($file,
		     'format' => 'Gnumeric_Excel:xlsx',
		     'ext' => "xlsx",
		     'resize' => '1048576x16384');
}