// Based on: Basic Sequencer Demo - James Mclain, Jim Bumgardner
// and twitter4j Examples

// send tones to a midi devices
// a prototype by: Alfredo Calosci, Michele Delogu, Rolf Lager,  Daniele Murgia.
// NeoLocalDesign Workshop 2015
// http://www.neolocaldesign.org/summer_school_2015.html

import themidibus.*;
MidiBus myBus;

// twitter
import twitter4j.conf.*;
import twitter4j.api.*;
import twitter4j.*;

import java.util.List;
import java.util.Iterator;

ConfigurationBuilder   cb;
Query query;
Twitter twitter;

ArrayList<String> twittersList; // twitter serach results

//Number twitters per search
int numberSearch = 15;

Cell[][] grid;
int kWidth = 1280;
int kHeight = 720;

int cols = 16;
int rows = 16;

int gridTop = 20;
int gridLeft = 20;

int gridWidth = kWidth - gridLeft*2;
int gridHeight = kHeight - gridTop*2;

float colWidth = gridWidth/cols;
float rowHeight = gridHeight/rows;

int kMidiChannel = 0; // Use 9 for the drum channel :)

// jbum added this variable to track current playing row
int curColumn = -1;

PFont font;
ArrayList <one_tweet> newTweets;
ArrayList <one_tweet> oldTweets;
ArrayList <one_tweet> tmpTweets;

String search;
int loopCount;

boolean multiMode; // 1 or 16 midoi channels

void setup() {
  size(1280, 720);
  colorMode(HSB, 360, 100, 100);

  newTweets = new ArrayList();
  oldTweets = new ArrayList();
  tmpTweets = new ArrayList();

  multiMode = false;

  String iniS[] = loadStrings("search_for.txt");
  search = iniS[0];

  myBus = new MidiBus(this, 0, "Virtual MIDI Bus");

  // please use your own config
  cb = new ConfigurationBuilder();      //Acreditacion
  cb.setOAuthConsumerKey("Hr8yDUZYhBwhO1OiUGyZA");   
  cb.setOAuthConsumerSecret("gmQDsJ385rYSi9WbGpKsWnfh9IPrqg03qQUc4oK2AI");   
  cb.setOAuthAccessToken("1371907867-Gmr9Rxhwq3RZaBtGWXAODS5cCMS7qDIrTvRbDFg");   
  cb.setOAuthAccessTokenSecret("SE9UIJ5rWjsxnjWngFj31Rc26pbT2ITXvwWCUez1s");

  //Make the twitter object and prepare the query
  twitter = new TwitterFactory(cb.build()).getInstance();

  //SEARCH
  queryTwitter(numberSearch);

  frameRate(8);  // jbum increased your framerate from .1

  font = loadFont("DroidSans-Bold-18.vlw");
  textFont(font, 18);
  textLeading(18); 
  textAlign(LEFT, CENTER);

  // load ini "fake" tweets
  String iniT[] = loadStrings("tweets_init.txt");

  for (int i = 0; i < iniT.length; i++) {
    String[] iniT_line = split(iniT[i], ';');
    one_tweet T = new one_tweet(float(iniT_line[0]), iniT_line[1], iniT_line[2] );
    oldTweets.add(T);
  }

  grid = new Cell[cols][rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      grid[x][y] = new Cell(x, y);
    }
  }
}

void draw() {
  background(0, 0, 0);

  fill(0, 0, 100);
  stroke(0, 0, 100);

  String msg = loopCount + " / 16 / " + newTweets.size();
  //text(msg, 20, 30);

  // Added this code to keep track of where we are, and where we've been
  curColumn = (curColumn + 1) % cols;

  if (curColumn == 0) {
    // add new
    addTweet();
    loopCount ++;

    if (loopCount >= 16) {
      loopCount = 0;
      queryTwitter(numberSearch);
    }
  }

  int lastColumn = (curColumn + cols-1) % cols; 
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      Cell cell = grid[x][y];
      if (cell.stat && cell.x == curColumn)
        cell.noteOn();
      else if (cell.stat && cell.x == lastColumn)
        cell.noteOff();
      else
        cell.display();
    }
  }

  // second loop for texts
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      Cell cell = grid[x][y];
      cell.displayTxt();
    }
  }
} // end draw

boolean setState = false;

void mousePressed() {
  int gx = (int) map(mouseX-gridLeft, 0, gridWidth, 0, cols);
  int gy = (int) map(mouseY-gridTop, 0, gridHeight, 0, rows);

  if (gx >= 0 && gx < cols && gy >= 0 && gy < rows) {
    setState = !grid[gx][gy].stat;
    grid[gx][gy].stat = setState;

    if (setState) {
      grid[gx][gy].counter= 0;
    }
  }
}

void mouseDragged() {
  int gx = (int) map(mouseX-gridLeft, 0, gridWidth, 0, cols);
  int gy = (int) map(mouseY-gridTop, 0, gridHeight, 0, rows);
  if (gx >= 0 && gx < cols && gy >= 0 && gy < rows) {
    grid[gx][gy].stat = setState;
  }
}

void addTweet() {

  // if exist > add real one
  if (newTweets.size() > 0) {
    // add a real one
    addRealTweet();
  } else {
    // otherwise add fake one
    // addFakeTweet();
  }
}

void addFakeTweet() {
  println("new fake tweet");
  int n = floor(random(oldTweets.size()));
  one_tweet TT = oldTweets.get(n);
  // println(TT.txt);
  // assign to a dot
  tweetToDot(TT);
}

void addRealTweet() {
  println("new real tweet");
  int n = floor(random(newTweets.size()));
  one_tweet TT = newTweets.get(n);
  // add to olds
  oldTweets.add(TT);
  // remove this
  newTweets.remove(n);
  // assign to a dot
  tweetToDot(TT);
}

void tweetToDot(one_tweet T) {

  int gx = (int) random(cols);
  int gy = (int) random(rows);

  boolean b = grid[gx][gy].stat;

  if (b) {
    // active
    tweetToDot(T);
  } else {

    Cell myDot = grid[gx][gy];
    myDot.stat = true;
    myDot.counter = 0;
    myDot.txt = T.txt;
    myDot.user = T.usr;
  }
}

void keyPressed() {
  if (key == ' ') {
    addFakeTweet();
  }
  
  if (key == 'm' || key == 'M') {
    multiMode = !multiMode;
    println("multiMode = " + multiMode);
  }
  
}

void queryTwitter(int nSearch) {
  query = new Query(search);
  query.setCount(nSearch);
  try {
    QueryResult result = twitter.search(query);
    List<Status> tweets = result.getTweets();

    for (Status tw : tweets) {
      String msg = tw.getText();
      String usr = tw.getUser().getScreenName();
      String twStr = "@"+usr+": "+msg;
      float id_msg = tw.getId();

      one_tweet TN = new one_tweet(id_msg, usr, msg);
      tmpTweets.add(TN);
    }

    updateTweets();
  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  }

}

void updateTweets() {

  for (int n = 0; n< tmpTweets.size(); n++) {
    // check if new
    one_tweet A = tmpTweets.get(n);
    boolean N = isNew(A.id);

    if (N) {
      newTweets.add(A);
    }
  }

  tmpTweets = new ArrayList();
}

boolean isNew(float myID) {
  boolean res = true;
  for (int n = 0; n< oldTweets.size(); n++) {
    one_tweet A = oldTweets.get(n);
    if (A.id == myID) {
      res = false;
      break;
    }
  }

  return res;
}