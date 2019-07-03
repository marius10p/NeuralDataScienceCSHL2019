### Installation

Install [git](https://git-scm.com/downloads) on your computer. On Windows/Mac/Linux, you can run `git` from the terminal/command prompt/Anaconda prompt. You might want to make a local folder called `github` where you put all your repositories. 
~~~
mkdir github
cd github
~~~
Now in the folder of your choice, you can **clone** (download) a github repository. You append `.git` to the web address. 
~~~
git clone https://github.com/AllenInstitute/AllenSDK.git
~~~
Now enter this folder and list all the **branches**
~~~
cd AllenSDK
git branch -a
~~~
We can checkout one of these branches
~~~
git checkout 207
~~~
These branches are development code that is separate from the master. Often you make a branch to add a new feature and then merge the feature into the main branch. So you may want to checkout a branch to get the latest features of the code.

To get back to master, `git checkout master`. To get the LATEST code, use the **pull** command:
~~~
git pull
~~~

### Edit files (in repo you own)

If you change a file, you can **commit** the changes to that file with
~~~
git commit -a -m 'my commit'
git push
~~~

The commit message is 'my commit' in this case, it should say what code you've changed. To **add** new files to the repository that you've added only locally, say
~~~
git add mytext.txt
git commit -a -m 'mytext added'
git push
~~~

### Advanced (optional)

This isn't our repository so we can't make a branch, add a feature and push it to the master branch. But we can **fork** the repository and make a branch there, and then if we want to suggest these changes to the master branch we make a **pull request**.

To make a fork, you'll need to click on the **fork** button on the github page and then clone the fork. Now you'll have your OWN version of this repository.
~~~
cd ..
mkdir fork
cd fork
git clone https://github.com/carsen-stringer/AllenSDK.git
cd AllenSDK
~~~

Make a branch and **push** it to github (push means put the code on github)
~~~
git checkout master
git checkout -b mybranch
git push origin mybranch
~~~

Now if you run `git branch -a` you'll see a new branch `mybranch` with a star next to it, signifying that you're on that branch.

From the github website, you can make a pull request with this branch and add comments about what it does. I'd recommend doing it this way if you're suggesting changes to someone else's repository.

If this is your own repository then the following will merge the branch into the master branch:
~~~
git checkout master
git merge mybranch
~~~

### Extra python info

You can run a "pip/conda" installed package from any folder. You can also run github versions of code packages (and their various branches) without "pip" installation, but you have to be in the repository folder to run the code OR add it to your path. The github version will not mess with your "pip" installed version, it will just be a different folder on your computer. 

If you want to, you can pip install a github version with the command `pip install git+https://github.com/pyqtgraph/pyqtgraph`.

To add a folder with \*.py files to your path in python in a jupyter-notebook for instance, use the following
~~~
import sys
sys.path.insert(0, 'PATH')
~~~

### Resources

- [branches in depth](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell)
- [merging](https://www.atlassian.com/git/tutorials/using-branches/git-merge)
