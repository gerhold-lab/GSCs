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
	file_name = substring(path, lastIndexOf(path, "\\")+1, lengthOf(path));
	print(file_name);
	img_name = replace(file_name, ".tif", "");
    print(img_name);
    open(path);
	stk = getImageID();
	getVoxelSize(voxW, voxH, voxD, unit);
	Stack.getDimensions(width, height, chanels, slices, frames);
	t = Stack.getFrameInterval();
	//ROI list for each germline should be 1 pt ROI per frame tracking a prominent cell and 1 rectangular ROI placed in frame 1, which
	//encompasses the whole germline
	RegROIs = replace(path,".tif", ".zip");
	roiManager("open", ""+RegROIs+"");
	numROIs = roiManager("count");
	if (numROIs != frames+1) {
		print("Error in ROI list - total number of ROIs is incorrect. Check ROI list for "+file_name+"");
	}
	else {
		roiManager("select", numROIs-1);
		Stack.getPosition(Ch, Sl, lastROI);
		if (lastROI != 1) {
			print("Last ROI is not in frame 1. Check ROI list for "+file_name+"");
		}
		else {
			Frames = newArray(numROIs-1);
			for (cc=0; cc<numROIs-1; cc++) {
				roiManager("select", cc);
				Stack.getPosition(Ch, Sl, Fr);
				Frames[cc] = Fr;
			}
			Difs = newArray(Frames.length-1);
			for (cc=0; cc<Frames.length-1; cc++) {
				Difs[cc] = Frames[cc+1]-Frames[cc];
			}
			occurence = 0;
			for (cc=0; cc<Difs.length; cc++) {
				if (Difs[cc] != 1) {
					occurence++;
				}
			}
			if (occurence > 0) {
				print("Error in ROI list - missing or duplicated frames. Check ROI list for "+file_name+"");
			}
			else {
				run("Set Measurements...", "centroid bounding stack redirect=None decimal=9");
				roiManager("deselect");
				roiManager("measure");
				cenX = newArray(nResults-1);
				cenY = newArray(nResults-1);
				for (dd=0; dd<nResults-1; dd++) {
					boo = getResult("X", dd);
					cenX[dd] = round(boo/voxW);
					boo = getResult("Y", dd);				
					cenY[dd] = round(boo/voxW);
				}
				//Array.show(cenX);
				//Array.show(cenY);
				Xshift = newArray(cenX.length);
				Yshift = newArray(cenY.length);
				for (dd=0; dd<cenX.length; dd++) {
					Xshift[dd] = cenX[dd]-cenX[0];
					Yshift[dd] = cenY[dd]-cenY[0];
				}
				//Array.show(Xshift);
				//Array.show(Yshift);
				run("Set Measurements...", "bounding stack redirect=None decimal=9");
				run("Clear Results");
				roiManager("select", numROIs-1);
				roiManager("measure");
				BBx = getResult("BX", 0);
				BBy = getResult("BY", 0);
				BBw = getResult("Width", 0);
				BBh = getResult("Height", 0);
				BBx = round(BBx/voxW);
				BBy = round(BBy/voxW);
				BBw = round(BBw/voxW);
				BBh = round(BBh/voxW);
				roiManager("reset");
				print(BBx, BBy, BBw, BBh);

				Array.getStatistics(Xshift, min, max, mean, stdDev);
				pad1 = abs(min);
				pad2 = max;
				padX = maxOf(pad1, pad2);
				BBx = BBx + padX;
				padX = 2*padX+width;
				print(padX);
				Array.getStatistics(Yshift, min, max, mean, stdDev);
				pad1 = abs(min);
				pad2 = max;
				padY = maxOf(pad1, pad2);
				BBy = BBy + padY;
				padY = 2*padY + height;
				print(padY);
				selectImage(stk);
  				run("Canvas Size...", "width="+padX+" height="+padY+" position=Center zero");
				//Need to adjust positions to accomodate canvas resize
	
				print(Xshift.length);
				//Array.show(Frames);
				
				for (dd=0; dd<Xshift.length; dd++) {
					Fr = Frames[dd];
					if (Fr < 10) {
						title = "frame_00"+Fr+"";
					}
					if (Fr >= 10 && Fr < 100) {
						title = "frame_0"+Fr+""; 
					}
					if (Fr >= 100) {
						title = "frame_"+Fr+""; 
					}
					//if (dd==0) {
						//selectImage(stk);
						//makeRectangle(BBx, BBy, BBw, BBh);
						//Stack.setFrame(Fr);
						//roiManager("add");
						//run("Duplicate...", "duplicate title="+title+" frames="+Fr+"");
					//}
					selectImage(stk);
					newBBx = BBx+Xshift[dd];
					newBBy = BBy+Yshift[dd];
					print(newBBx, newBBy);
					makeRectangle(newBBx, newBBy, BBw, BBh);
					Stack.setFrame(Fr);
					//roiManager("add");
					run("Duplicate...", "duplicate title="+title+" frames="+Fr+"");
				}
				selectImage(stk);
				close();
				run("Concatenate...", "all_open open");
				setVoxelSize(voxW, voxH, voxD, unit);
				Stack.setFrameInterval(t);
				run("Stack to Hyperstack...", "order=xyczt(default) channels=2 slices="+slices+" frames="+frames+" display=Color");
				saveAs("Tiff", ""+out+""+img_name+".tif");
				rename(boo);
				run("Split Channels");
				selectWindow("C1-boo");
				run("Subtract...", "value=100 stack");
				run("Median...", "radius=2 stack");
				run("Subtract...", "value=10 stack");
				run("Enhance Contrast", "saturated=0.35");
				saveAs("Tiff", ""+out+""+img_name+"_H2Btotrack.tif");
				close();
				run("Close All");
			}
		}
	}
}

setBatchMode(true);
GetFiles(dir);
setBatchMode(false);