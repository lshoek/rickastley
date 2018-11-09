import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.File; 
import java.awt.MouseInfo; 
import java.awt.Point; 
import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class rickastley extends PApplet {





int CORAL = 0xffF64740;
int MIDNIGHT = 0xff0D3B66;
int RAISIN = 0xff291F1E;

int counter = 0;
int maxSketches = 4;
int numClips = 0;
Ricklet[] sketches;

Point mouse;
boolean clicked = false;

SoundControl soundControl;

public void setup()
{
	surface.setTitle("controlapp");
	surface.setSize(720, 240);
	surface.setLocation(displayWidth - width, displayHeight - height);
	background(CORAL);
	stroke(255);

	//Start loading the Sound
	soundControl = new SoundControl(this);

	initScheduler();

	File dir = new File(sketchPath("data"));
	numClips = dir.listFiles().length;

	sketches = new Ricklet[maxSketches];
	for (int i=0; i<maxSketches; i++)
		sketches[i] = new Ricklet(this, 0, 0, 0, 0, i);

	// run sketches
	for (int i=0; i<maxSketches; i++)
	{
		runSketch(new String[] { 
			"--display=1", 
			"--sketch-path=" + sketchPath(), "" }, 
			sketches[i]);
	}
}

public void draw()
{	
	background(CORAL);

	// update ricklets
	for (int i=0; i<maxSketches; i++)
	{
		//irregularity
		//int d = (i%2>0) ? 1 : 0;
		//float sincos = (i%3<1) ? sin(pulse) : cos(pulse);
		//int shift = (int)(pow(sincos,5)*5.5);

		float pulse = soundControl.getChannel(i);
		sketches[i].setPulse(pulse);
		//sketches[i].setLocationProps(sketches[i].x + shift*d, sketches[i].y + shift*(1-d));
	}
	mouse = MouseInfo.getPointerInfo().getLocation();
	text("(" + mouse.x + ", " + mouse.y + ")", 20, 40);
	scheduler();
	soundControl.update();
}

// Point toNative(int a, int b)
// {
// 	return new Point(
// 		int(map(a, 0, 1920, 0, displayWidth)), 
// 		int(map(a, 0, 1080, 0, displayHeight)));
// }

public void mouseClicked() 
{
	clicked = true;
}

class Ricklet extends PApplet 
{
	PApplet parent;
	PImage[] frames;
	ImageLoaderThread imageLoader;
	
	String name;
	public Point pos;
	public int w, h, id;

	float pulse = 0;
	boolean wasUpdated = false;
	boolean frameLock = false;
	boolean clipsLoaded = false;

	public Ricklet(PApplet _parent, int _x, int _y, int _w, int _h, int _id)
  	{
	    super();
	    parent =_parent;
	    pos = new Point(_x, _y);
	    setSizeProps(_w, _h);
	    id = _id;
  	}

	public void setup()
	{
		surface.setTitle(name);
		surface.setResizable(true);
		surface.setSize(w, h);
		surface.setLocation(pos.x, pos.y);
		background(RAISIN);
		stroke(255);
		imageMode(CENTER);
	}

	public void draw()
	{
		if (imageLoader == null || imageLoader.isAlive()) return;
		if (!clipsLoaded) return;

		if (wasUpdated)
		{
			surface.setSize(w, h);
			surface.setLocation(pos.x, pos.y);
			wasUpdated = false;
		}
		float p = constrain(pulse, 0, 1);
		int f = ceil(map(p, 0, 1, 1, frames.length-1));
		if (!imageLoader.isAlive())
		{
			background(RAISIN);
			image(frames[f], width/2, height/2, width, height);
			text("id:"+id+" f:"+f, 20, 40);
		}
	}

	public void loadClip(int _x, int _y, int _w, int _h, int index, int sectionIndex) 
	{ 
		setLocationProps(_x, _y);
		setSizeProps(_w, _h);
		if (imageLoader == null || !imageLoader.isAlive())
		{
			imageLoader = new ImageLoaderThread(this, id, sectionIndex);
			imageLoader.start();
		}
		clipsLoaded = true;
	}

	class ImageLoaderThread extends Thread
	{
		Ricklet parent;
		int sectionIndex;
		int id;

		public ImageLoaderThread(Ricklet _parent, int _id, int _sectionIndex)
		{
			parent = _parent;
			sectionIndex = _sectionIndex;
			id = _id;
		}

		public void run()
		{
			if (frameLock) return;
			frameLock = true;

			File dir = new File(sketchPath("data/" + str(sectionIndex+1) + "/A" + (id+1)));
			println(dir.getAbsolutePath());
			File[] files = dir.listFiles();
			surface.setTitle("vid: " + dir.getName());

			frames = new PImage[files.length];
			for (int i=0; i<files.length; i++)
				frames[i] = loadImage(dir + "/" + files[i].getName());

			frameLock = false;
		}
	}
	public int getId() { return id; }
	public void setPulse(float val) { pulse = val; }
	public void setLocationProps(int _x, int _y) { pos.x=_x; pos.y=_y; wasUpdated=true; }
	public void setSizeProps(int _w, int _h) { w=_w; h=_h; wasUpdated=true; }
	public void setFrames(PImage[] _frames) { frames = _frames; }
	public void setVisibility(boolean b) { surface.setVisible(b); }
	public PImage[] getFrames() { return frames; }
}  

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
  public float getChannel(int i) {
    if (i == 0) return getBand(0);
    else if (i == 1) return getBand(1);
    else if (i == 2) return getBand(5);
    else if (i == 3) return getBand(7);
    else if (i == 4) return getBand(28);
    else return 0f;
  }

  /**
   Updates SoundControl, forwards its calls to checkWaiting
   or analyze, depending on the circumstances
   **/
  public void update() {
    if (waiting) {
      checkWaiting();
    } else {
      analyze();
    }
  }

  /**
   Returns the position of the playback in seconds
   **/
  public float getPosition() {
    return (millis() - startTime) / 1000f;
  }

  /**
   Will check if we can start yet, if so we do
   **/
  public void checkWaiting() {
    String[] lines = loadStrings("https://www.interwing.nl/meta-media/start.txt");
    lines[0] = lines[0].replaceAll("\n", "").trim();
    if (lines[0].equals("1")) {
      //We're no longer waiting, we can start all applications
      waiting = false;
      //Now we start
      start();
      //Then we set the frameRate to 30
      frameRate(60);
    }
  }


  /**
   Starts playback and starts the first analysis
   **/
  public void start() {
    soundFile.play();
    startTime = millis();
    analyze();
  }

  /**
   Gets the output of a specific frequency band, mapped to 
   a normalized 0-1 value.
   @param Integer i the index of the band
   **/
  public float getBand(int i) {
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
   Handles the actual analyis, should be called every frame
   **/
  public void analyze() {
    //First, get the current frame's audio spectrum
    fft.analyze(bands);

    //Then add a bit of that to the eased audio spectrum
    for (int i = 0; i < numBands; i++) {
      spectrum[i] += (bands[i] - spectrum[i]) * 0.1f;
    }
  }

  /**
   Returns the bounds that have been calculated and saved to disk,
   now this file needs to be parsed into a 2D array to be read back.
   **/
  public float[][] parseBounds(String[] lines) {
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
// quick and dirty scheduler
// 0 = A1
// 1 = A2 etc

boolean[] sections;

int sectionIndex = 5;
int numSections = 10;

boolean debugLock = true;

public void initScheduler()
{
	sections = new boolean[numSections];
	for (int i=0; i<numSections; i++)
		sections[i] = false;
}

public void scheduler()
{
	switch (sectionIndex) 
	{
		case 0:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(1065, 75, PApplet.parseInt(random(240, 720)), PApplet.parseInt(random(240, 720)), 0, sectionIndex);
			sketches[1].loadClip(
				PApplet.parseInt(random(0, displayWidth-720)), 
				PApplet.parseInt(random(0, displayHeight-720)), 
				PApplet.parseInt(random(240, 720)), 
				PApplet.parseInt(random(240, 720)), 
				1, sectionIndex);
			sketches[2].loadClip(
				PApplet.parseInt(random(0, displayWidth-720)), 
				PApplet.parseInt(random(0, displayHeight-720)), 
				PApplet.parseInt(random(240, 720)), 
				PApplet.parseInt(random(240, 720)), 
				2, sectionIndex);
			sketches[3].loadClip(
				PApplet.parseInt(random(0, displayWidth-720)), 
				PApplet.parseInt(random(0, displayHeight-720)), 
				PApplet.parseInt(random(240, 720)), 
				PApplet.parseInt(random(240, 720)), 
				3, sectionIndex);
			markSection(sectionIndex);			
		}
		if (soundControl.getPosition() > 18.0f) nextSection();
		break;

		case 1:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 42.0f) nextSection();
		break;

		case 2:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 60.0f) nextSection();
		break;

		case 3:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 84.0f) nextSection();
		break;

		case 4:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 119.0f) nextSection();
		break;

		case 5:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(860, 50, PApplet.parseInt(random(240, 720)), PApplet.parseInt(random(240, 720)), 0, sectionIndex);
			sketches[1].loadClip(800, 340, PApplet.parseInt(random(240, 720)), PApplet.parseInt(random(240, 720)), 0, sectionIndex);
			sketches[2].loadClip(750, 460, PApplet.parseInt(random(240, 720)), PApplet.parseInt(random(240, 720)), 0, sectionIndex);
			sketches[3].loadClip(1065, 75, PApplet.parseInt(random(240, 720)), PApplet.parseInt(random(240, 720)), 0, sectionIndex);
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 136.0f) nextSection();
		break;

		case 6:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(
				PApplet.parseInt(random(0, displayWidth-720)), 
				PApplet.parseInt(random(0, displayHeight-720)), 
				PApplet.parseInt(random(240, 720)), 
				PApplet.parseInt(random(240, 720)), 
				0, sectionIndex);
			sketches[1].loadClip(
				PApplet.parseInt(random(0, displayWidth-720)), 
				PApplet.parseInt(random(0, displayHeight-720)), 
				PApplet.parseInt(random(240, 720)), 
				PApplet.parseInt(random(240, 720)), 
				1, sectionIndex);
			sketches[2].loadClip(
				PApplet.parseInt(random(0, displayWidth-720)), 
				PApplet.parseInt(random(0, displayHeight-720)), 
				PApplet.parseInt(random(240, 720)), 
				PApplet.parseInt(random(240, 720)), 
				2, sectionIndex);
			sketches[3].loadClip(
				PApplet.parseInt(random(0, displayWidth-720)), 
				PApplet.parseInt(random(0, displayHeight-720)), 
				PApplet.parseInt(random(240, 720)), 
				PApplet.parseInt(random(240, 720)), 
				3, sectionIndex);
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 160.0f) nextSection();
		break;

		case 7:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 178.0f) nextSection();
		break;

		case 8:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 195.0f) nextSection();
		break;

		case 9:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 317.0f) nextSection();
		break;

		default:
		break;
	}
}

public void nextSection()
{
	if (debugLock) return;
	else sectionIndex++;
}

public void markSection(int index)
{
	sections[index] = true;
	println("started composition #" + index);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "rickastley" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
