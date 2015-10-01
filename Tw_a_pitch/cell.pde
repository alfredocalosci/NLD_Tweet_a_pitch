class Cell {
  int x, y;
  boolean stat;
  int noteNumber;

  int spanLife;
  int counter;

  int H, fillShade;

  String user, txt;

  // Cell Constructor
  Cell(int x, int y) {
    this.x = x;
    this.y = y;
    noteNumber = (int) map(y, 0, rows, 64-rows/2, 64+rows/2);
    stat = false;

    H = 240;

    H = floor(map(y, 0, rows, 240, 480)%360);
    counter = 0;
    spanLife = 8 * 2; // maybe 2 ?


    fillShade = 20;

    user = "@BacklineImport";
    txt = "@WarwickFramus está uniendo a los guitarristas y bajistas contra el racismo. ¡Súmate a la causa! https://t.co/Xg3BvnZnkJ #againstracism";
  } 

  void dodraw() {
    noStroke();
    fill(H, 80, fillShade);
    ellipse(x*colWidth + gridLeft + colWidth/2, y*rowHeight+gridTop+colWidth/2, colWidth*0.2, colWidth*0.2);
  }

  void display() {
    noStroke();
    fillShade = stat? 90 : 30;

    fill(H, 80, fillShade);

    // time span
    fill(H, 80, fillShade, 128);
    ellipse(x*colWidth + gridLeft + colWidth/2, y*rowHeight+gridTop+colWidth/2, colWidth*0.5, colWidth*0.5);

    dodraw();
  }

  void displayTxt() {
    // text
    if (stat) {
      float a = map(counter, 0, spanLife, 255, 0);
      fill(H, 80, 100, a);
      text("." + txt, x*colWidth + 96, y*rowHeight, width/4, height/8);
    }
  }

  void noteOn() {
    
    // play the note
    if(multiMode){
      myBus.sendNoteOn(y, noteNumber, 40);
    } else{
      myBus.sendNoteOn(kMidiChannel, noteNumber, 40);
    }
    
    fill(255, 255, 0);
    counter ++;

    if (counter > spanLife) {
      stat = false;
    }

    dodraw();
  }

  void noteOff() {
    
    if(multiMode){
       myBus.sendNoteOff(y, noteNumber, 0);
    } else{
      myBus.sendNoteOff(kMidiChannel, noteNumber, 0);
    }
    
    display();
  }
} // end of Cell class