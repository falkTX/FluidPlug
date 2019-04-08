/*
 * FluidPlug - SoundFonts as LV2 plugins via FluidSynth
 * Copyright (C) 2015-2016 Filipe Coelho <falktx@falktx.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public License
 * as published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * For a full copy of the GNU Library General Public License see the LICENSE file.
 */

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#include <fluidsynth.h>
#include <lv2/lv2plug.in/ns/lv2core/lv2.h>
#include <lv2/lv2plug.in/ns/ext/atom/atom.h>
#include <lv2/lv2plug.in/ns/ext/atom/util.h>
#include <lv2/lv2plug.in/ns/ext/midi/midi.h>
#include <lv2/lv2plug.in/ns/ext/urid/urid.h>

#ifndef FLUIDPLUG_LABEL
#error FLUIDPLUG_LABEL undefined
#endif

#define FLUIDPLUG_PREFIX "http://kxstudio.linuxaudio.org/plugins/FluidPlug_"
#define FLUIDPLUG_URI    FLUIDPLUG_PREFIX FLUIDPLUG_LABEL

typedef struct {
    int bank;
    int prog;
} BankProgram;

typedef struct {
    // fluidsynth data
    BankProgram*      programs;
    fluid_settings_t* settings;
    fluid_synth_t*    synth;
    int               synthId;

    // lv2 data
    float*                   buffers[2];
    const float*             controlLevel;
    const float*             controlProgram;
    int                      currentProgram;
    const LV2_Atom_Sequence* events;
    LV2_URID                 midiEventURID;
    bool                     needsReset;
} FluidSynthPluginData;

typedef enum {
    kPortEvents = 0,
    kPortAudioOutL,
    kPortAudioOutR,
    kPortLevel,
    kPortProgram,
} FluidSynthPluginPorts;

static LV2_Handle lv2_instantiate(const struct _LV2_Descriptor* descriptor, double sampleRate, const char* bundlePath, const LV2_Feature* const* features)
{
    const LV2_URID_Map* uridMap = NULL;

    for (int i=0; features[i] != NULL; ++i)
    {
        if (strcmp(features[i]->URI, LV2_URID__map) == 0)
        {
            uridMap = (const LV2_URID_Map*)features[i]->data;
            break;
        }
    }

    if (uridMap == NULL)
        return NULL;

    FluidSynthPluginData* const data = malloc(sizeof(FluidSynthPluginData));

    if (data == NULL)
        return NULL;

    fluid_settings_t* const settings = new_fluid_settings();

    if (settings == NULL)
        goto cleanup;

    //fluid_settings_setint(settings, "synth.audio-channels", use16Outs ? 16 : 1);
    //fluid_settings_setint(settings, "synth.audio-groups", use16Outs ? 16 : 1);
    fluid_settings_setnum(settings, "synth.sample-rate", sampleRate);
    //fluid_settings_setint(settings, "synth.parallel-render", 1);
    fluid_settings_setint(settings, "synth.threadsafe-api", 0);

    fluid_synth_t* const synth = new_fluid_synth(settings);

    if (synth == NULL)
        goto cleanup_settings;

    fluid_synth_set_gain(synth, 1.0f);
    fluid_synth_set_polyphony(synth, 32);
    fluid_synth_set_sample_rate(synth, (float)sampleRate);

#ifdef __arm__
    // let's be nice to the poor cpus...
    fluid_synth_set_interp_method(synth, -1, FLUID_INTERP_LINEAR);
#endif

    char* filename = malloc(strlen(bundlePath) + 14 /* strlen("/FluidPlug.sf2") */ + 1);

    if (filename == NULL)
        goto cleanup_synth;

    strcpy(filename, bundlePath);
    strcat(filename, "/FluidPlug.sf2");

    const int synthId = fluid_synth_sfload(synth, filename, 1);

    free(filename);

    if (synthId < 0)
        goto cleanup_synth;

    fluid_sfont_t* const sfont = fluid_synth_get_sfont_by_id(synth, synthId);

    if (sfont == NULL)
        goto cleanup_synth;

    size_t count;
#if FLUIDSYNTH_VERSION_MAJOR < 2
    fluid_preset_t preset;

    sfont->iteration_start(sfont);
    for (count = 0; sfont->iteration_next(sfont, &preset) != 0;)
        ++count;
#else
    fluid_preset_t *preset = NULL;

    fluid_sfont_iteration_start(sfont);
    for (count = 0; (preset = fluid_sfont_iteration_next(sfont)) != NULL;)
        ++count;
#endif

    if (count == 0)
        goto cleanup_synth;

    BankProgram* const programs = malloc(sizeof(BankProgram)*count);

    if (programs == NULL)
        goto cleanup_synth;

#if FLUIDSYNTH_VERSION_MAJOR < 2
    sfont->iteration_start(sfont);
    for (count = 0; sfont->iteration_next(sfont, &preset) != 0;)
    {
        const BankProgram bp = {
            preset.get_banknum(&preset),
            preset.get_num(&preset)
        };
        programs[count++] = bp;
    }
#else
    fluid_sfont_iteration_start(sfont);
    for (count = 0; (preset = fluid_sfont_iteration_next(sfont)) != NULL;)
    {
        const BankProgram bp = {
            fluid_preset_get_banknum(preset),
            fluid_preset_get_num(preset)
        };
        programs[count++] = bp;
    }
#endif

    fluid_synth_program_select(synth, 0, synthId, programs[0].bank, programs[0].prog);

    // fluidsynth data
    data->settings = settings;
    data->synth    = synth;
    data->synthId  = synthId;
    data->programs = programs;

    // lv2 data
    data->currentProgram = 0;
    data->midiEventURID  = uridMap->map(uridMap->handle, LV2_MIDI__MidiEvent);
    data->needsReset     = false;

    // null control values, connection optional
    data->controlProgram = NULL;

    // boostrap synth engine
    float l[1024];
    float r[1024];
    fluid_synth_write_float(synth, 1024, l, 0, 1, r, 0, 1);

    return data;

cleanup_synth:
    delete_fluid_synth(synth);

cleanup_settings:
    delete_fluid_settings(settings);

cleanup:
    free(data);
    return NULL;

    // unused
    (void)descriptor;
}

static void lv2_connect_port(LV2_Handle instance, uint32_t port, void* dataLocation)
{
    FluidSynthPluginData* const data = instance;

    switch (port)
    {
    case kPortEvents:
        data->events = dataLocation;
        break;

    case kPortAudioOutL:
    case kPortAudioOutR:
        data->buffers[port-1] = dataLocation;
        break;

    case kPortLevel:
        data->controlLevel = dataLocation;
        break;

    case kPortProgram:
        data->controlProgram = dataLocation;
        break;
    }
}

static void lv2_activate(LV2_Handle instance)
{
    FluidSynthPluginData* const data = instance;

    data->needsReset = true;
}

static void lv2_run(LV2_Handle instance, uint32_t frames)
{
    // do nothing in pre-roll mode
    if (frames == 0)
        return;

    FluidSynthPluginData* const data = instance;

    if (data->needsReset)
    {
        /*
        for (int i=0; i<16; ++i)
        {
            fluid_synth_all_notes_off(data->synth, i);
            fluid_synth_all_sounds_off(data->synth, i);
        }
        */
        fluid_synth_all_notes_off(data->synth, 0);
        fluid_synth_all_sounds_off(data->synth, 0);
        data->needsReset = false;
    }

    fluid_synth_set_gain(data->synth, *data->controlLevel);

    if (data->controlProgram != NULL)
    {
        const float currentProgram_f = *data->controlProgram;
        const int   currentProgram_i = (int)(currentProgram_f+0.5f);

        if (currentProgram_i != data->currentProgram && currentProgram_i >= 0)
        {
            data->currentProgram = currentProgram_i;
            fluid_synth_program_select(data->synth, 0, data->synthId, data->programs[currentProgram_i].bank, data->programs[currentProgram_i].prog);
        }
    }

    uint32_t frameOffset = 0;

    LV2_ATOM_SEQUENCE_FOREACH(data->events, event)
    {
        if (event == NULL)
            continue;
        if (event->body.type != data->midiEventURID)
            continue;
        if (event->body.size > 4)
            continue;
        if (event->time.frames >= frames)
            break;

        const uint8_t* const mdata  = (const uint8_t*)(event + 1);
        const uint8_t        status = mdata[0] & 0xF0;

        switch (status)
        {
        case 0x80:
        case 0x90:
        case 0xD0:
        case 0xE0:
            break;
        case 0xB0:
            if (mdata[1] != 0 && mdata[1] != 0x20)
                break;
            // skip bank changes
        default:
            continue;
        }

        if (event->time.frames > frameOffset)
            fluid_synth_write_float(data->synth, event->time.frames-frameOffset, data->buffers[0]+frameOffset, 0, 1, data->buffers[1]+frameOffset, 0, 1);

        frameOffset = event->time.frames;

        const uint8_t channel = 0; //mdata[0] & 0x0F;

        switch (status)
        {
        case 0x80: {
            const uint8_t note = mdata[1];
            fluid_synth_noteoff(data->synth, channel, note);
        } break;

        case 0x90: {
            const uint8_t note = mdata[1];
            const uint8_t velo = mdata[2];
            fluid_synth_noteon(data->synth, channel, note, velo);
        } break;

        case 0xB0: {
            const uint8_t control = mdata[1];
            const uint8_t value   = mdata[2];
            fluid_synth_cc(data->synth, channel, control, value);
        } break;

        case 0xD0: {
            const uint8_t pressure = mdata[1];
            fluid_synth_channel_pressure(data->synth, channel, pressure);;
        } break;

        case 0xE0: {
          const uint8_t lsb = mdata[1];
          const uint8_t msb = mdata[2];
          fluid_synth_pitch_bend(data->synth, channel, (msb<<7)|lsb);
        } break;
        }
    }

    if (frames > frameOffset)
        fluid_synth_write_float(data->synth, frames-frameOffset, data->buffers[0]+frameOffset, 0, 1, data->buffers[1]+frameOffset, 0, 1);
}

static void lv2_cleanup(LV2_Handle instance)
{
    FluidSynthPluginData* const data = instance;

    free(data->programs);
    delete_fluid_synth(data->synth);
    delete_fluid_settings(data->settings);
    free(data);
}

LV2_SYMBOL_EXPORT
const LV2_Descriptor* lv2_descriptor(uint32_t index)
{
    static const LV2_Descriptor sDescriptor = {
        .URI            = FLUIDPLUG_URI,
        .instantiate    = lv2_instantiate,
        .connect_port   = lv2_connect_port,
        .activate       = lv2_activate,
        .run            = lv2_run,
        .deactivate     = NULL,
        .cleanup        = lv2_cleanup,
        .extension_data = NULL,
    };

    return (index == 0) ? &sDescriptor : NULL;
}
