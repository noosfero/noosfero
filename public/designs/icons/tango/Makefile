IMG_REGEXP = url(\([^)]*\)\.png)

GIFS = $(shell sed -e '/^[\.]/!d  ; /$(IMG_REGEXP)/!d; s/.*$(IMG_REGEXP).*/ie6\/\1.gif/' style.css)

ie6/%.gif: %.png
	mkdir -p $(shell dirname $@) && convert $< $@

all: ie6.css $(GIFS)

ie6.css: style.css
	sed -e '/^[\.]/!d; s/^/.msie6 /; s/$(IMG_REGEXP)/url(ie6\/\1.gif)/' $< > $@

ie6.mk: style.css
	(echo 'GIFS = \';  $<; echo '  firefox-24x24.gif') > $@
	echo 'include gif.mk' >> $@

clean:
	rm -f ie6.css ie6.mk
	rm -rf ie6
