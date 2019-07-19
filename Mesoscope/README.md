# 2P exercises

## PYTHON

Check out the python [readme](https://github.com/marius10p/NeuralDataScienceCSHL2019/tree/master/Python)

Open the file [Python/python_tutorial.ipynb](../Python/python_tutorial.ipynb) in a jupyter-notebook. We will go through these exercises together.

## MESOSCOPE IN V1

![2pv1](2pv1.JPG)

^ 18,795 neurons in V1 ^

### view the data in [suite2p](https://github.com/MouseLand/suite2p)

Install suite2p and load the data in folder XX into suite2p (stat.npy).

### retinotopy

We will now compute the receptive fields, using the [retinotopy notebook](retinotopy.ipynb). In these experiments we are showing sparse noise stimuli to the mice as they freely run on an air-floating ball.

### explore data using [rastermap](https://github.com/MouseLand/rastermap)

We will use an unsupervised dimensionality reduction technique that works well with neural data. Install rastermap and load the data into the GUI. 

Next we will run rastermap in the notebook so that we can compute receptive fields across the rastermap, open the [exploratory_analysis notebook](exploratory_analysis.ipynb).

What are these neurons doing which don't have clear receptive fields?

### behavioral analysis with [facemap](https://github.com/MouseLand/facemap)

Let's look at what the mouse is doing during the recording. Install facemap using the instructions on the github. Then open the video "cam1_TX39_20Hz.avi" in facemap (this is a subset of the video). You can see how facemap works in the [facemap_tutorial notebook](facemap_tutorial.ipynb).

I've run facemap on the whole movie and aligned them to the neural frames for you. So now let's see how the behavior relates to the neural activity. Open the [behavioral_analysis notebook](behavioral_analysis.ipynb).

## SUITE2P

Let's learn how to process 2P clacium imaging. There are four main steps:

1. Motion correction [notebook], [slides](../LectureSlides/Day5)
2. Cell detection [notebook], [slides]
3. Spike deconvolution [notebook], [slides]
4. Manual curation (inspect data in GUI)

![2psteps](suite2p.JPG)
