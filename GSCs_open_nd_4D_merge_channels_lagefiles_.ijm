//Macro #1

//Run this macro first on raw data directly from SD3/Metamorph. This macro opens each nd file, converts the dual camera single tif output into a 2 channel hyperstack 
//The original metadata for each nd file is also saved in the output folder. The nd file field of view may have been the full camera chip or a cropped 
//region of the camera chip, in which case, the coordinates of this first cropped region will be in the metadata. This information will be neccessary for 
//flat field corrections and image registration. This macro also rotates the image by 90 degrees.


dir = getDirectory("Select source directory.");
out = getDirectory("Choose an output directory.");

function GetFiles(dir) {
	list = getFileList(dir);
	//Array.show(list);
    for (i=0; i<list.length; i++) {
    	if (endsWith(list[i], "/")) {
    		GetFiles(""+dir+list[i]);
    		}
    	else {
    		if (endsWith(list[i], ".nd")) {
    			path = dir+list[i];
    			print(path);
    			modpath = replace(path, "/", "\\");
    			print(modpath);
    			nd_name = substring(modpath, lastIndexOf(modpath, "\\")+1, lengthOf(modpath));
				print(nd_name);
				img_name = replace(nd_name, ".nd", "");
				print(img_name);
				//if this script has been run already, a csv file with the metadata will have been saved in the "out" directory for each nd
				//if this file exists, the script will not process a given nd file --> if you want to re-run this script, you will need to make sure
				//that any csv files with the same file name as the nd file have been removed from the "out" folder
				if (File.exists(""+out+""+img_name+"_metadata.csv") != 1) {
    				getmetadata(modpath);
				}
    		}
    	}
    }
}

function getmetadata(modpath) {
	nd_name = substring(modpath, lastIndexOf(modpath, "\\")+1, lengthOf(modpath));
	print(nd_name);
	img_name = replace(nd_name, ".nd", "");
	print(img_name);
	run("Bio-Formats Importer", "open='"+modpath+"' display_metadata open_all_series view=Hyperstack stack_order=XYCZT");
	//boo = getImageID();
	selectWindow("Original Metadata - "+nd_name+"");
	foo = ""+img_name+"_metadata.csv";
	//print(foo);
	saveAs("Text", ""+out+""+foo+"");
	selectWindow("Original Metadata - "+nd_name+"");
	run("Close");
	run("Close All");
}

setBatchMode(true);
GetFiles(dir);
setBatchMode(false);


function GetFiles2(dir) {
	listA = getFileList(dir);
	//Array.show(list);
    for (i=0; i<listA.length; i++) {
    	if (endsWith(listA[i], "/")) {
    		GetFiles2(""+dir+listA[i]);
    		}
    	else {
    		if (endsWith(listA[i], ".TIF")) {
    			path = dir+listA[i];
    			print(path);
    			modpath = replace(path, "/", "\\");
    			print(modpath);
    			nd_name = substring(modpath, lastIndexOf(modpath, "\\")+1, lengthOf(modpath));
				print(nd_name);
				img_name = replace(nd_name, ".TIF", "");
				print(img_name);
				splitmerge(modpath);
				}
    		}
    	}
    }


function splitmerge(modpath) {
	nd_name = substring(modpath, lastIndexOf(modpath, "\\")+1, lengthOf(modpath));
	print(nd_name);
	img_name = replace(nd_name, ".TIF", "");
	print(img_name);
	frame = substring(img_name, lastIndexOf(img_name, 't')+1, lengthOf(img_name));
	if (lengthOf(frame) < 2) {
		frame = "0"+frame+"";
	}
	print(frame);
	img_name_noFr = substring(img_name, 0, lastIndexOf(img_name, 't')+1);
	print(img_name_noFr);
	open(modpath);
	bob = getImageID();
	Stack.getDimensions(boo, foo, channels, slices, frames);
	makeRectangle(0, 0, boo/2, foo);
	run("Duplicate...", "duplicate");
	rename("mCherry");
	selectImage(bob);
	makeRectangle(boo/2, 0, boo/2, foo);
	run("Crop");
	rename("GFP");
	run("Merge Channels...", "c1=mCherry c5=GFP create");
	merge = getImageID();
	run("Rotate 90 Degrees Right");
	saveAs("Tiff", ""+out+""+img_name_noFr+""+frame+".tif");
	close();
}

setBatchMode(true);
GetFiles2(dir);
setBatchMode(false);
