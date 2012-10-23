PNGS = $(patsubst %.svg, %.png, $(wildcard *.svg))
GIFS = $(patsubst %.svg, %.gif, $(wildcard *.svg))

%.png: %.svg
	inkscape -w 48 -h 48 -e $@ $<

%.gif : %.png
	convert $< $@

all: $(GIFS) $(PNGS)

clean:
	rm -f $(GIFS) $(PNGS)
