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

#include <fluidsynth.h>

// NOTE: this code doesn't have any error checks because it's going to be run just once

int main()
{
    fluid_settings_t* const settings = new_fluid_settings();
    fluid_settings_setnum(settings, "synth.sample-rate", 48000.0);
    fluid_settings_setint(settings, "synth.parallel-render", 1);
    fluid_settings_setint(settings, "synth.threadsafe-api", 0);

    fluid_synth_t* const synth = new_fluid_synth(settings);
    fluid_synth_set_gain(synth, 1.0f);
    fluid_synth_set_polyphony(synth, 32);
    fluid_synth_set_sample_rate(synth, 48000.0f);

    const int synthId = fluid_synth_sfload(synth, "./FluidPlug.sf2", 1);

    fluid_sfont_t* const sfont = fluid_synth_get_sfont_by_id(synth, synthId);

    int count = 0;
    int bank = -1;
    fluid_preset_t preset;
    sfont->iteration_start(sfont);
    for (; sfont->iteration_next(sfont, &preset) != 0;)
    {
        ++count;
        const int banknum = preset.get_banknum(&preset)+1;

        if (bank == -2)
            continue;

        if (bank == -1)
            bank = banknum;
        else if (bank != banknum)
            bank = -2;
    }

    printf("        lv2:maximum %i ;\n", count);
    printf("        lv2:scalePoint [\n");

    int index = 0;
    sfont->iteration_start(sfont);
    for (; sfont->iteration_next(sfont, &preset) != 0; ++index)
    {
        const char* const name = preset.get_name(&preset);

        if (index != 0)
            printf("        ] , [\n");

        printf("            rdfs:label \"");

#if 1
        if (bank == -2)
            printf("%03i:", preset.get_banknum(&preset)+1);

        if (count > 100)
            printf("%03i", index+1);
        else if (count > 10)
            printf("%02i", index+1);
        else
            printf("%i", index+1);

        printf(" %s\" ;\n", name);
#else
        printf("%s\" ;\n", name);
#endif
        printf("            rdf:value %i ;\n", index);
    }

    printf("        ] ;\n");

    delete_fluid_synth(synth);
    delete_fluid_settings(settings);

    return 0;
}
