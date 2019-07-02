To get started with python, install Anaconda [python](https://www.anaconda.com/distribution/). This will come with many useful libraries for data analysis.

Anaconda allows you to create different **environments** for your code. This is different from matlab. In python, there are many packages with different versions that aren't always backward compatible. Therefore, you may write code that might not work quite the same way in a year or so. However, all python packages have **version** control, so you can specifically install a package with
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

Now you're in a new environment, you should see `(cshl)` on the left-hand side of your terminal. You can install packages here as you wish, and your `(base)` anaconda packages won't change. To close the environment, say
~~~
conda deactivate
~~~

In fact many packages that you might install from github come with `environment.yml` files to make an environment with the correct dependencies for you.

This UCL Engineering [website](http://github-pages.ucl.ac.uk/rsd-engineeringcourse/) covers many python programming topics, here's a [pdf](http://github-pages.ucl.ac.uk/rsd-engineeringcourse/notes.pdf) of their intro to python.

