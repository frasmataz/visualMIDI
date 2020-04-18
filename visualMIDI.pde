import themidibus.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.HashMap;

static class ToneColours {
  public static color[] tones = {
   #0b0b67, // 1
   #39670b, // 1#
   #670b67, // 2
   #0b6739, // 2#
   #670b0b, // 3
   #0b3967, // 4
   #67670b, // 4#
   #390b67, // 5
   #0b670b, // 5#
   #670b39, // 6
   #0b6767, // 6#
   #67390b  // 7
  };
}

int toneOffset = 3; // C is 0, C# is 1, etc
float scrollSpeed = 0.6;
int lineTimeout = 1000; // Maximum time in ms between notes to draw a line between them
int minMidiNote = 21; // default 36
int maxMidiNote = 108; // default 84 This is the range of my 48-key keyboard

MidiBus midiBus = new MidiBus(this, "loopMIDI Port", -1);
ArrayList<NoteEvent> eventList = new ArrayList<NoteEvent>(); 

void setup() { 
  size(1920, 1080);
  background(0);
  strokeWeight(4);
  blendMode(EXCLUSION);
}

void draw() {
  noStroke();
  clear();
  
  long frameTime = System.currentTimeMillis();
  HashMap<Integer, NoteEvent> lastNoteEvents = new HashMap<Integer, NoteEvent>();
  
  // Iterate through all note events
  for (int i = 0; i < eventList.size(); i++) {
    NoteEvent event = eventList.get(i);
    
    // Clear up notes that have scrolled more than a canvas width off the canvas.
    if (width - (frameTime - event.time) * scrollSpeed < -width) {
      eventList.remove(i);
      
    // Otherwise, draw the note
    } else {
      if (lastNoteEvents.containsKey(event.note.channel)) {
        NoteEvent previousNote = lastNoteEvents.get(event.note.channel);

        if (
          event.time - previousNote.time < lineTimeout && // Check if notes are close enough to draw lines between..
          event.time - previousNote.time > 5              // ..but not right on top of each other.
        ) {
          stroke(ToneColours.tones[(previousNote.note.pitch - toneOffset) % 12]);
          line(
            width - (frameTime - previousNote.time) * scrollSpeed,
            height - ((previousNote.note.pitch - minMidiNote) * height / (maxMidiNote - minMidiNote)),
            width - (frameTime - event.time) * scrollSpeed,
            height - ((event.note.pitch - minMidiNote) * height / (maxMidiNote - minMidiNote))
          );
          noStroke();
        }
      }

      lastNoteEvents.put(event.note.channel, event);

      fill(ToneColours.tones[(event.note.pitch - toneOffset) % 12]);
      circle(
        width - (frameTime - event.time) * scrollSpeed, 
        height - ((event.note.pitch - minMidiNote) * height / (maxMidiNote - minMidiNote)), // Map midi notes to heights on the canvas
        (event.note.velocity + 10) * 1.5
      );
    }
  }
}

void noteOn(int channel, int pitch, int velocity) {
  eventList.add(
    new NoteEvent(new Note(channel, pitch, velocity),
    true,
    System.currentTimeMillis()
  ));
}

class NoteEvent {
  public Note note;
  public boolean isOn; // True for note on, False for note off
  public long time;
  
  public NoteEvent(Note note_, boolean isOn_, long time_) {
    note = note_;
    isOn = isOn_;
    time = time_;
  }
}
