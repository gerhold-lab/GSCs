//This macro will register your stack in xy to account for some worm movement, which should facilitate tracking
//It requires as input: your original Tiff file (the output from GSCs_open_nd_4D_merge_channels_.ijm) and a corresponding
//ROI list which has the same file name as your Tiff, excpet that ".tif" is ".zip"
//The ROI list should be a point ROI at every frame that manually tracks some landmark (I use one nucleus in the proximal arm)
//and the last ROI in the ROI list should be a rectangular selection that encompasses the entire germline and which is place in frame 1

dir = getDirectory("Please choose a source directory.");
out = getDirectory("Choose an output directory.");

function GetFiles(dir) {
	list = getFileList(dir);
    for (i=0; i<list.length; i++) {
    	if (endsWith(list[i], "\\")) {
    		GetFiles(""+dir+list[i]);
    		}
    	else {
    		if (endsWith(list[i], ".tif")) {
    			path = dir+list[i];
    			register_germline(path);
    		}
    	}
    }
}

function register_germline(path) {
	roiManager("reset");
	run("Clear Results");
	modpath = replace(path, "/", "\\");
	parent = substring(modpath, 0, lastIndexOf(modpath, "\\")+1);
	print(parent);
	file_name = substring(path, lastIndexOf(path, "\\")+1, lengthOf(path));
	print(file_name);
	img_name = replace(file_name, ".tif", "");
    print(img_name);
    open(path);
	stk = getImageID();
	getVoxelSize(voxW, voxH, voxD, unit);
	Stack.getDimensions(width, height, chanels, slices, frames);
	//t = Stack.getFrameInterval();
	//2 ROI lists for each germline with corresponding ROIs for each channel
	//Files name will be ROI-C1 or C2-img_name.zip
	C1_ROIs = ""+parent+"ROI-C1-"+img_name+".zip";
	print(C1_ROIs);
	C2_ROIs = ""+parent+"ROI-C2-"+img_name+".zip";
	print(C2_ROIs);
	roiManager("open", ""+C1_ROIs+"");
	numROIs = roiManager("count");
	run("Set Measurements...", "area bounding redirect=None decimal=9");;
	roiManager("deselect");
	roiManager("measure");
	C1_BX = newArray(numROIs);
	C1_BY = newArray(numROIs);
	for (cc=0; cc<numROIs; cc++) {
		C1_BX[cc] = getResult("BX", cc);
		C1_BY[cc] = getResult("BY", cc);
	}
	run("Clear Results");
	roiManager("reset");
	roiManager("open", ""+C2_ROIs+"");
	numROIs = roiManager("count");
	run("Set Measurements...", "area bounding redirect=None decimal=9");;
	roiManager("deselect");
	roiManager("measure");
	C2_BX = newArray(numROIs);
	C2_BY = newArray(numROIs);
	for (cc=0; cc<numROIs; cc++) {
		C2_BX[cc] = getResult("BX", cc);
		C2_BY[cc] = getResult("BY", cc);
	}
	difX = newArray(numROIs);
	difY = newArray(numROIs);
	//print(numROIs);
	for (cc=0; cc<numROIs; cc++) {
		C1x = C1_BX[cc];
		C2x = C2_BX[cc];
		C1y = C1_BY[cc];
		C2y = C2_BY[cc];
		difXs = C1x-C2x;
		difYs = C1y-C2y;
		difX[cc] = difXs;
		difY[cc] = difYs;
	}
	Array.getStatistics(difX, min, max, mean, stdDev);
	corrX = mean;
	corrX = round(corrX/voxW);
	print(corrX);
	Array.getStatistics(difY, min, max, mean, stdDev);
	corrY = mean;
	corrY = round(corrY/voxW);
	print(corrY);
	padX = 2*corrX+width;
	padY = 2*corrY+height;
	selectImage(stk);
	rename("boo");
  	run("Canvas Size...", "width="+padX+" height="+padY+" position=Center zero");
	//Need to adjust positions to accomodate canvas resize
	run("Split Channels");
	selectWindow("C1-boo");
	makeRectangle(corrX, corrY, width, height);
	run("Duplicate...", "duplicate");
	C1dup = getImageID();
	selectWindow("C1-boo");
	close();
	selectImage(C1dup);
	rename("C1-boo");
	selectWindow("C2-boo");
	makeRectangle(0, 0, width, height);
	run("Duplicate...", "duplicate");
	C2dup = getImageID();
	selectWindow("C2-boo");
	close();
	selectImage(C2dup);
	rename("C2-boo");
	run("Merge Channels...", "c1=C1-boo c2=C2-boo create");
	saveAs("Tiff", ""+out+""+img_name+"_reg.tif");
	close();
	roiManager("reset");
	run("Clear Results");
}

setBatchMode(true);
GetFiles(dir);
setBatchMode(false);