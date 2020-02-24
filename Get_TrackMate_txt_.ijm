//Macro #4 (optional)

//This macro opens each trackmate xml file, asks the user to generate the necessary results windows (i.e. run "Analysis" in Trackmate) and saves the 
//"Spots in tracks statistics" output as a csv file with file name "+img_name+"_"+stagepos+"_emb_"+k+".csv" in a new folder in 
//the parent directory (dir) called "embs_tracks"

dir = getDirectory("Select source directory.");

File.makeDirectory(""+dir+"embs_tracks");
out = ""+dir+"embs_tracks\\";


function GetFiles(dir) {
	list = getFileList(dir); 
    for (i=0; i<list.length; i++) {
    	if (endsWith(list[i], "/")) {
    		GetFiles(""+dir+list[i]);
    		}
    	else {
    		if (endsWith(list[i], ".xml")) {
    			path = dir+list[i];
    			modpath = replace(path, "/", "\\");
    			print(modpath);
    			getcsv(modpath);
    		}
    	}
    }
}

function getcsv(modpath) {
	run("Clear Results");
	run("Load a TrackMate file");
	wait(1000);
	name = getTitle();
	name = replace(name, ".tif", "");
	print(name);
	waitForUser("run TrackMate analysis to generate Spots in tracks statistics window");
	selectWindow("Track statistics");
	run("Close");
	selectWindow("Links in tracks statistics");
	run("Close");
	selectWindow("Spots in tracks statistics");
	saveAs("Results", ""+out+""+name+".txt");
	//print(path);
	run("Close All");
	selectWindow(""+name+".txt");
	run("Close");
}

//setBatchMode(true);
GetFiles(dir);
//setBatchMode(false);