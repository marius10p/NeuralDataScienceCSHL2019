%This program aims to do an exploratory data analysis of the Matt Smith
%dataset. The point of that is to familiarize ourselves with a complex
%dataset.
%(Always start with a header file.)
%(Always start with stating the strategic goal)
%(These 2 are meta comments. This - in itself is a meta-meta-comment.)
%Input: A .mat file provided by Matt Smith
%Output: Figures representing raster plot, PSTH and tuning curve
%Assumptions: The data is located in the same folder as the script. It assumes all
%sections are executed sequentially. 
%Version history: V1 07/13/2019
%Who is responsible for this code and how do I reach them? 

nds0Init %Initialization
disp('Analysis Initialized...')
nds1Load %Loads data (transduction)
disp('Data loaded into workspace...')
nds2Prune %Clean data
disp('Data cleaned...')
nds3Format %Re-format data to prepare analysis
disp('Data formatted...')
nds4PSTH %Make the PSTH
nds5Rasters %Make the raster plots
nds6tuningCurve %Make the tuning curve
nds7fitCurve %Fit a curve to the empirical data