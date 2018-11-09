// quick and dirty scheduler
// 0 = A1
// 1 = A2 etc

boolean[] sections;

int sectionIndex = 2;
int numSections = 10;

boolean debugLock = true;

void initScheduler()
{
	sections = new boolean[numSections];
	for (int i=0; i<numSections; i++)
		sections[i] = false;
}

void scheduler()
{
	switch (sectionIndex) 
	{
		case 0:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(500, 650, 400, 320, sectionIndex);			
			sketches[3].loadClip(925, 400, 300, 600, sectionIndex); 
			sketches[2].loadClip(600, 300, 600, 400, sectionIndex); 
			sketches[1].loadClip(640, 0, 400, 400, sectionIndex); 
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 18.0) nextSection();
		break;

		case 1:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(520, 560, 600, 420, sectionIndex);			
			sketches[3].loadClip(875, 150, 500, 500, sectionIndex); 
			sketches[2].loadClip(500, 300, 400, 400, sectionIndex); 
			sketches[1].loadClip(640, 25, 450, 300, sectionIndex); 
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 42.0) nextSection();
		break;

		case 2:
		if (!sections[sectionIndex])
		{
			sketches[2].loadClip(500, 320, 400, 240, sectionIndex);			
			sketches[3].loadClip(480, 540, 500, 240, sectionIndex); 
			sketches[0].loadClip(460, 760, 400, 240, sectionIndex);

			sketches[1].loadClip(640, 25, 320, 240, sectionIndex); 
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 60.0) nextSection();
		break;

		case 3:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 84.0) nextSection();
		break;

		case 4:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 119.0) nextSection();
		break;

		case 5:
		if (!sections[sectionIndex])
		{
			sketches[3].loadClip(700, 600, 600, 400, sectionIndex);
			sketches[1].loadClip(900, 150, 600, 400, sectionIndex);
			sketches[2].loadClip(750, 420, 400, 400, sectionIndex);
			sketches[0].loadClip(1065, 75, 320, 320, sectionIndex);
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 136.0) nextSection();
		break;

		case 6:
		if (!sections[sectionIndex])
		{
			sketches[3].setVisibility(false);
			sketches[2].loadClip(700, 550, 950, 400, sectionIndex);
			sketches[1].loadClip(800, 250, 600, 400, sectionIndex);
			sketches[0].loadClip(1065, 75, 320, 320, sectionIndex);
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 160.0) nextSection();
		break;

		case 7:
		if (!sections[sectionIndex])
		{
			sketches[3].setVisibility(true);
			sketches[4].setVisibility(true);

			sketches[4].loadClip(1100, 250, 500, 400, sectionIndex); // leftarm
			sketches[3].loadClip(400, 600, 900, 400, sectionIndex); // legs
			sketches[2].loadClip(600, 250, 600, 400, sectionIndex); // body
			sketches[1].loadClip(250, 250, 600, 400, sectionIndex); // rightarm
			sketches[0].loadClip(640, 100, 400, 320, sectionIndex); // head
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 178.0) nextSection();
		break;

		case 8:
		if (!sections[sectionIndex])
		{
			sketches[4].setVisibility(false);

			sketches[3].loadClip(520, 600, 800, 400, sectionIndex);
			sketches[2].loadClip(1100, 220, 400, 400, sectionIndex);	
			sketches[1].loadClip(500, 100, 600, 400, sectionIndex);
			sketches[0].loadClip(550, 500, 640, 240, sectionIndex);			
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 195.0) nextSection();
		break;

		case 9:
		if (!sections[sectionIndex])
		{
			sketches[4].setVisibility(true);

			sketches[4].loadClip(600, 600, 600, 500, sectionIndex);
			sketches[3].loadClip(400, 300, 900, 300, sectionIndex);	
			sketches[2].loadClip(1150, 350, 500, 400, sectionIndex);
			sketches[1].loadClip(250, 250, 400, 600, sectionIndex);					
			sketches[0].loadClip(640, 75, 400, 400, sectionIndex); 
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 317.0) nextSection();
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