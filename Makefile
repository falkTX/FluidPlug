#!/usr/bin/make -f
# Makefile for FluidPlug #
# ---------------------- #
# Created by falkTX
#

include Makefile.mk

DESTDIR =
PREFIX  = /usr

# ---------------------------------------------------------------------------------------------------------------------

all: build

build: AirFont320 FluidGM

clean:
	rm -f *.lv2/*.so exporter

distclean: clean
	rm -f *.lv2/README
	rm -f *.lv2/*.sf2
	rm -f *.lv2/*.tar
	rm -f *.lv2/*.tar.7z

install:
	install -d $(DESTDIR)$(PREFIX)/lib/lv2/AirFont320.lv2
	install -d $(DESTDIR)$(PREFIX)/lib/lv2/FluidGM.lv2

	install -m 644 \
		AirFont320.lv2/*.sf2 \
		AirFont320.lv2/*.so \
		AirFont320.lv2/*.ttl \
		$(DESTDIR)$(PREFIX)/lib/lv2/AirFont320.lv2

	install -m 644 \
		FluidGM.lv2/*.sf2 \
		FluidGM.lv2/*.so \
		FluidGM.lv2/*.ttl \
		$(DESTDIR)$(PREFIX)/lib/lv2/FluidGM.lv2

	# recursive copy
	cp -r AirFont320.lv2/modgui $(DESTDIR)$(PREFIX)/lib/lv2/AirFont320.lv2
	cp -r FluidGM.lv2/modgui    $(DESTDIR)$(PREFIX)/lib/lv2/FluidGM.lv2

# ---------------------------------------------------------------------------------------------------------------------

AirFont320 = \
	AirFont320.lv2/FluidPlug.sf2 \
	AirFont320.lv2/FluidPlug.so \
	AirFont320.lv2/FluidPlug.ttl \
	AirFont320.lv2/manifest.ttl

FluidGM = \
	FluidGM.lv2/FluidPlug.sf2 \
	FluidGM.lv2/FluidPlug.so \
	FluidGM.lv2/FluidPlug.ttl \
	FluidGM.lv2/manifest.ttl

AirFont320: $(AirFont320)
FluidGM:    $(FluidGM)

download: \
	AirFont320.lv2/FluidPlug.sf2 \
	FluidGM.lv2/FluidPlug.sf2

# ---------------------------------------------------------------------------------------------------------------------

AirFont320.lv2/FluidPlug.sf2:
	(cd AirFont320.lv2 && \
		wget http://download.linuxaudio.org/musical-instrument-libraries/sf2/airfont_a340u.tar.7z && \
		7z x airfont_a340u.tar.7z && \
		7z x airfont_a340u.tar && \
		mv airfont_a340u/* . && \
		mv airfont_a320u.sf2 FluidPlug.sf2 && \
		mv readme README && \
		rmdir airfont_a340u)

FluidGM.lv2/FluidPlug.sf2:
	(cd FluidGM.lv2 && \
		wget http://download.linuxaudio.org/musical-instrument-libraries/sf2/fluidr3.tar.7z && \
		7z x fluidr3.tar.7z && \
		7z x fluidr3.tar && \
		mv fluidr3/* . && \
		mv fluidr3gm.sf2 FluidPlug.sf2 && \
		mv readme README && \
		rmdir fluidr3)

# ---------------------------------------------------------------------------------------------------------------------

%.lv2/FluidPlug.so: source/FluidPlug.c
	$(CC) $< -DFLUIDPLUG_LABEL=\"$*\" $(BUILD_C_FLAGS) $(FLUIDSYNTH_FLAGS) $(LINK_FLAGS) $(FLUIDSYNTH_LIBS) $(SHARED) -o $@

%.lv2/FluidPlug.ttl:
	sed "s/xLABELx/$*/" source/FluidPlug.ttl.p1 > $*.lv2/FluidPlug.ttl
	cd $*.lv2 && ../exporter >> FluidPlug.ttl
	sed "s/xLABELx/$*/" source/FluidPlug.ttl.p2 >> $*.lv2/FluidPlug.ttl

%.lv2/manifest.ttl:
	sed "s/xLABELx/$*/" source/manifest.ttl.in > $*.lv2/manifest.ttl

# ---------------------------------------------------------------------------------------------------------------------

exporter: source/Exporter.c
	$(CC) $< $(BUILD_C_FLAGS) $(FLUIDSYNTH_FLAGS) $(LINK_FLAGS) $(FLUIDSYNTH_LIBS) -o $@

# ---------------------------------------------------------------------------------------------------------------------
