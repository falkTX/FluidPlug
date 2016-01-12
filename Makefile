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

install-splitted:
	install -d $(DESTDIR)$(PREFIX)/lib/lv2/FluidBass.lv2

	install -m 644 \
		FluidBass.lv2/*.sf2 \
		FluidBass.lv2/*.so \
		FluidBass.lv2/*.ttl \
		$(DESTDIR)$(PREFIX)/lib/lv2/FluidBass.lv2

	cp -r FluidBass.lv2/modgui  $(DESTDIR)$(PREFIX)/lib/lv2/FluidBass.lv2

# ---------------------------------------------------------------------------------------------------------------------

build: \
	AirFont320 \
	FluidGM \
	FluidBass

AirFont320: \
	AirFont320.lv2/FluidPlug.sf2 \
	AirFont320.lv2/FluidPlug.so \
	AirFont320.lv2/FluidPlug.ttl \
	AirFont320.lv2/manifest.ttl

FluidGM: \
	FluidGM.lv2/FluidPlug.sf2 \
	FluidGM.lv2/FluidPlug.so \
	FluidGM.lv2/FluidPlug.ttl \
	FluidGM.lv2/manifest.ttl

FluidBass: \
	FluidBass.lv2/FluidPlug.sf2 \
	FluidBass.lv2/FluidPlug.so \
	FluidBass.lv2/FluidPlug.ttl \
	FluidBass.lv2/manifest.ttl

FluidBrass: \
	FluidBrass.lv2/FluidPlug.sf2 \
	FluidBrass.lv2/FluidPlug.so \
	FluidBrass.lv2/FluidPlug.ttl \
	FluidBrass.lv2/manifest.ttl

FluidChromPerc: \
	FluidChromPerc.lv2/FluidPlug.sf2 \
	FluidChromPerc.lv2/FluidPlug.so \
	FluidChromPerc.lv2/FluidPlug.ttl \
	FluidChromPerc.lv2/manifest.ttl

FluidDrums: \
	FluidDrums.lv2/FluidPlug.sf2 \
	FluidDrums.lv2/FluidPlug.so \
	FluidDrums.lv2/FluidPlug.ttl \
	FluidDrums.lv2/manifest.ttl

FluidEnsemble: \
	FluidEnsemble.lv2/FluidPlug.sf2 \
	FluidEnsemble.lv2/FluidPlug.so \
	FluidEnsemble.lv2/FluidPlug.ttl \
	FluidEnsemble.lv2/manifest.ttl

FluidEthnic: \
	FluidEthnic.lv2/FluidPlug.sf2 \
	FluidEthnic.lv2/FluidPlug.so \
	FluidEthnic.lv2/FluidPlug.ttl \
	FluidEthnic.lv2/manifest.ttl

FluidGuitars: \
	FluidGuitars.lv2/FluidPlug.sf2 \
	FluidGuitars.lv2/FluidPlug.so \
	FluidGuitars.lv2/FluidPlug.ttl \
	FluidGuitars.lv2/manifest.ttl

FluidOrgans: \
	FluidOrgans.lv2/FluidPlug.sf2 \
	FluidOrgans.lv2/FluidPlug.so \
	FluidOrgans.lv2/FluidPlug.ttl \
	FluidOrgans.lv2/manifest.ttl

FluidPercussion: \
	FluidPercussion.lv2/FluidPlug.sf2 \
	FluidPercussion.lv2/FluidPlug.so \
	FluidPercussion.lv2/FluidPlug.ttl \
	FluidPercussion.lv2/manifest.ttl

FluidPianos: \
	FluidPianos.lv2/FluidPlug.sf2 \
	FluidPianos.lv2/FluidPlug.so \
	FluidPianos.lv2/FluidPlug.ttl \
	FluidPianos.lv2/manifest.ttl

FluidPipes: \
	FluidPipes.lv2/FluidPlug.sf2 \
	FluidPipes.lv2/FluidPlug.so \
	FluidPipes.lv2/FluidPlug.ttl \
	FluidPipes.lv2/manifest.ttl

FluidReeds: \
	FluidReeds.lv2/FluidPlug.sf2 \
	FluidReeds.lv2/FluidPlug.so \
	FluidReeds.lv2/FluidPlug.ttl \
	FluidReeds.lv2/manifest.ttl

FluidSoundFX: \
	FluidSoundFX.lv2/FluidPlug.sf2 \
	FluidSoundFX.lv2/FluidPlug.so \
	FluidSoundFX.lv2/FluidPlug.ttl \
	FluidSoundFX.lv2/manifest.ttl

FluidStrings: \
	FluidStrings.lv2/FluidPlug.sf2 \
	FluidStrings.lv2/FluidPlug.so \
	FluidStrings.lv2/FluidPlug.ttl \
	FluidStrings.lv2/manifest.ttl

FluidSynthFX: \
	FluidSynthFX.lv2/FluidPlug.sf2 \
	FluidSynthFX.lv2/FluidPlug.so \
	FluidSynthFX.lv2/FluidPlug.ttl \
	FluidSynthFX.lv2/manifest.ttl

FluidSynthLeads: \
	FluidSynthLeads.lv2/FluidPlug.sf2 \
	FluidSynthLeads.lv2/FluidPlug.so \
	FluidSynthLeads.lv2/FluidPlug.ttl \
	FluidSynthLeads.lv2/manifest.ttl

FluidSynthPads: \
	FluidSynthPads.lv2/FluidPlug.sf2 \
	FluidSynthPads.lv2/FluidPlug.so \
	FluidSynthPads.lv2/FluidPlug.ttl \
	FluidSynthPads.lv2/manifest.ttl

# ---------------------------------------------------------------------------------------------------------------------

download: \
	AirFont320.lv2/FluidPlug.sf2 \
	FluidGM.lv2/FluidPlug.sf2 \
	FluidBass.lv2/FluidPlug.sf2 \
	FluidBrass.lv2/FluidPlug.sf2 \
	FluidChromPerc.lv2/FluidPlug.sf2 \
	FluidDrums.lv2/FluidPlug.sf2 \
	FluidEnsemble.lv2/FluidPlug.sf2 \
	FluidEthnic.lv2/FluidPlug.sf2 \
	FluidGuitars.lv2/FluidPlug.sf2 \
	FluidOrgans.lv2/FluidPlug.sf2 \
	FluidPercussion.lv2/FluidPlug.sf2 \
	FluidPianos.lv2/FluidPlug.sf2 \
	FluidPipes.lv2/FluidPlug.sf2 \
	FluidReeds.lv2/FluidPlug.sf2 \
	FluidSoundFX.lv2/FluidPlug.sf2 \
	FluidStrings.lv2/FluidPlug.sf2 \
	FluidSynthFX.lv2/FluidPlug.sf2 \
	FluidSynthLeads.lv2/FluidPlug.sf2 \
	FluidSynthPads.lv2/FluidPlug.sf2

# ---------------------------------------------------------------------------------------------------------------------

AirFont320.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd AirFont320.lv2 && \
		wget http://download.linuxaudio.org/musical-instrument-libraries/sf2/airfont_a340u.tar.7z && \
		7z x airfont_a340u.tar.7z && \
		7z x airfont_a340u.tar && \
		mv airfont_a340u/* . && \
		mv airfont_a320u.sf2 FluidPlug.sf2 && \
		mv readme README && \
		rmdir airfont_a340u)

FluidGM.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidGM.lv2 && \
		wget http://download.linuxaudio.org/musical-instrument-libraries/sf2/fluidr3.tar.7z && \
		7z x fluidr3.tar.7z && \
		7z x fluidr3.tar && \
		mv fluidr3/* . && \
		mv fluidr3gm.sf2 FluidPlug.sf2 && \
		mv readme README && \
		rmdir fluidr3)

FluidBass.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidBass.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_bass.sf2.tar.7z && \
		7z x fluidr3gm_bass.sf2.tar.7z && \
		7z x fluidr3gm_bass.sf2.tar && \
		mv fluidr3gm_bass.sf2 FluidPlug.sf2)

FluidBrass.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidBrass.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_brass.sf2.tar.7z && \
		7z x fluidr3gm_brass.sf2.tar.7z && \
		7z x fluidr3gm_brass.sf2.tar && \
		mv fluidr3gm_brass.sf2 FluidPlug.sf2)

FluidChromPerc.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidChromPerc.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_chromaticpercussion.sf2.tar.7z && \
		7z x fluidr3gm_chromaticpercussion.sf2.tar.7z && \
		7z x fluidr3gm_chromaticpercussion.sf2.tar && \
		mv fluidr3gm_chromaticpercussion.sf2 FluidPlug.sf2)

FluidDrums.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidDrums.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_drums.sf2.tar.7z && \
		7z x fluidr3gm_drums.sf2.tar.7z && \
		7z x fluidr3gm_drums.sf2.tar && \
		mv fluidr3gm_drums.sf2 FluidPlug.sf2)

FluidEnsemble.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidEnsemble.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_ensemble.sf2.tar.7z && \
		7z x fluidr3gm_ensemble.sf2.tar.7z && \
		7z x fluidr3gm_ensemble.sf2.tar && \
		mv fluidr3gm_ensemble.sf2 FluidPlug.sf2)

FluidEthnic.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidEthnic.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_ethnic.sf2.tar.7z && \
		7z x fluidr3gm_ethnic.sf2.tar.7z && \
		7z x fluidr3gm_ethnic.sf2.tar && \
		mv fluidr3gm_ethnic.sf2 FluidPlug.sf2)

FluidGuitars.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidGuitars.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_guitar.sf2.tar.7z && \
		7z x fluidr3gm_guitar.sf2.tar.7z && \
		7z x fluidr3gm_guitar.sf2.tar && \
		mv fluidr3gm_guitar.sf2 FluidPlug.sf2)

FluidOrgans.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidOrgans.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_organ.sf2.tar.7z && \
		7z x fluidr3gm_organ.sf2.tar.7z && \
		7z x fluidr3gm_organ.sf2.tar && \
		mv fluidr3gm_organ.sf2 FluidPlug.sf2)

FluidPercussion.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidPercussion.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_percussive.sf2.tar.7z && \
		7z x fluidr3gm_percussive.sf2.tar.7z && \
		7z x fluidr3gm_percussive.sf2.tar && \
		mv fluidr3gm_percussive.sf2 FluidPlug.sf2)

FluidPianos.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidPianos.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_piano.sf2.tar.7z && \
		7z x fluidr3gm_piano.sf2.tar.7z && \
		7z x fluidr3gm_piano.sf2.tar && \
		mv fluidr3gm_piano.sf2 FluidPlug.sf2)

FluidPipes.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidPipes.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_pipe.sf2.tar.7z && \
		7z x fluidr3gm_pipe.sf2.tar.7z && \
		7z x fluidr3gm_pipe.sf2.tar && \
		mv fluidr3gm_pipe.sf2 FluidPlug.sf2)

FluidReeds.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidReeds.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_reed.sf2.tar.7z && \
		7z x fluidr3gm_reed.sf2.tar.7z && \
		7z x fluidr3gm_reed.sf2.tar && \
		mv fluidr3gm_reed.sf2 FluidPlug.sf2)

FluidSoundFX.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidSoundFX.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_soundeffects.sf2.tar.7z && \
		7z x fluidr3gm_soundeffects.sf2.tar.7z && \
		7z x fluidr3gm_soundeffects.sf2.tar && \
		mv fluidr3gm_soundeffects.sf2 FluidPlug.sf2)

FluidStrings.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidStrings.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_strings.sf2.tar.7z && \
		7z x fluidr3gm_strings.sf2.tar.7z && \
		7z x fluidr3gm_strings.sf2.tar && \
		mv fluidr3gm_strings.sf2 FluidPlug.sf2)

FluidSynthFX.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidSynthFX.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_syntheffects.sf2.tar.7z && \
		7z x fluidr3gm_syntheffects.sf2.tar.7z && \
		7z x fluidr3gm_syntheffects.sf2.tar && \
		mv fluidr3gm_syntheffects.sf2 FluidPlug.sf2)

FluidSynthLeads.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidSynthLeads.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_synthlead.sf2.tar.7z && \
		7z x fluidr3gm_synthlead.sf2.tar.7z && \
		7z x fluidr3gm_synthlead.sf2.tar && \
		mv fluidr3gm_synthlead.sf2 FluidPlug.sf2)

FluidSynthPads.lv2/FluidPlug.sf2:
	-@mkdir -p $(shell dirname $@)
	(cd FluidSynthPads.lv2 && \
		wget http://download.linuxaudio.org/kxstudio/fluidr3-splitted/fluidr3gm_synthpad.sf2.tar.7z && \
		7z x fluidr3gm_synthpad.sf2.tar.7z && \
		7z x fluidr3gm_synthpad.sf2.tar && \
		mv fluidr3gm_synthpad.sf2 FluidPlug.sf2)

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
