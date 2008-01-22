#!/bin/sh

ICON=$1
THEME=$2
SVG=$3

if [ -z $ICON ] || [ -z $THEME ] || [ -z $SVG ]; then
  echo "use: $0 <ICON> <THEME> <ICON>"
  echo "example:"
  echo "  $0 close Nuovo stock/gtk-close.svg"
  exit 1
fi

SECTION="$(dirname $SVG)/"
PNG=$(basename $SVG | sed -e 's/\.svg/\.png/')
SVGFILE=/usr/share/icons/$THEME/scalable/$SVG

if [ ! -f $SVGFILE ]; then
  echo "$SVGFILE not found, stopping."
  exit 2
fi

rsvg -h 24 -h 24 $SVGFILE $PNG

if [ ! -f $PNG ]; then
  echo "Error creating $PNG, stopping."
  exit 2
fi

svn add $PNG

LINE=$(printf "%-25s %-12s %s" $PNG $THEME $SECTION)
sed -i -e "s!### END OF ICONS LISTING ###!$LINE\n&!" README

echo ".icon-$ICON { background-image: url($PNG); }" >> style.css
