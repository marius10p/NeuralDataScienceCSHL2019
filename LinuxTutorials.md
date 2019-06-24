Linux is the main operating system used for scientific computing. Different distributions of Linux can look very different, but Ubuntu is the main user-friendly version typically installed on workstations. Ubuntu provides a point-and-click interface similar to Windows and OS X, but you can and should do everything you need from the command line. This takes a bit of practice and learning. Please familiarize yourself with the tutorials below and/or be ready to refer to them when you need to during the course. Note that a compute cluster might have something like Scientific Linux installed; you probably only get a command line without a graphical interface, but all the commands are the same. 

1) Start with the section “Unix/Linux for Beginners”:  
	https://www.tutorialspoint.com/unix/unix-getting-started.htm

2) Now that you had an introduction, read about the command line:  
  https://tutorials.ubuntu.com/tutorial/command-line-for-beginners#0  
	https://ipython-books.github.io/21-learning-the-basics-of-the-unix-shell/

3) You will sometimes need to view or edit text in the command line, for which you can use vi(m):   
	https://ryanstutorials.net/linuxtutorial/vi.php

4) Advanced topic: shell scripting. This is like writing a script with multiple lines of code for the command line to execute sequentially. If you are submitting jobs to a compute cluster, you will write such scripts to include all the commands you want your job to run (i.e. matlab or python programs). 
	https://www.tutorialspoint.com/unix/shell_scripting.htm

Cheat sheet of useful commands:

Man

sudo apt install

Cd ~/, /

Mv

Rm (-r)

pwd

ls -lt string*    #star means anything can follow

cat/less file_name

vi file_name # open a text file to edit

chmod 777 file_name # make a file executable
