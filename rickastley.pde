import java.io.File;
import java.awt.MouseInfo;
import java.awt.Point;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;

color CORAL = #F64740;
color MIDNIGHT = #0D3B66;
color RAISIN = #291F1E;

int counter = 0;
int maxSketches = 5;
int numClips = 0;
Ricklet[] sketches;

Point mouse;
boolean clicked = false;

SoundControl soundControl;

void setup()
{
	surface.setTitle("controlapp");
	surface.setSize(720, 240);
  	surface.setVisible(false);
	surface.setLocation(displayWidth - width, displayHeight - height);
	background(CORAL);
	stroke(255);

	//Start loading the Sound
	soundControl = new SoundControl(this);

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
	initScheduler();
  	frameRate(30);
}

void draw()
{	
	background(CORAL);

	// update ricklets
	for (int i=0; i<maxSketches; i++)
	{
		float pulse = soundControl.getChannel(sketches[i].getBand());
		float t = soundControl.getPosition() * 6.0;

		//irregularity
		int d = (i%2>0) ? 1 : 0;
		float sincos = (i%3<1) ? sin(t) : cos(t);
		int shift = (int)(pow(sincos,5)*2.0);

		sketches[i].setPulse(pulse);
		if (!soundControl.waiting)
			sketches[i].setLocationProps(sketches[i].pos.x + shift*d, sketches[i].pos.y + shift*(1-d));
	}
	mouse = MouseInfo.getPointerInfo().getLocation();
	text("(" + mouse.x + ", " + mouse.y + ")", 20, 40);
	scheduler();
	soundControl.update();
}

void mouseClicked() 
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

	int band = 0;
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

	void setup()
	{
		surface.setTitle(name);
		surface.setResizable(true);
		surface.setSize(w, h);
		surface.setLocation(pos.x, pos.y);
		background(RAISIN);
		stroke(255);
		imageMode(CENTER);
    	frameRate(30);
	}

	void draw()
	{
		if (imageLoader == null || imageLoader.isAlive()) return;
		if (!clipsLoaded) return;

		if (true)
		{
			surface.setSize(w, h);
			surface.setLocation(pos.x, pos.y);
			wasUpdated = false;
		}
    	if(soundControl.waiting) return;

		float p = constrain(pulse, 0, 1);
		int f = ceil(map(p, 0, 1, 1, frames.length-1));
		if (!imageLoader.isAlive())
		{
			background(RAISIN);
			if (frames != null && frames[f] != null) 
				image(frames[f], width/2, height/2, width, height);
			//text("id:"+id+" f:"+f, 20, 40);
		}
	}

	public void loadClip(int _x, int _y, int _w, int _h, int sectionIndex, int _band) 
	{
		((SmoothCanvas)surface.getNative()).getFrame().toFront();
		setLocationProps(_x, _y);
		setSizeProps(_w, _h);
		if (imageLoader == null || !imageLoader.isAlive())
		{
			imageLoader = new ImageLoaderThread(this, id, sectionIndex);
			imageLoader.start();
		}
		band = _band;
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
	public int getBand() { return band; }	
	public void setPulse(float val) { pulse = val; }
	public void setLocationProps(int _x, int _y) { pos.x=_x; pos.y=_y; wasUpdated=true; }
	public void setSizeProps(int _w, int _h) { w=_w; h=_h; wasUpdated=true; }
	public void setFrames(PImage[] _frames) { frames = _frames; }
	public void setVisibility(boolean b) { surface.setVisible(b); }
	public PImage[] getFrames() { return frames; }
}  
