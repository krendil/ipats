module ipats.samplespeaker;

import std.stdio;
import std.conv : to;
import std.string : toStringz;

import derelict.sdl.sdl;
import derelict.sdl.mixer;

import ipats.samplemap;
import ipats.speaker;


/**
Contains some basic messages returned by play()
*/
enum Messages : string {
    success = "Playing...",
    fileError = "Error loading file",
    playbackError = "Error playing sound",
    other = "Unknown Error",
    empty = "No text"
}



/**
Plays back a series of .mp3 files depending on the text.

Built on SDL_mixer.
*/
class SampleSpeaker : Speaker{
    
    public:
        
    this(CharMap map = ipaMap){
        
        DerelictSDL.load(); //Load shared libraries, initialise derelict
        DerelictSDLMixer.load();
        
        if( SDL_Init(SDL_INIT_AUDIO) ){
            writefln("SDL error: %s", SDL_GetError());
        }        
        /+if( Mix_Init(Mix_MusicType.MUS_OGG) ){
            writefln("SDL_mixer error: %s", Mix_GetError());
        }+/
        
        /* open the audio device with 44.1kHz frequency, 16bit signed format,
        mono output, and 512 bytes/chunk */
        if( Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 1, 512) ){
            writefln("SDL_mixer error: %s", Mix_GetError());
        }
        
        this.fileNames = map;
        
        //Autoplay all samples in the cache
        wrapPostMix(&SampleSpeaker.playNextSample);
        stop();
    }
    
    
    /**
    Interpret the text and play a sound
    
    Reads the text, by playing a series of audio samples.
    
    toRead: A read-only utf-8 string containing the text to be read.
    Returns: A string containing an error message if failed, 
        or a success message on success.  This message will be displayed to the user
    */ 
    string say(in wstring toRead){
        if(toRead.length == 0) return Messages.empty.idup;
        
        //Stop playback, just in case
        stop();
        
        currentSample = 0;
        if( loadSamples(toRead) ){
            return Messages.fileError.idup;
        }
        
        //Play the samples
        playing = true;
        if( Mix_PlayChannel(-1, cache[0], 0) < 0){
            
            writefln("SDL_mixer error: %s", to!string(Mix_GetError()));
            return Messages.playbackError.idup;
            
        }
        
        return Messages.success.idup;
    }
    
    /**
    Stops playback if playing; otherwise, does nothing
    */
    void stop(){
        playing = false;
        //Stop all playing channels
        Mix_HaltChannel(-1);
    }
    
    /**
    Saves the full audio file to the specified absolute filename
    
    File type is Ogg Vorbis.
    
    toRead: A read-only utf-8 string containing the text to be read
    path: The absolute path of where to save the file.
    */
    void save(in string toRead, in string path){
        
    }
    
    private:
    
    //An AA mapping characters to sound files
    CharMap fileNames;
    
    //The current sample index
    size_t currentSample = 0;
    
    //Store for caching reasons
    wstring lastString;
    
    //The current chunk of samples
    Mix_Chunk*[] cache;
    
    //Flag used for halting
    bool playing;
    
    /**
    Loads the samples corresponding to the readable characters in the string
    
    toRead: A read-only utf-8 string containing the text to be read.
    Returns: An array containing the loaded samples
    */
    int loadSamples(in wstring toRead){
        //We still have the samples cached - don't load them again
        if (toRead == lastString) return 0;
        
        emptyCache();

        //There will never be more samples needed than characters
        cache.length = toRead.length;
        size_t i;
        
        foreach(wchar c; toRead){
            if( !(c in fileNames) ) continue;
            
            auto rw = SDL_RWFromFile(toStringz("sounds/"~fileNames[c]), "r".ptr);
            
            if(rw is null){
                writefln("Error opening file %s: %s", fileNames[c],
                    to!string(SDL_GetError()));
                return -1;
            }
            
            cache[i] = Mix_LoadWAV_RW(rw, 1);
            if(cache[i] is null){
                writefln("Error loading file %s: %s", fileNames[c], 
                    to!string(Mix_GetError()));
                return -1;
            }
            
            ++i;
        }
        
        cache = cache[0..i];
        
        //Old-fashioned error handling
        return 0;
    }
    
    /**
    Increment currentSample and play on the given channel
    Used as callback
    */
    void playNextSample(){
        //Only continue if we are actually meant to be playing
        if(!playing) return;
        //Only continue if the current sample has actually finished playing
        if(Mix_Playing(-1) > 0) return;
        
        //debug writefln("Incrementing currentSample from %s", to!string(currentSample));
        currentSample++;
        //Stop if we've reached the end
        if(currentSample >= cache.length){
            playing = false;
            return;
        }
        debug writefln("Playing sample %s", to!string(currentSample));
        Mix_PlayChannel(-1, cache[currentSample], 0);
            
    }
    
    /**
    Empties the cache.  Frees all the chunks inside.
    */
    void emptyCache(){
        foreach(c; cache){
            Mix_FreeChunk(c);
            c = null;
        }
        cache.length = 0;
    }
    
    void wrapPostMix(void delegate() d){
        auto del = new Delegate;
        del.dg = d;
        debug writefln("Callback address: %s", to!string(&finished));
        Mix_SetPostMix(&effect, del);
    }
}

struct Delegate{
    void delegate() dg;
}

/**
A dummy effect.  We're just using effects for the *udata when the channel is finished.
Maybe we'll put a real effect there someday
*/
extern(C) void effect(void* udata, ubyte* stream, int length){
    auto d = (cast(Delegate*) udata);
    d.dg();
}

extern(C) void finished(int channel, void* udata){
    
}