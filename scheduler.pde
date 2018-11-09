// quick and dirty scheduler
// 0 = A1
// 1 = A2 etc

boolean[] sections;

int sectionIndex = 0;
int numSections = 10;

boolean debugLock = false;

void initScheduler()
{
	sections = new boolean[numSections];
	for (int i=0; i<numSections; i++)
		sections[i] = false;
}

void scheduler()
{
	float time = soundControl.getPosition() + 10.0;
	switch (sectionIndex) 
	{
		case 0:
		if (!sections[sectionIndex])
		{
			sketches[4].setVisibility(false);

			sketches[0].loadClip(500, 650, 400, 320, sectionIndex, 2);	//feet		
			sketches[3].loadClip(925, 400, 300, 600, sectionIndex, 0); //leg
			sketches[2].loadClip(600, 300, 600, 400, sectionIndex, 3); //hands
			sketches[1].loadClip(640, 0, 400, 400, sectionIndex, 2); //head
			markSection(sectionIndex);
		}
		if (time > 18.0) nextSection();
		break;

		case 1:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(520, 560, 600, 420, sectionIndex, 2); //legs			
			sketches[3].loadClip(875, 150, 500, 500, sectionIndex, 4); //rightarm
			sketches[2].loadClip(500, 300, 400, 400, sectionIndex, 2); //leftarm
			sketches[1].loadClip(640, 25, 450, 300, sectionIndex, 2); //head
			markSection(sectionIndex);
		}
		if (time > 42.0) nextSection();
		break;

		case 2:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(640, 720, 320, 240, sectionIndex, 2);	//legs
			sketches[3].loadClip(560, 500, 640, 240, sectionIndex, 0); //skirt
			sketches[2].loadClip(580, 260, 480, 240, sectionIndex, 4);	//hands	
			sketches[1].loadClip(640, 25, 320, 240, sectionIndex, 4); //head
			markSection(sectionIndex);
		}
		if (time > 60.0) nextSection();
		break;

		case 3:
		if (!sections[sectionIndex])
		{
			sketches[3].loadClip(960, 250, 320, 600, sectionIndex, 2); //body		
			sketches[0].loadClip(680, 600, 580, 360, sectionIndex, 2); //legs				
			sketches[2].loadClip(615, 360, 480, 240, sectionIndex, 2);	//leftarm	
			sketches[1].loadClip(780, 50, 320, 320, sectionIndex, 4); //head			
			markSection(sectionIndex);
		}
		if (time > 84.0) nextSection();
		break;

		case 4:
		if (!sections[sectionIndex])
		{	
			sketches[0].loadClip(640, 560, 420, 480, sectionIndex, 4); //feet				
			sketches[3].loadClip(700, 200, 480, 600, sectionIndex, 4); //body
			sketches[2].loadClip(860, 300, 320, 240, sectionIndex, 0);	//arms					
			sketches[1].loadClip(780, -20, 320, 320, sectionIndex, 1); //head			
			markSection(sectionIndex);
		}
		if (time > 119.0) nextSection();
		break;

		case 5:
		if (!sections[sectionIndex])
		{
			sketches[3].loadClip(700, 600, 600, 400, sectionIndex, 4); //legs
			sketches[1].loadClip(900, 150, 600, 400, sectionIndex, 4); //body shadow
			sketches[2].loadClip(750, 420, 400, 400, sectionIndex, 2); //arms
			sketches[0].loadClip(1065, 75, 320, 320, sectionIndex, 1); //head
			markSection(sectionIndex);
		}
		if (time > 136.0) nextSection();
		break;

		case 6:
		if (!sections[sectionIndex])
		{
			sketches[3].setVisibility(false);
			sketches[2].loadClip(700, 550, 950, 400, sectionIndex, 4); //legs
			sketches[1].loadClip(800, 250, 600, 400, sectionIndex, 2); //body
			sketches[0].loadClip(1065, 75, 320, 320, sectionIndex, 3); //head
			markSection(sectionIndex);
		}
		if (time > 160.0) nextSection();
		break;

		case 7:
		if (!sections[sectionIndex])
		{
			sketches[4].setVisibility(true);

			sketches[4].loadClip(1100, 250, 500, 400, sectionIndex, 4); // leftarm
			sketches[3].loadClip(400, 600, 900, 400, sectionIndex, 2); // legs
			sketches[2].loadClip(600, 250, 600, 400, sectionIndex, 2); // body
			sketches[1].loadClip(250, 250, 600, 400, sectionIndex, 4); // rightarm
			sketches[0].loadClip(640, 100, 400, 320, sectionIndex, 4); // head
			markSection(sectionIndex);
		}
		if (time > 178.0) nextSection();
		break;

		case 8:
		if (!sections[sectionIndex])
		{
			sketches[4].setVisibility(false);

			sketches[3].loadClip(520, 600, 800, 400, sectionIndex, 2); //body
			sketches[2].loadClip(1100, 220, 400, 400, sectionIndex, 2);	//rightear
			sketches[1].loadClip(500, 100, 600, 400, sectionIndex, 4);//eyes
			sketches[0].loadClip(550, 500, 640, 240, sectionIndex, 4);	//mouth		
			markSection(sectionIndex);
		}
		if (time > 195.0) nextSection();
		break;

		case 9:
		if (!sections[sectionIndex])
		{
			sketches[4].setVisibility(true);

			sketches[4].loadClip(600, 600, 600, 500, sectionIndex, 3); //legs
			sketches[3].loadClip(400, 300, 900, 300, sectionIndex, 2);	//body
			sketches[2].loadClip(1150, 350, 500, 400, sectionIndex, 4); //rightarm
			sketches[1].loadClip(250, 250, 400, 600, sectionIndex, 4); //leftarm					
			sketches[0].loadClip(640, 75, 400, 400, sectionIndex, 4); //face
			markSection(sectionIndex);
		}
		if (time > 317.0) nextSection();
		break;

		default:
		break;
	}
}

void nextSection()
{
	if (debugLock) return;
	else sectionIndex++;
}

void markSection(int index)
{
	sections[index] = true;
	println("started composition #" + index);
}
