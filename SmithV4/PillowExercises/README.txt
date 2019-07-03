
NOTE:
Pillow_script_v2.m and testdata_v2.mat are the latest versions of the script/dataset.

Updated 7/9/2017
*****************

STIMULI:  each stimulus was a plaid composed of 2 gratings drawn from a set of 
8 unique orientations + a blank.  This means we can think about representing each stimulus
as a sparse 9-vector: all zeros with two 1's indicating the identity of the gratings making 
up the plaid (and having a 2 in a single bin if both were the same grating, or both blank).    
Thus, for stimuli we have Nframes x 9 matrix  (composed of 0s, 1s, and 2s).

RESPONSES: a binary representation of each neuron's spike train, in 1ms bins.
Includes time before and after stimulus as defined above.

*****************

Training data (conditions 3-1000)

-stimarray_train: frame # x plaid ID x trial #
	-1st dim: frame order of the plaid stimulus
	-2nd dim: 1x9 vector representation of the 2-grating plaid (see above)
	-3rd dim: chronological order of presentation of this 10-plaid sequence in the experiment 
	(NOTE: this is NOT strictly sequential chronological order, as conditions {1} and {2} are omitted)

-spikedata_train: time x trial # x neuron #
	-1st dim: 100ms pre-stim time + 1000ms of plaid stim time + 100ms post-stim time (pre- and post- can be adjusted in code)
	-2nd dim: chronological order of presentation of this 10-plaid sequence in the experiment 
	-3rd dim: neuron #, as identified by Matt


Testing data (conditions 1-2)

-stimarray_test: cell array containing stimulus data for conditions (10-plaid sequences) {1} and {2}. These conditions were repeated ~100 times, so they are separated into cells and the third dimension (trial #) is omitted for brevity of representation.
	Each cell entry: frame # x plaid #


-spikedata_test: cell array containing response data for conditions {1} and {2}. 
	Each cell entry: time x trial # x neuron #
	- as above, the trial # is chronological BUT not sequential


*****************

Former version notes:

Version 0:

testdata is a .mat file with the responses (spikedata) and stimulus descriptions (stimarray), set up as described below:

Responses are in a cell array indexed by condition (unique 10-plaid sequence). 
- Each cell contains a 3D array of repeats x time x neurons (1ms bin spike rasters);
- I'm including 100 ms of time before and after the 1s of plaid presentation.

Stimulus descriptions are formatted as conditions x 10 x 9.
- First dimension is the same as the response array indexing; 
- Second dimension is the order in the presentation sequence; 
- Third dimension is the stimulus itself, the combination of plaids represented as 0s/1s/2s in appropriate bins.

Version 1:

Testing data are as version 2. 
Training data have condition # instead of trial # dimension (ordered according to condition ID designated by Matt, 3-1000).
Only the first repeat of conditions with ~2 repeats is included in the responses (affects animal Wi* only, ~100 trials excluded).