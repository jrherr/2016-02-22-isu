---
layout: page
root: ..
title: "The Shell"
comments: true
date: 2016-02-19
---

# The Shell

Author: Sheldon McKay

Adapted from the lesson by Tracy Teal.
Original contributors:
Paul Wilson, Milad Fatenejad, Sasha Wood and Radhika Khetani for Software Carpentry (http://software-carpentry.org/)

## Searching files

We showed a little how to search within a file using `less`. We can also
search within files without even opening them, using `grep`. Grep is a command-line
utility for searching plain-text data sets for lines matching a string or regular expression.
Let's give it a try!

Suppose we want to see how many reads in our file have really bad, with 10 consecutive Ns  
Let's search for the string NNNNNNNNNN in file 
     $ cd ~/dc_sample_data/untrimmed_fastq
     $ grep NNNNNNNNNN SRR098026.fastq

We get back a lot of lines.  What is we want to see the whole fastq record for each of these read.
We can use the '-B' argument for grep to return the matched line plus one before (-B 1) and two
lines after (-A 2). Since each record is four lines and the last second is the sequence, this should
give the whole record.

    $ grep -B1 -A2 NNNNNNNNNN SRR098026.fastq

for example:

    @SRR098026.177 HWUSI-EAS1599_1:2:1:1:2025 length=35
    CNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
    +SRR098026.177 HWUSI-EAS1599_1:2:1:1:2025 length=35
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

****
**Exercise**

1) Search for the sequence GNATNACCACTTCC in SRR098026.fastq.
In addition to finding the sequence, have your search also return
the name of the sequence.

2) Search for that sequence in both fastq files.
****

## Redirection

We're excited we have all these sequences that we care about that we
just got from the FASTQ files. That is a really important motif
that is going to help us answer our important question. But all those
sequences just went whizzing by with grep. How can we capture them?

We can do that with something called "redirection". The idea is that
we're redirecting the output to the terminal (all the stuff that went
whizzing by) to something else. In this case, we want to print it
to a file, so that we can look at it later.

The redirection command for putting something in a file is `>`

Let's try it out and put all the sequences that contain 'NNNNNNNNNN'
from all the files in to another file called 'bad_reads.txt'

    $ grep -B1 -A2 NNNNNNNNNN SRR098026.fastq > bad_reads.txt

The prompt should sit there a little bit, and then it should look like nothing
happened. But type `ls`. You should have a new file called bad_reads.txt. Take
a look at it and see if it has what you think it should.

If we use '>>', it will append to rather tha overwrite a file.  This can be useful for
saving more than one search, for example:

    $ grep -B1 -A2 NNNNNNNNNN SRR098026.fastq > bad_reads.txt
    $ grep -B1 -A2 NNNNNNNNNN SRR097977.fastq >> bad_reads.txt

There's one more useful redirection command that we're going to show, and that's
called the pipe command, and it is `|`. It's probably not a key on
your keyboard you use very much. What `|` does is take the output that
scrolling by on the terminal and then can run it through another command.
When it was all whizzing by before, we wished we could just slow it down and
look at it, like we can with `less`. Well it turns out that we can! We pipe
the `grep` command through `less`

    $ grep -B1 -A2 NNNNNNNNNN SRR098026.fastq | less

Now we can use the arrows to scroll up and down and use `q` to get out.

We can also do something tricky and use the command `wc`. `wc` stands for
`word count`. It counts the number of lines or characters. So, we can use
it to count the number of lines we're getting back from our `grep` command.
And that will magically tell us how many sequences we're finding. We're

    $ grep -B1 -A2 NNNNNNNNNN SRR098026.fastq | wc

That tells us the number of lines, words and characters in the file. If we
just want the number of lines, we can use the `-l` flag for `lines`.

    $ grep -B1 -A2 NNNNNNNNNN SRR098026.fastq | wc -l

Redirecting is not super intuitive, but it's really powerful for stringing
together these different commands, so you can do whatever you need to do.

The philosophy behind these command line programs is that none of them
really do anything all that impressive. BUT when you start chaining
them together, you can do some really powerful things really
efficiently. If you want to be proficient at using the shell, you must
learn to become proficient with the pipe and redirection operators:
`|`, `>`, `>>`.



Finally, let's use the new tools in our kit and a few new ones to example our SRA metadata file.

    $ cd 
    $ cd dc_sample_data/sra_metadata

Let's ask a few questions about the data

1) How many of the read libraries are paired end?

First, what are the column headers?

    $ head -n 1 SraRunTable.txt
    BioSample_s	InsertSize_l	LibraryLayout_s	Library_Name_s	LoadDate_s	MBases_l	MBytes_l	ReleaseDate_s Run_s SRA_Sample_s Sample_Name_s Assay_Type_s AssemblyName_s BioProject_s Center_Name_s Consent_s Organism_Platform_s SRA_Study_s g1k_analysis_group_s g1k_pop_code_s source_s strain_s

That's only the first line but it is a lot to take in.  'cut' is a program that will extract columns in tab-delimited
files.  It is a very good command to know.  Lets look at just the first four columns in the header using the '|' readirect
and 'cut'

    $ head -n 1 SraRunTable.txt | cut -f1-4
    BioSample_s InsertSize_l      LibraryLayout_s	Library_Name_s    

'-f1-4' means to cut the first four fields (columns).  The LibraryLayout_s column looks promising.  Let's look at some data for just that column.

    $ cut -f3 SraRunTable.txt | head -n 10
    LibraryLayout_s
    SINGLE
    SINGLE
    SINGLE
    SINGLE
    SINGLE
    SINGLE
    SINGLE
    SINGLE
    PAIRED
    
We can see that there are (at least) two categories, SINGLE and PAIRED.  We want to search all entries in this column
for just PAIRED and count the number of hits.

    $ cut -f3 SraRunTable.txt | grep PAIRED | wc -l
    2

2) How many of each class of library layout are there?

We can use some new tools 'sort' and 'uniq' to extract more information.  For example, cut the third column, remove the
header and sort the values.  The '-v' option for greap means return all lines that DO NOT match.

    $ cut -f3 SraRunTable.txt | grep -v LibraryLayout_s | sort
    
This returns a sorted list (too long to show here) of PAIRED and SINGLE values.  Now we can use 'uniq' with the '-c' flag to
count the different categories.

    $ cut -f3 SraRunTable.txt | grep -v LibraryLayout_s | sort | uniq -c
      2 PAIRED
     35 SINGLE 

3) Sort the metadata file by PAIRED/SINGLE and save to a new file
   We can use if '-k' option for sort to specify which column to sort on.  Note that this does something
   similar to cut's '-f'.

    $ sort -k3 SraRunTable.txt > SraRunTable_sorted_by_layout.txt

4) Extract only paired end records into a new file
   Do we know PAIRED only occurs in column 4?  WE know there are only two in the file, so let's check.

    $ grep PAIRED SraRunTable.txt | wc -l
    2

OK, we are good to go.

    $ grep PAIRED SraRunTable.txt > SraRunTable_only_paired_end.txt
    

****
**Final Exercise**

1) How many sample load dates are there?

2) How many samples were loaded on each date

3) Filter subsets into new files bases on load date
****

 
## Search file: where is my file?
While grep finds lines in files, the find command finds files themselves. Again, it has a lot of options; to show how the simplest ones work, we’ll use the directory tree shown below.

For our first command, let’s run find . -type d. As always, the . on its own means the current working directory, which is where we want our search to start; -type d means “things that are directories”. Sure enough, find’s output is the names of the five directories in our little tree (including .):
    $ cd ~/FastQC
    $ find . -type d

If we change -type d to -type f, we get a listing of all the files instead:

    $ find . -type f
    
find automatically goes into subdirectories, their subdirectories, and so on to find everything that matches the pattern we’ve given it. If we don’t want it to, we can use -maxdepth to restrict the depth of search:

     $ find . -maxdepth 1 -type f

The opposite of -maxdepth is -mindepth, which tells find to only report things that are at or below a certain depth. -mindepth 2 therefore finds all the files that are two or more levels below us:

    $ find . -mindepth 2 -type f

Now let’s try matching by name:

    $ find . -name *.txt

We expected it to find all the text files, but it only prints out LICENSE.txt. The problem is that the shell expands wildcard characters like * before commands run. Since *.txt in the current directory expands to LICENSE.txt, the command we actually ran was:

    $ find . -name LICENSE.txt

find did what we asked; we just asked for the wrong thing.

To get what we want, let’s do what we did with grep: put *.txt in single quotes to prevent the shell from expanding the * wildcard. This way, find actually gets the pattern *.txt, not the expanded filename LICENSE.txt:

    $ find . -name '*.txt'

## Where can I learn more about the shell?

- Software Carpentry tutorial - [The Unix shell](http://software-carpentry.org/v4/shell/index.html)
- The shell handout - [Command Reference](http://files.fosswire.com/2007/08/fwunixref.pdf)
- [explainshell.com](http://explainshell.com)
- http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html
- man bash
- Google - if you don't know how to do something, try Googling it. Other people
have probably had the same question.
- Learn by doing. There's no real other way to learn this than by trying it
out.  Write your next paper in nano (really emacs or vi), open pdfs from
the command line, automate something you don't really need to automate.


## Bonus:

**backtick, xargs**: Example find all files with certain text

**alias** -> rm -i

**variables** -> use a path example

**.bashrc**

**du**

**ln**

**ssh and scp**

**Regular Expressions**

**Permissions**

**Chaining commands together**
