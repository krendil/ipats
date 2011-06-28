module ipats.gui;

import std.conv;
import std.stdio;

import gtk.Button;
import gtk.HButtonBox;
import gtk.Statusbar;
import gtk.Main;
import gtk.MainWindow;
import gtk.StockItem;
import gtk.TextView;
import gtk.VBox;

import ipats.speaker;
import ipats.dspeaker;

class IPATSWindow : MainWindow {
    
    //Default amount of spacing between widgets
    static immutable int spacing = 2;
    
    //The box for entering text
    TextView entryBox;
    
    //A label for status feedback
    Statusbar status;
    
    //The actual TTS engine
    Speaker speaker;
    
    this(Speaker speaker){
        super("IPATS");
        
        this.speaker = speaker;
        
        //This box will contain the text entry space and a row of buttons
        VBox v = new VBox(false, spacing);
        
        entryBox = new TextView();
        entryBox.setSizeRequest(-1, 48); //we want a couple of lines
        
        //This box will contain a row of buttons
        auto h = new HButtonBox();
        
        Button play = new Button(StockID.MEDIA_PLAY, &play, true);
        Button stop = new Button(StockID.MEDIA_STOP, &stop, true);
        Button save = new Button(StockID.SAVE_AS, &save, true);
        Button quit = new Button(StockID.QUIT, &quit, true);
        
        h.add(play);
        h.add(stop);
        h.add(save);
        h.add(quit);
        
        //A statusbar-oid will provide feedback
        auto status = new Statusbar();
        status.setSizeRequest(-1, 16);
        
        v.add(entryBox);
        v.add(h);
        v.add(status);
        
        add(v);
        showAll();
        
    }
    
    /**
    Sends the inserted text to the TTS player thingy
    */
    void play(Button b){
        string result = speaker.say(entryBox.getBuffer().getText());
        debug writeln(result);
    }
    
    /**
    Stops the currently playing sound, if any
    */
    void stop(Button b){
        speaker.stop();
    }
    
    /**
    Allows the user to save the audio output to file
    */
    void save(Button b){
        //Open file dialog
        //speaker.save(  , entryBox.getBuffer().getText());
    }
    
    /**
    Exits the program, supposedly
    */
    void quit(Button b){
        exit(0, false);
        Main.quit();
    }
    
}

void main(string[] args){
    
    Main.init(args);
    
    auto s = new DSpeaker();
    auto w = new IPATSWindow(s);
    
    Main.run();
}
        
        