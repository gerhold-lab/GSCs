//This macro runs through a folder of tiff files, opens each one, and allows the user to select a region to crop. The cropped image REPLACES THE ORIGINAL TIFF.
//Only use this macro if your tiff has a single object of interest (i.e. one germline) and you want to reduce your file size by excluding wasted background pixels.
//If you are working with GSCs and your field of view has more than one germline in it (first kudos on a good image session), you can keep a single tiff with both 
//germlines included. We will distinguish between them later on by generating two separate TrackMate files, one for each germline.

//A single ROI is saved for each tiff which has the coordinates of the bounding box that was used to crop the object (i.e. germline) from the original tiff,
//which has the same field of view as the original nd file.

//dir should be a folder with your original tiff files, usually on the lab's server and generated by running the GSCS_open_nd_4D_merge_channels macro. 

dir = getDirectory("Select source directory.");


function GetFiles(dir) {
	list = getFileList(dir);
	//Array.show(list);
    for (i=0; i<list.length; i++) {
    	if (endsWith(list[i], "/")) {
    		GetFiles(""+dir+list[i]);
    		}
    	else {
    		if (endsWith(list[i], ".tif")) {
    			path = dir+list[i];
    			print(path);
    			modpath = replace(path, "/", "\\");
    			print(modpath);
    			croptiff(modpath);
    		}
    	}
    }
}

function croptiff(modpath) {
	img_name = substring(modpath, lastIndexOf(modpath, "\\")+1, lengthOf(modpath));
	print(img_name);
	open(modpath);
	merge = getImageID();
	roi = replace(modpath, ".tif", ".roi");
	//print(roi);
	selectImage(merge);
	Stack.setChannel(1);
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Enhance Contrast", "saturated=0.35");
	run("Clear Results");
	roiManager("Reset");
	waitForUser("select a rectangular region encompassing the germline to be cropped which is approximately centered in xy on the germline of interest and which includes some background and add to ROI manager");
	waitForUser("Did you press t???");
	roiManager("select", 0);
	run("Duplicate...", "duplicate");
	dup = getImageID();
	saveAs("Tiff", ""+modpath+"");
	roiManager("save", ""+roi+"");
	selectImage(dup);
	close();
	selectImage(merge);
	close();
}

//setBatchMode(true);
GetFiles(dir);
//setBatchMode(false);