/*
 * 2FS
 * Copyright (C) 2015 Filipe Coelho <falktx@falktx.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * For a full copy of the GNU General Public License see the LICENSE file.
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

#ifndef _2FS_LABEL
#error _2FS_LABEL undefined
#endif

#define _2FS_PREFIX "http://kxstudio.sf.net/plugins/2fs_"
#define _2FS_URI    _2FS_PREFIX _2FS_LABEL

typedef struct {
    // fluidsynth data
    fluid_settings_t* settings;
    fluid_synth_t*    synth;
    unsigned          synthId;
    // lv2 data
    float*                   buffers[3];
    const LV2_Atom_Sequence* events;
    LV2_URID                 midiEventURID;
    bool                     needsReset;
} FluidSynthPluginData;

typedef enum {
    kPortEvents = 0,
    kPortAudioOutL,
    kPortAudioOutR,
    kPortProgram
} FluidSynthPluginPorts;

static LV2_Handle lv2_instantiate(const struct _LV2_Descriptor * descriptor, double sampleRate, const char* bundlePath, const LV2_Feature* const* features)
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
    fluid_settings_setint(settings, "synth.parallel-render", 1);
    fluid_settings_setint(settings, "synth.threadsafe-api", 0);

    fluid_synth_t* const synth = new_fluid_synth(settings);

    if (synth == NULL)
        goto cleanup_settings;

    fluid_synth_set_gain(synth, 1.0f);
    fluid_synth_set_polyphony(synth, 32);
    fluid_synth_set_sample_rate(synth, (float)sampleRate);

    char* filename = malloc(strlen(bundlePath) + 8 /* strlen("/2fs.sf2") */ + 2);

    if (filename == NULL)
        goto cleanup_synth;

    strcpy(filename, bundlePath);
    strcat(filename, "/2fs.sf2");

    const int synthId = fluid_synth_sfload(synth, filename, 0);

    free(filename);

    if (synthId < 0)
        goto cleanup_synth;

    fluid_synth_program_reset(synth);

    fluid_sfont_t* const sfont = fluid_synth_get_sfont_by_id(synth, synthId);

    if (sfont == NULL)
        goto cleanup_synth;

    fluid_preset_t preset;
    sfont->iteration_start(sfont);

    if (sfont->iteration_next(sfont, &preset) == 0)
        goto cleanup_synth;

    const int bank = preset.get_banknum(&preset);
    const int prog = preset.get_num(&preset);
    fluid_synth_program_select(synth, 0, synthId, bank, prog);

    // fluidsynth data
    data->settings = settings;
    data->synth    = synth;
    data->synthId  = synthId;

    // lv2 data
    data->midiEventURID = uridMap->map(uridMap->handle, LV2_MIDI__MidiEvent);
    data->needsReset   = false;

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
    case kPortProgram:
        data->buffers[port-1] = dataLocation;
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
    if (frames == 0)
        // do nothing in pre-roll mode
        return;

    FluidSynthPluginData* const data = instance;

    if (data->needsReset)
    {
        for (int i=0; i<16; ++i)
        {
            fluid_synth_all_notes_off(data->synth, i);
            fluid_synth_all_sounds_off(data->synth, i);
        }
        data->needsReset = false;
    }

#if 0
    // Check for updated parameters
    float curValue;

    for (uint32_t i=0; i < fPorts.paramCount; ++i)
    {
        if (fPorts.paramsOut[i])
            continue;

        CARLA_SAFE_ASSERT_CONTINUE(fPorts.paramsPtr[i] != nullptr)

        curValue = *fPorts.paramsPtr[i];

        if (carla_isEqual(fPorts.paramsLast[i], curValue))
            continue;

        fPorts.paramsLast[i] = curValue;
        fDescriptor->set_parameter_value(fHandle, i, curValue);
    }
#endif

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
        default:
            continue;
        }

        if (event->time.frames > frameOffset)
            fluid_synth_write_float(data->synth, event->time.frames-frameOffset, data->buffers[0]+frameOffset, 0, 1, data->buffers[1]+frameOffset, 0, 1);

        frameOffset = event->time.frames;

        const uint8_t channel = mdata[0] & 0x0F;

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
            if (control == 0 || control == 0x20)
                continue;
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

    delete_fluid_synth(data->synth);
    delete_fluid_settings(data->settings);
    free(data);
}

LV2_SYMBOL_EXPORT
const LV2_Descriptor* lv2_descriptor(uint32_t index)
{
    static const LV2_Descriptor sDescriptor = {
        .URI            = _2FS_URI,
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
