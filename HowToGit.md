### Installation

Install [git](https://git-scm.com/downloads) on your computer. On Windows/Mac/Linux, you can run `git` from the terminal/command prompt/Anaconda prompt. You might want to make a local folder called `github` where you put all your repositories. 
~~~
mkdir github
cd github
~~~
Now in the folder of your choice, you can **clone** AKA download a github repository. You append `.git` to the web address. 
~~~
git clone https://github.com/AllenInstitute/AllenSDK.git
~~~
Now enter this folder and **fetch** all the **branches**
~~~
cd AllenSDK
git fetch --all
~~~



If you want to use a different branch or create your own branch, then say the following:

git fetch --all
git checkout my_branch
Here are more detailed instructions here under git checkout a remote branch

Now you're in a specific branch and can run "python -m suite2p" again, and you'll be running this branch's code.



### Extra python info

You can run a "pip/conda" installed package from any folder. You can also run github versions of code packages (and their various branches) without "pip" installation, but you have to be in the repository folder to run suite2p. The github version will not mess with your "pip" installed version, it will just be a different folder on your computer. To be able to checkout different branches of suite2p you will need git installed. 
