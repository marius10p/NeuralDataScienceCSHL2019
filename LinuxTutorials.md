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

## Cheat sheet of useful commands:

**man "command"**: see what the options are for an executable command like "python" or "mv"

**sudo __**: this preface allows you to make changes to your root directory, like copy/edit files or install packages

**sudo apt install**: install packages (autocomplete available with TAB)

**ctrl+r**: allows you to search through previous commands you've typed into the command line (can use ctrl+c to cancel)

### Processes

**ctrl+c**: kill anything running 

**free -h**: summary of memory usage (RAM)

**top**: shows you all processes running and what resources they're using

**kill PID**: kill processes with ID's you can see in **top**

### Look around and move things (you can use **TAB** to try to autocomplete ANYTHING)

**pwd**: states the full path to the directory you're currently in

**cd ~/**: this takes you to your home directory (you have write access here)

**cd /**: this takes you to the root directory (you have read-only access here)

**cd ../**: go to the parent of the current directory you're in (go one folder up)

**cd "folder"**: change to directory to "folder"

**mkdir "folder"**: create directory "folder"

**mv "file" "folder"**: move a "file" to "folder"

**mv "folder1" "folder2"**: move "folder1" to "folder2"

**cp "file" "folder"**: copy a "file" to "folder"

**cp -r "folder1" "folder2"**: copy "folder1" to "folder2"

**rm "file"**: delete file

**rm -r "folder"**: delete folder

**ls -lt string***: lists contents of a directory + time of last edit + whether you have read-write-executable access

**star means anything can follow**

### Look at and edit files

**less "filename"**: quickly look at file without edit ("q" to quit, arrow keys/page up/down to move)

**vi "file_name"**: open a text file to edit (to insert text, type "i"; to save and close, press ESC and type ":wq"

**chmod 777 "file_name"**: makes a file executable

**grep "phrase" \*.txt**: look for "phrase" in all txt files in a directory
