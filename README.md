## Introduction

The STORM data analysis toolbox is a toolbox made to analyze SMLM data with MATLAB. It has multiple modules built in that can perform different types of analyses (e.g., colocalization, single-particle tracking, segmentation, visualization, etc.).

### Data structure
This toolbox was specifically written for our analysis pipeline (as in: the data structure is specific for our pipeline). The core of the calculations will be the same for every analysis pipeline, but the way the data is ordered may be different depending on your own pipeline. 
Please structure your own data so that it is conform to the toolbox written here.

## System requirements
The files were tested in MATLAB R2021b (The MathWorks, USA), on a i7-12700H 2.30 GHz (32 GB RAM) laptop running Windows 64-bit. No errors were encountered (only some warnings sometimes related to the polyshape function of MATLAB, but these can safely be ignored).
The code was also tested in MATLAB R2022b, but should be working in any version of MATLAB where the polyshape.m function exists (i.e., MATLAB R2017b or newer).

## Installation and run guide
To Run:
  - Download the full folder from this repository to your computer.
  - Add the full folder to your MATLAB path 
  ```
  Option 1: Navigate to the folder through the 'Current Folder' menu and right click -> Add To Path -> Selected Folders and Subfolders
  Option 2: Home tab in MATLAB -> Environment group: Set Path -> Add with Subfolders -> Select the folder in the input dialog -> Save -> Close
  ```
  - Run the 'data_analysis_software.m' file
  ```
  run('data_analysis_software.m')
  ```
  - Load your data
  ```
  Select 'Load Session'
  Select the file you want to load (for the example, select the one included in this repository)
  ```
  - Perform the colocalization analysis for the Lysosome data
  ```
  Select Modules
  Select Lysosome Mask Module (or Lysosome Mask LAMTOR Module)
  Select the reference data in the Data Browser -> click 'Set Reference Data' in the Lysosome Mask Module (or Lysosome Mask LAMTOR Module)
  Select the colocalization data in the Data Browser -> click 'Set Other Channel' in the Lysosome Mask Module (or Lysosome Mask LAMTOR Module)
  Select 'Start Extraction'
  ```
  - Perform the Pattern Analysis
  ```
  Select Modules
  Select Pattern Analysis Module
  Select the reference data in the Data Browser -> click 'Set Reference Data' in the Pattern Analysis Module
  Select the colocalization data in the Data Browser -> click 'Set Other Channel' in the Pattern Analysis Module
  Select 'Start Extraction'
  ```
Note: make sure to install python for MATLAB when running the Pattern Analysis.

 A typical "installation" should not take you longer than a minute, and the run time on a i7-12700H 2.30 GHz (32 GB RAM) laptop with Windows 64-bit is ~2 minutes.
 
 The output will be:
  - An Excel file with the entire summary of the output.
  - The seperated data saved in the data browser
  
## Other
For more information, please refer to: xxx (to be updated)
