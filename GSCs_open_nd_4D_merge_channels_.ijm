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
    				splitmerge(modpath);
				}
    		}
    	}
    }
}

function splitmerge(modpath) {
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
	n = nImages;
	//Because we sometimes have >1 stage position and sometimes only have 1 stage position and because this affects the window titles of the images that
	//are opened by Bioformats Importer in ways that seem hard to predict, we first determine whether there is more than 1 image opne. If there is, we assume that
	//the stage position information will be in the window title. If there is only 1 image open, we call this image stage position 1 (i.e. s1).
	if (n > 1) {
    	imglist = newArray(n); 
   		for (j=1; j<=n; j++) { 
        	selectImage(j); 
        	imglist[j-1] = getImageID; 
   		}
   		Array.show(imglist);
    	for (j=0; j<n; j++) { 
        	selectImage(imglist[j]);
        	//the title of each window seems to change depending on the file and I am not sure what, in metamorph, is determining this.
        	//To reliably name each stage position as "img_name" plus stage position for later use, either need a robust way to find the stage
        	//position in the window name (i.e. Title) or use the metadata to rename each window as img_name plus sn (where n = stage position number, i.e. 1, 2, ...)
        	//This version uses the window title, and assumes that the Title looks like "xxxx_s1_t1.TIF - Stage1 "Fatty38""
        	bob = getTitle();
        	bob = substring(bob, indexOf(bob, "Stage"), lastIndexOf(bob, " "));
        	stagepos = substring(bob, 5, lengthOf(bob));
       		print(stagepos);
        	Stack.getDimensions(boo, foo, channels, slices, frames);
        	//boo = getWidth();
        	//foo = getHeight();
			//print(boo);
			//print(foo);
			makeRectangle(0, 0, boo/2, foo);
			run("Duplicate...", "duplicate");
			rename("mCherry");
			selectImage(imglist[j]);
			makeRectangle(boo/2, 0, boo/2, foo);
			run("Crop");
			rename("GFP");
			run("Merge Channels...", "c1=mCherry c5=GFP create");
			merge = getImageID();
			run("Rotate 90 Degrees Right");
			saveAs("Tiff", ""+out+""+img_name+"_s"+stagepos+".tif");
			close();
    	}
	}
	else {
		joe = getImageID();
        Stack.getDimensions(boo, foo, channels, slices, frames);
        //boo = getWidth();
        //foo = getHeight();
		//print(boo);
		//print(foo);
		makeRectangle(0, 0, boo/2, foo);
		run("Duplicate...", "duplicate");
		rename("mCherry");
		selectImage(joe);
		makeRectangle(boo/2, 0, boo/2, foo);
		run("Crop");
		rename("GFP");
		run("Merge Channels...", "c1=mCherry c5=GFP create");
		merge = getImageID();
		run("Rotate 90 Degrees Right");
		saveAs("Tiff", ""+out+""+img_name+"_s1.tif");
		close();
    }
	run("Close All");
}

setBatchMode(true);
GetFiles(dir);
setBatchMode(false);
