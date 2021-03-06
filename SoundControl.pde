import processing.sound.*;
/**
 This class holds all the methods to control
 the video by analyzing the Rick Astley song
 using FFT analysis
 **/
class SoundControl {

  //The amount of bands the FFT analysis uses.
  final int numBands = 32;
  //The array that contains the frame by frame FFT spectrum
  float[] bands = new float[numBands];
  //The array that contains the spectrum, eased over time
  float[] spectrum = new float[numBands];
  //This is the min and max for every frequency band
  float[][] bounds;

  //This is the instance that does the actual FFT analysis
  FFT fft;

  //Never Gonna Give You Up wave file.
  SoundFile soundFile;

  //The boolean that shows if we're waiting for permission to start
  boolean waiting = true;

  //Millis that started playback
  int startTime = 0;

  /**
   Creates a new SoundControl object, this
   also automatically starts loading the sound
   file from the data/music folder
   
   @param PApplet app a reference of the main sketch
   **/
  SoundControl(PApplet app) {
    //Load the soundFile from the music folder in the data folder
    soundFile = new SoundFile(app, "../music/rickastley.wav");

    //Now also instantiate the actual FFT analysis object
    fft = new FFT(app, numBands);
    //Set the input of the FFT analysis to the soundFile that just loaded
    fft.input(soundFile);

    //Load the bounds CSV
    bounds = parseBounds(loadStrings("../music/bounds.csv"));
    //First set the frameRate to 2
    frameRate(2);
  }

  /**
   Returns the channel output by name (A, B, C, D, E)
   **/
  float getChannel(int i) {
    if (i == 0) return getBand(0);
    else if (i == 1) return getExtremeBand(1);
    else if (i == 2) return getExtremeBand(5);
    else if (i == 3) return getExtremeBand(7);
    else if (i == 4) return getExtremeBand(28);
    else return 0f;
  }

  /**
   Updates SoundControl, forwards its calls to checkWaiting
   or analyze, depending on the circumstances
   **/
  void update() {
    if (waiting) {
      checkWaiting();
    } else {
      analyze();
    }
  }

  /**
   Returns the position of the playback in seconds
   **/
  float getPosition() {
    if(startTime == 0) return 0;
    return (millis() - startTime) / 1000f;
  }

  /**
   Will check if we can start yet, if so we do
   **/
  void checkWaiting() {
    String[] lines;
    try{
      lines = loadStrings("https://www.interwing.nl/meta-media/start.txt");
    }catch(Exception e){
      lines = new String[]{"1"};
    }
    lines[0] = lines[0].replaceAll("\n", "").trim();
    if (lines[0].equals("1")) {
      //We're no longer waiting, we can start all applications
      waiting = false;
      //Now we start
      start();
      //Then we set the frameRate to 30
      frameRate(30);
    }
  }


  /**
   Starts playback and starts the first analysis
   **/
  void start() {
    soundFile.play();
    startTime = millis();
    analyze();
  }

  /**
   Gets the output of a specific frequency band, mapped to 
   a normalized 0-1 value.
   @param Integer i the index of the band
   **/
  float getBand(int i) {
    //Constrain the index of the bands to normal values (0-numBands);
    i = constrain(i, 0, numBands);
    //Lookup the raw value in the eased spectrum
    float rawBand = spectrum[i];
    //What is the min and max for this band?
    float min = bounds[i][0];
    float max = bounds[i][1];
    //Now scale the value and return it
    return constrain(map(rawBand, min, max, 0, 1), 0, 1);
  }
  
  /**
  Extremize the output
  **/
  float getExtremeBand(int i){
    float val = getBand(i);
    float diff = min(val, 1 - val);
    boolean negative = diff == val;
    return val + (negative? -diff: diff) * 0.1;
  }

  /**
   Handles the actual analyis, should be called every frame
   **/
  void analyze() {
    //First, get the current frame's audio spectrum
    fft.analyze(bands);

    //Then add a bit of that to the eased audio spectrum
    float easeFactor = 0.1f;
    for (int i = 0; i < numBands; i++) {
      if(bands[i] == 0) {
        bands[i] = random(bounds[i][1]);
        easeFactor = 0.05;
      }
      spectrum[i] += (bands[i] - spectrum[i]) * easeFactor;
    }
  }

  /**
   Returns the bounds that have been calculated and saved to disk,
   now this file needs to be parsed into a 2D array to be read back.
   **/
  float[][] parseBounds(String[] lines) {
    //Create the 2D array
    float[][] bnds = new float[numBands][2];
    //Parse each line untill we find EOF or have parse the right amount of channels
    for (int i = 0; i < lines.length && i < numBands; i++) {
      //Split the line into its parts
      String[] parts = lines[i].split(",");
      //Now try to parse both parts
      float min = parseFloat(parts[0]);
      float max = parseFloat(parts[1]);
      //Finally assign this to the bnds array
      bnds[i] = new float[]{min, max};
    }
    //Then, lastly, return the populated array
    return bnds;
  }
}
