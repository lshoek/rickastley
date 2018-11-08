// quick and dirty scheduler

int numSections = 8;
boolean[] sections;
int sectionIndex = 0;

void scheduler()
{
	switch (sectionIndex) 
	{
		case 0:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				0);
			sketches[1].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				1);
			sketches[2].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				2);
			sketches[3].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				3);
			sketches[4].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				4);
			markSection(sectionIndex);			
		}
		sectionIndex++;
		break;

		case 1:
		if (!sections[sectionIndex])
		{
			sketches[0].loadClip(
				int(random(0, displayWidth-720)), 
				int(random(0, displayHeight-720)), 
				int(random(240, 720)), 
				int(random(240, 720)), 
				0);
			markSection(sectionIndex);
		}
		if (soundControl.getPosition() > 10.0) sectionIndex++;
		break;
		default:
		break;
	}
}

void markSection(int index)
{
	sections[index] = true;
	println("started composition #" + index);
}