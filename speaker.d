module ipats.speaker;

/**
A basic wrapper for the text-to-speech interface.

Making an interface will let us create different kinds of backends in the future,
like a SAMPA reader, or a full synthesizer backend.
*/
interface Speaker{
    /**
    Interpret the text and play a sound
    
    How to interpret the text and play the sound is up to the implementation.
    
    toRead: A read-only utf-8 string containing the text to be read
    Returns: A string containing an error message if failed, 
        or a success message on success.  This message will be displayed to the user
    */ 
    string say(string toRead);
    
    /**
    Stops playback if playing; otherwise, does nothing
    */
    void stop();
    
    /**
    Saves the full audio file to the specified absolute filename
    
    toRead: A read-only utf-8 string containing the text to be read
    path: The absolute path of where to save the file.
    */
    void save(string toRead, string path);
}