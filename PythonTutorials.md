### Installation

To get started with python, install Anaconda [python](https://www.anaconda.com/distribution/). This will come with many useful libraries for data analysis. Now if you're in **Windows**, open up an "Anaconda prompt" and you're good to go.

If you're in **Linux** you'll want to make sure that your `~/.bashrc` profile points to Anaconda python, not the built in python (so when you open a terminal you're all set). Add the following lines to your `~/.bashrc` file if it's not there already (where `<user>` is your username):
~~~
export PATH="/home/<user>/anaconda3/bin:$PATH"
conda activate
~~~

If you're in **Mac**, here are detailed [instructions](https://www.datacamp.com/community/tutorials/installing-anaconda-mac-os-x). It should work out of the box in a terminal, but if not you may need to modify your `.bash_profile` like in Linux.

### Packages and environments

Anaconda has a package manager [**conda**](https://conda.io/en/latest/) that you can use to install packages. Here is a good [tutorial](https://conda.io/projects/conda/en/latest/user-guide/getting-started.html) if you want more info. To install a package say
~~~
conda install numpy
~~~
To upgrade to the latest version of a package say
~~~
conda install numpy --upgrade
~~~

Another package manager is `pip`, these are packages that are written only in python (see info [here](https://www.anaconda.com/understanding-conda-and-pip/)). Generally these will be packages that you find on github. I recommend using `conda` when available (e.g. for things like numpy or scikit-learn) because it makes sure that all dependencies are working. Dependencies are packages on which a package depends - most packages in data analysis will depend on the core packages like numpy and scipy.

conda also allows you to create different **environments** for your code. This is different from matlab. In python, there are many packages with different versions that aren't always backward compatible. Therefore, you may write code that might not work quite the same way in a year or so with the latest packages. However, all python packages have **version** control, so you can specifically install an older package with
~~~
pip install suite2p==0.5.5
~~~
or
~~~
conda install numpy==1.13.0
~~~

You may therefore want different environments for different code packages. To create and activate an environment, you can say
~~~
conda create -n cshl
conda activate cshl
~~~

Now you're in a new environment, you should see `(cshl)` on the left-hand side of your terminal. You can install packages here as you wish, and your `(base)` anaconda packages won't change. To see what packages are installed you can say
~~~
conda list
~~~

To close the environment, say
~~~
conda deactivate
~~~

Many packages that you might install from github come with `environment.yml` files to make an environment with the correct dependencies for you. Once in a folder which contains the `environment.yml`, run the following to name the environment `suite2p`:
~~~
conda env create -n suite2p
conda activate suite2p
~~~

### Jupyter notebooks

The `(base)` Anaconda environment will have `jupyter-notebook` installed. Run this from the folder in which you want to create your notebooks and a browser window should open with the address "localhost:8888/tree":
~~~
jupyter-notebook
~~~

If it isn't installed, then install it with
~~~
conda install ipython jupyter
~~~

The tutorials below will use jupyter notebooks (and pretty much everyone who uses python does) so it's a good idea to be able to open one and plot something simple. Here's an [example](https://www.tutorialspoint.com/jupyter/jupyter_notebook_plotting.htm) of something you should try to do yourself.

### Python tutorials

If you're familiar with matlab, then here's a [MATLAB TO NUMPY](http://mathesaurus.sourceforge.net/matlab-numpy.html) cheatsheet. The numpy [tutorial](https://docs.scipy.org/doc/numpy/user/quickstart.html) is also very good. The [indexing](https://docs.scipy.org/doc/numpy/user/quickstart.html#fancy-indexing-and-index-tricks) is a bit different so take note. Slices are `1:10` and these can broadcast in 2D arrays, but lists of indices do NOT broadcast. Run the following in a cell (CTRL+ENTER to run a cell):
~~~
import numpy as np
import matplotlib.pyplot as plt
%matplotlib inline

x = np.random.rand(50,50)

# broadcasted indices (get a square)
plt.imshow(x[10:20, 10:20])

# list of indices (get *10* numbers not a 10x10)!
print(x[np.arange(10,20,1,int), np.arange(10,20,1,int)])
~~~

Numpy also automatically broadcasts if last N indices are the same (it will add the first index itself). However, if you want to broadcast along the last indices, then you need to add new axes:
~~~
import numpy as np

x = np.random.rand(50,100)

print(x.shape, x.mean(axis=0).shape, x.mean(axis=1).shape)

# x is 50x100 and x.mean(axis=0) is 100 long (LAST AXIS MATCHES)
x -= x.mean(axis=0)

# x is 50x100 and x.mean(axis=1) is 50 long (LAST AXIS DOES NOT MATCH)
x -= x.mean(axis=1)[:,np.newaxis]
~~~

Did you see I did a few other tricky things you can't do in matlab? I did an "inline" operation to subtract, the following are equivalent:
~~~
x = x - x.mean(axis=0)
x -= x.mean(axis=0)
~~~

Also, these numpy vectors/matrices have their OWN functions called methods, which you call with the `.` - this is different from matlab. So you can take the mean as
~~~
xmean = x.mean(axis=0)
xmean = np.mean(x, axis=0) # more matlab-y way
~~~
You can see all the methods of an object with
~~~
dir(x)
~~~

The scikit-learn [tutorials](https://scikit-learn.org/stable/tutorial/basic/tutorial.html#machine-learning-the-problem-setting) are a nice place to start trying out some python for simple machine learning.

And for more info, this UCL Engineering [website](http://github-pages.ucl.ac.uk/rsd-engineeringcourse/) covers many python programming topics, here's a [pdf](http://github-pages.ucl.ac.uk/rsd-engineeringcourse/notes.pdf) of their intro to python.

