#!/bin/sh

ICON=$1
THEME=$2
SVG=$3

if [ -z $ICON ] || [ -z $THEME ] || [ -z $SVG ]; then
  echo "use: $0 <ICON> <THEME> <SVG>"
  echo "example:"
  echo "  $0 favorites dlg-neu emblems/epiphany-bookmarks.svg"
  exit 1
fi

PNG=$(basename $SVG | sed -e 's/\.svg/\.png/')
SVGFILE=/usr/share/icons/$THEME/scalable/$SVG

if [ ! -f $SVGFILE ]; then
  echo "$SVGFILE not found, stopping."
  exit 2
fi

rsvg -w 64 -h 64 $SVGFILE $PNG

if [ ! -f $PNG ]; then
  echo "Error creating $PNG, stopping."
  exit 2
fi

ln -s $PNG ${ICON}.png

if [ -e .svn ]; then
  svn add $PNG ${ICON}.png
else
  git add $PNG ${ICON}.png
fi

LINE=$(printf "%-43s %s" $PNG $THEME)
sed -i -e "s!### END OF ICONS LISTING ###!$LINE\n&!" README
