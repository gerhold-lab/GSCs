dir = getDirectory("Please choose a source directory");

//File.makeDirectory(""+dir+"\\cells_trackmateROIs\\"); //PC
File.makeDirectory(""+dir+"/cells_trackmateROIs/"); //Mac
ROIs = ""+dir+"/cells_trackmateROIs/";
//File.makeDirectory(""+dir+"\\cells_cropped\\"); //PC
File.makeDirectory(""+dir+"/cells_cropped/"); //Mac
Tiffs = ""+dir+"/cells_cropped/";

//Dialog.create("voxel size in um?");
Dialog.addNumber("depth:", 0.5);
Dialog.addNumber("width/height:", 0.1801588);
Dialog.show();
z = Dialog.getNumber();
xy = Dialog.getNumber();

function GetFiles(dir) {
	list = getFileList(dir); 
    for (i=0; i<list.length; i++) {
    	if (endsWith(list[i], "/")) {
    		GetFiles(""+dir+list[i]);
    		}
    	else {
    		if (endsWith(list[i], "coords.txt")) {
    			path = dir+list[i];
    			print(path);
    			getROIs(path);
    		}
    	}
    }
}

function getROIs(path) {
	run("Clear Results");
	roiManager("Reset");
	run("Results... ", "open=["+path+"]");
	corresp = replace(path, "_coords.txt", ".tif");
	print(corresp);
	open(corresp);
	boo = getImageID();
	cellindx = replace(path, "_coords.txt", "_cellIDs.txt");
	string = File.openAsString(cellindx);
	//print(string);
	cells = split(string,"\n");
	//Array.show(cells);
	foo = getTitle();
	name = replace(foo, ".tif", "");
	//File.makeDirectory(""+ROIs+"\\"+name+"\\"); //PC
	//File.makeDirectory(""+Tiffs+"\\"+name+"\\"); //PC
	File.makeDirectory(""+ROIs+"/"+name+"/"); //Mac
	File.makeDirectory(""+Tiffs+"/"+name+"/"); //Mac
	out1 = ""+ROIs+"/"+name+"/";
	out2 = ""+Tiffs+"/"+name+"/";
	
	//make array out of "Cell" column from Results table
	cellIDs = newArray(nResults);
	for (i=0; i<nResults; i++) {
		cellIDs[i] = getResultString("Cell",i);
	}
	//Array.show(cellIDs);

	for (j=0; j<cells.length; j++) {
		cell = cells[j];
		//counts the number of times cell appears in array cellIDs (i.e number of frames where cell was tracked); occurence++ advances the value of occurence 
		//by increments of 1
		occurence = 0;
		for (i=0; i<lengthOf(cellIDs); i++) {
			if(cellIDs[i] == cell) {
				occurence++;
			}
		}
		//print(occurence);

		if (occurence > 0) {
			rownums = newArray(occurence); //new array with length equal to number of times cell appears in cellIDs array
			occurence = 0;
			//loops through cellIDs array (list of all cell labels from Matlab output), if Cell = cell, adds loop number to rownum array. 
			//rownum array ends up as index for where (row number) in Matlab output each cell appears - i.e. if Cell10 coordinates are found
			//from row 1-73 rownums = [1, 2, 3... 73] 
			for (i=0; i<lengthOf(cellIDs); i++) {
				if(cellIDs[i] == cell) {
					rownums[occurence] = i;
					occurence++;
				}
			}
			//Array.getStatistics(rownums, min, max, mean, stdDev);
			//Array.show(rownums);
			//allows 'for' loop to be initialized at the first row number with measurements for given cell and runs loop until i = last row number
			for (i=0; i<rownums.length; i++) {
				row = rownums[i];
				frame = getResult("Frame", row);
				//Trackmate indexes frames to 0 rather than 1, but frames were corrected in Matlab, so skip
      			//frame = frame+1;
				x = getResult("X", row);
      			y = getResult("Y", row);
      			slice = getResult("Z", row);
      			//x and y coordinates of spindle midpoint should be in calibrated (um) values - convert to pixel values
      			x = x/xy;
      			y = y/xy;
      			//z values need to be corrected back to slice values - Matlab uses Trackmate output with z given in um
      			//subpixel resolution is used --> z values will need to be rounded
      			slice = round(slice/z+1);
      			//define size in pixels of recangular area to be cropped
      			size = 70;
      			makeRectangle(x-size/2, y-size/2, size, size);
      			//Overlay.addSelection; don't need this step?
      			Stack.setPosition(1, slice, frame);
      			// Add to the ROI manager.
      			roiManager("Add");
      		}
			roiManager("Save", ""+out1+""+name+"_"+cell+".zip");

			//number of slices to project = S*2+1
			S = 7;
			numROIs = roiManager("count");
			for (i=0; i<numROIs; i++) {
				selectImage(boo);
				Stack.getDimensions(width, height, chanels, slices, frames);
				roiManager("select", i);
				Stack.getPosition(Ch, Sl, Fr);
				if (Fr < 10) {
					title = "frame_00"+Fr+"";
				}
				if (Fr >= 10 && Fr < 100) {
					title = "frame_0"+Fr+""; 
				}
				if (Fr >= 100) {
					title = "frame_"+Fr+""; 
				}
				top = Sl - S;
				bottom = Sl + S;
				if (top < 1) {
					top = 1;
				}
				if (bottom > slices) {
					bottom = slices;
				}
				run("Duplicate...", "duplicate title="+title+" channels=2 slices="+top+"-"+bottom+" frames="+Fr+"");
				joe = getImageID();
				run("Z Project...", "projection=[Max Intensity]");
				//gus = getImageID();
				selectImage(joe);
				close();
			}
			selectImage(boo);
			close();
			run("Concatenate...", "all_open title=[Concatenated Stacks]");
			saveAs("Tiff", ""+out2+""+name+"_"+cell+".tif");
			close();
			run("Close All");
		}
		open(corresp);
	}
}

setBatchMode(true);
GetFiles(dir);
setBatchMode(false);