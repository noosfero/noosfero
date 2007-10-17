#!/bin/sh

# this script can be used when using svk, since svk does not support automatic
# checkout of svn's svn:externals. Then if you use svk, change to
# vendor/plugins directory and run this script with `sh update-externals.sh`

svk propget svn:externals . | awk '{ if ($1) print "if [ -e " $1 " ]; then svn update " $1 "; else svn co " $2 " " $1 "; fi"}' | sh
