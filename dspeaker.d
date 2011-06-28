 /***********************************************************************
 This file is part of dspeak.

    dspeak is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    dspeak is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with dspeak.  If not, see <http://www.gnu.org/licenses/>.
    

Copyright (C) 2011 to David Osborne
email: krendilboove@gmail.com

ipats is a small IPA to speech program, built on espeech
*/

module ipats.dspeaker;

import std.conv;
import std.stdio;

import dspeak.dspeak;

import ipats.speaker;

class DSpeaker : Speaker{
    this(){
        //Initialise in playback mode, with default data path and no callback buffers
        int result = initialize();
        debug writefln("Sample rate: %d", result);
        setSynthCallback(&dummyCallback);
        //Load the IPA voice (fail miserably if not present)
        setVoice("ip");
        debug setPhonemeTrace(2);
    }
    
    string say(string text){
        EspeakError e = synth(text);
        switch(e){
            case EspeakError.EE_OK:
                return "OK";
            case EspeakError.EE_INTERNAL_ERROR:
                return "Internal Error";
            case EspeakError.EE_BUFFER_FULL:
                return "Buffer Full";
            default:
                return "Unexpected Error Value: " ~ to!string(e);
        }
    }
    
    void stop(){
        cancel();
    }
    
    void save(string toRead, string path){
        //Not implemented
    }
}

//Always continues synthesis
extern(C) private int dummyCallback(short* a, int i, Event* e){
    //printf("Received %d samples\n", i);
    return 0;
}