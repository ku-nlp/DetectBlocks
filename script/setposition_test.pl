#!/usr/bin/env perl

use strict;
use utf8;

use SetPosition;


#my $str = "../sample/htmls/Kyoto/001.html";
#my $str = "http://www.google.co.jp";
my $str = $ARGV[0];

if ($str eq "") {
    print "Please input URL or path of HTML file\n";
    exit();
}

my $execpath = '../tools/addMyAttrToHtml/staticExe/wkhtmltopdf-reed';
my $jspath = '../tools/addMyAttrToHtml/staticExe/myExecJs.js';

print &SetPosition::setPosition($str, $execpath, $jspath);




