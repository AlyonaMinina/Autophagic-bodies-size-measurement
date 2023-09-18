//Clear the log window if it was open
if (isOpen("Log")){
	selectWindow("Log");
	run("Close");
	
}

// Create the table for Autophagic bodies density
Density_table = "Autophagic bodies density";
Table.create(Density_table);
Column_1 = "File name";
Column_2 = "ROI number";
Column_3 = "Area of the ROI in um2";
Column_4 = "Autophagic bodies count";
Column_5 = "Number of Autophagic bodies per 10 um2";

//create a table for autophagic bodies areas
Areas_table = "Autophagic bodies areas for the image";
Table.create(Areas_table);
Column_6 = "File name";
Column_7 = "ROI number";
Column_8 = "Autopahgic body number";
Column_9 = "Autophagic body area in um2";
				
// Print the unnecessary greeting
print(" ");
print("Welcome to the Autophagic Bodies measurement!");
print(" ");
print("Please select the folder with images for analysis");
print(" ");

// Find the original directory and create a new one for quantification results
original_dir = getDirectory("Select a directory");
original_folder_name = File.getName(original_dir);
output_dir = original_dir +"Results" + File.separator;
File.makeDirectory(output_dir);


// Get a list of all files in the directory
file_list = getFileList(original_dir);

// Create a shorter list contiaiing . czi files only
czi_list = newArray(0);
for(z = 0; z < file_list.length; z++) {
	if(endsWith(file_list[z], ".czi")) {
		czi_list = Array.concat(czi_list, file_list[z]);
	}
}


// Tell user how many images will be analyzed by the macro
print(czi_list.length + " images were detected for analysis");
print("");

// Request info from the user about the number and dimensions of the ROIs they wish to analyze
number_of_ROIs = 5;
ROI_height = 20;
ROI_width = 10;


Dialog.create("Please provide ROIs parameters for your images");
Dialog.addNumber("Number of ROIs to be analyzed on each image:", number_of_ROIs);
Dialog.addNumber("Dimensions of ROIs. ROI height in um:", ROI_height);
Dialog.addNumber("ROI width in um:", ROI_width);
Dialog.show();


number_of_ROIs = Dialog.getNumber();
ROI_height = Dialog.getNumber();
ROI_width = Dialog.getNumber();	


// Loop analysis through the list of . czi files

for (i = 0; i < czi_list.length; i++) {
	path = original_dir + czi_list[i];
	run("Bio-Formats Windowless Importer",  "open=path");
		      
	// Get the image file title and remove the extension from it    
	title = getTitle();
	a = lengthOf(title);
	b = a-4;
	short_name = substring(title, 0, b);
			
	// Print for the user what image is being processed
	print ("Processing image " + i+1 + " out of " + czi_list.length + ":");
	print(title);
	print("");
							
	// Start ROI Manager to set up user-guided ROIs
	run("ROI Manager...");
	
	// Make sure ROI Manager is clean of any previously used ROIs
	roiManager("reset");
	
	// Obtain coordinates to draw ROIs in the center of the image
	x = getWidth()/2;
	toScaled(x);
	x_coordinate =  parseInt(x);
	
	y = getWidth()/2;
	toScaled(y);
	y_coordinate =  parseInt(y);
	
	// Draw ROIs of the user-provided number and dimensions
	for (no_roi = 0; no_roi < number_of_ROIs; no_roi++) {
	    makeRectangle(x_coordinate, y_coordinate, ROI_width, ROI_height);
	    run("Specify...", "width=ROI_width height=ROI_height x=x_coordinate y=y_coordinate slice=1 scaled");
        roiManager("Add");
	    roiManager("Select", no_roi);
        roiManager("Rename", no_roi + 1);
        roiManager("Show All");
		roiManager("Show All with labels");
		}
				
	// Wait for the user to adjust the ROIs size and position
	waitForUser("Adjust each ROI, then hit OK"); 
	
				
	//Perform segmentation and particle analysis for each ROI and save the results into a custom table
	run("ROI Manager...");
	ROI_number = roiManager("count");
	for ( r=0; r<ROI_number; r++ ) {
		selectWindow(title);
		roiManager("Select", r);
		current_last_row = Table.size(Density_table);
		Table.set(Column_1, current_last_row, short_name, Density_table);
		Table.set(Column_2, current_last_row, r+1, Density_table);
		
		//Measure and log the area of the current ROI	
		run("Set Measurements...", "area redirect=None decimal=3");
		run("Measure");
		ROI_area = getResult("Area", 0);
		Table.set(Column_3, current_last_row, ROI_area, Density_table);
		run("Clear Results");
				
		// Duplicate ROI and quantify autophagic bodies within it using Florentine's segmentaion settings
		run("Duplicate...", "duplicate channels=1");
		rename("Micrograph");
		run("8-bit");
		run("Duplicate...", " ");
		rename("Discard");
		run("Despeckle");
		run("Sharpen");
		run("Despeckle");
		setAutoThreshold("Yen dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Watershed");
		run("Despeckle");
		run("Watershed");
	
		//measure particles
		run("Set Measurements...", "area redirect=None decimal=3");
		run("Analyze Particles...", "size=0.15-10.00 circularity=0.70-1.00 show=[Overlay Masks] display clear composite");
		rename("Segmentation");
		//save particles areas as a .csv file
		AB_count = nResults;
		for (c = 0; c < nResults(); c++) {
	   		Autophagic_body_number = getResult(" ", c);
	   		area = getResult("Area", c);
			current_last_row_in_areas = Table.size(Areas_table);
			Table.set(Column_6, current_last_row_in_areas, short_name, Areas_table);
			Table.set(Column_7, current_last_row_in_areas, r+1, Areas_table);
			Table.set(Column_8, current_last_row_in_areas, c+1, Areas_table);
			Table.set(Column_9, current_last_row_in_areas, area, Areas_table);
		}
		Table.save(output_dir + "Autophagic bodies areas for experiment " + original_folder_name + ".csv");
		
		
		//log particles number into the Autophagic bodies density table
		AB_count = nResults;
		ROI_area = Table.get(Column_3, current_last_row, Density_table);
		//print("AB count "+ AB_count);
		//print("ROI_area "+ ROI_area);
		Table.set(Column_4, current_last_row, AB_count, Density_table);
		Table.set(Column_5, current_last_row, 10*AB_count/ROI_area, Density_table);
		run("Clear Results");
		
		//Save thersholding results
		run("Combine...", "stack1=Micrograph stack2=Segmentation");
		saveAs("Tiff", output_dir + short_name + " Segmentation results for ROI " + (r+1) + ".tif");
		}
	
		//Save ROIs as a .zip file
		roiManager("Save", output_dir + short_name +"_ROIs.zip");
		run("Close All");
		roiManager("reset");
		run("Clear Results");		
	}		

//Save the quantification results into a .csv table file
Table.save(output_dir + "Autophagic bodies density for experiment " + original_folder_name + ".csv");

 
//A feeble attempt to close those pesky ImageJ windows		
run("Close All");
roiManager("reset");

if (isOpen("Results")){
	selectWindow("Results");
	run("Close");
	}
if (isOpen("Summary")){
	selectWindow("Summary");
	run("Close");
	}
if (isOpen("Autophagic bodies density")){
	selectWindow("Autophagic bodies density");
	run("Close");
	}	
	
if (isOpen("ROI Manager")){
	selectWindow("ROI Manager");
	run("Close");
	}	
	
 
//Print the final message
print(" ");
print("All Done!");
print("Your quantification results are saved in the folder " + output_dir);
print(" "); 
print(" ");
print("Alyona Minina. 2023.");
