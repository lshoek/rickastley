import java.io.File;
import java.awt.MouseInfo;
import java.awt.Point;

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
	surface.setLocation(displayWidth - width, displayHeight - height);
	background(CORAL);
	stroke(255);

	// init sections
	sections = new boolean[numSections];
	for (int i=0; i<numSections; i++)
		sections[i] = false;

	//Start loading the Sound
	soundControl = new SoundControl(this);

	File dir = new File(sketchPath("data"));
	numClips = dir.listFiles().length;

	sketches = new Ricklet[maxSketches];
	for (int i=0; i<maxSketches; i++)
	{
		sketches[i] = new Ricklet(this, 
			int(random(0, displayWidth-720)), 
			int(random(0, displayHeight-720)), 
			int(random(240, 720)), 
			int(random(240, 720)), i);
	}
	// run sketches
	for (int i=0; i<maxSketches; i++)
	{
		runSketch(new String[] { 
			"--display=1", 
			"--sketch-path=" + sketchPath(), "" }, 
			sketches[i]);
	}
}

void draw()
{	
	background(CORAL);
	float pulse = soundControl.getPosition();

	// update ricklets
	for (int i=0; i<maxSketches; i++)
	{
		// irregularity
		int d = (i%2>0) ? 1 : 0;
		float sincos = (i%3<1) ? sin(pulse) : cos(pulse);
		int shift = (int)(pow(sincos,5)*5.5);

		sketches[i].setPulse(pulse);
		//sketches[i].setLocationProps(sketches[i].x + shift*d, sketches[i].y + shift*(1-d));
	}
	mouse = MouseInfo.getPointerInfo().getLocation();
	text("(" + mouse.x + ", " + mouse.y + ")", 20, 40);
	scheduler();
	soundControl.update();
}

Point toNative(int a, int b)
{
	return new Point(
		int(map(a, 0, 1920, 0, displayWidth)), 
		int(map(a, 0, 1080, 0, displayHeight)));
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
	    imageLoader = new ImageLoaderThread(this, 1);
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
	}

	void draw()
	{
		if (imageLoader.isAlive()) return;
		if (!clipsLoaded) return;

		if (mousePressed) setPulse(map(mouseX, 0, width, 0, 1));
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
			image(frames[f], width/2, height/2);
			text("id:"+id+" f:"+f, 20, 40);
		}
	}

	public void loadClip(int _x, int _y, int _w, int _h, int index) 
	{ 
		setLocationProps(_x, _y);
		setSizeProps(_w, _h);
		if (imageLoader == null || !imageLoader.isAlive())
		{
			imageLoader = new ImageLoaderThread(this, index);
			imageLoader.start();
		}
		clipsLoaded = true;
	}

	class ImageLoaderThread extends Thread
	{
		Ricklet parent;
		int id;

		public ImageLoaderThread(Ricklet _parent, int _id)
		{
			parent = _parent;
			id = _id;
		}

		public void run()
		{
			if (frameLock) return;
			frameLock = true;

			File dir = new File(sketchPath("data\\" + str(id%numClips+1)));
			File[] files = dir.listFiles();
			surface.setTitle("vid: " + dir.getName());

			frames = new PImage[files.length];
			for (int i=0; i<files.length; i++)
				frames[i] = loadImage(dir + "\\" + files[i].getName());

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
