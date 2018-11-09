// quick and dirty scheduler
// 0 = A1
// 1 = A2 etc

boolean[] sections;

int sectionIndex = 5;
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
			sketches[0].loadClip(1065, 75, int(random(240, 720)), int(random(240, 720)), 0, sectionIndex);
			sketches[1].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				1, sectionIndex);
			sketches[2].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				2, sectionIndex);
			sketches[3].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				3, sectionIndex);
			markSection(sectionIndex);			
		}
		if (soundControl.getPosition() > 18.0) nextSection();
		break;

		case 1:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 42.0) nextSection();
		break;

		case 2:
		if (!sections[sectionIndex])
		{
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
			sketches[0].loadClip(860, 50, int(random(240, 720)), int(random(240, 720)), 0, sectionIndex);
			sketches[1].loadClip(800, 340, int(random(240, 720)), int(random(240, 720)), 0, sectionIndex);
			sketches[2].loadClip(750, 460, int(random(240, 720)), int(random(240, 720)), 0, sectionIndex);
			sketches[3].loadClip(1065, 75, int(random(240, 720)), int(random(240, 720)), 0, sectionIndex);
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 136.0) nextSection();
		break;

		case 6:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				0, sectionIndex);
			sketches[1].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				1, sectionIndex);
			sketches[2].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				2, sectionIndex);
			sketches[3].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				3, sectionIndex);
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 160.0) nextSection();
		break;

		case 7:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 178.0) nextSection();
		break;

		case 8:
		if (!sections[sectionIndex])
		{
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 195.0) nextSection();
		break;

		case 9:
		if (!sections[sectionIndex])
		{
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
