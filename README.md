# ImageJ macros for autophagic bodies size and density measurement

This ImageJ macro is designed to analyze Carl Zeiss confocal images. The macro will process all .czi files in a selected folder, it will process all regions of interests (ROIs) selected by the user and determine the number of autophagic bodies present in 10 um^2 of ROI and the area of each autophagic body.


## **The ImageJ Macro for autophagic bodies size measurement. ** 

**Step by step:**

1. Put all images that you wish to process into a single folder.
2. Download the macro file and drag&drop it into ImageJ -> the script will open in the Editor window
3. Click on "Run"
4. Follow the macro to open the folder from the Step 1
5. If needed, change the number of regions of interest (ROIs) that you wish to analyze on EACH image and adjust the preset size for the ROIs (you will be able to adjust it later).
6. If needed adjust the size and position of ROI for puncta analysis, click on “update” in the ROI Manager after adjusting each ROI.
7. Hit ok-> macro will process each ROI and save the following files in the Results subfolder:

  - .csv file with density of autophagic bodies (calculated for 10 um^2 for each ROI)
  - .csv file with area of each autophagic body in um^2
  - .tiff file with side by side comparison of the original image cropped to the ROI size and the results of image segmentation (can be used to adjust segmentation settings) 

8. Repeat steps 6 for each image in your folder. 

<p align="center"> <a href=" https://youtu.be/4HWWrh_u8nU"><img src="https://github.com/AlyonaMinina/Autophagic-bodies-size-measurement/blob/main/Images/Youtube%20preview.PNG?raw=true" width = 480> </img></a></p>

