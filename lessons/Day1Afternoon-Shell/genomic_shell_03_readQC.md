---
layout: page
root: ..
title: Read QC
author: Sheldon McKay 
---

# Lesson QC of Sequence Read Data

Quality Control of NGS Data
===================

Learning Objectives:
-------------------
#### What's the goal for this lesson?

* Understand how the FastQ format encodes quality
* Be able to evaluate a FastQC report
* Use Trimmommatic to clean FastQ reads
* Use a For loop to automate operations on multiple files


## Details on the FASTQ format

Although it looks complicated  (and maybe it is), its easy to understand the [fastq](https://en.wikipedia.org/wiki/FASTQ_format) format with a little decoding. Some rules about the format include...

|Line|Description|
|----|-----------|
|1|Always begins with '@' and then information about the read|
|2|The actual DNA sequence|
|3|Always begins with a '+' and sometimes the same info in line 1|
|4|Has a string of characters which represent the quality scores; must have same number of characters as line 2|

so for example in our data set, one complete read is:

    $ head -n4 SRR098281.fastq 
      @SRR098281.1 HWUSI-EAS1599_1:2:1:0:318 length=35
      CNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
      +SRR098281.1 HWUSI-EAS1599_1:2:1:0:318 length=35
      #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

This is a pretty bad read. 

Notice that line 4 is:    

       #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


As mentioned above, line 4 is a encoding of the quality. In this case, the code is the [ASCII](https://en.wikipedia.org/wiki/ASCII#ASCII_printable_code_chart) character table. According to the chart a '#' has the value 35 and '!' has the value 33 - **But these values are not actually the quality scores!** There are actually several historical differences in how Illumina and other players have encoded the scores. Heres the chart from wikipedia:

    SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS.....................................................
    ..........................XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX......................
    ...............................IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII......................
    .................................JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ......................
    LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL....................................................
    !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
    |                         |    |        |                              |                     |
   33                        59   64       73                            104                   126
    0........................26...31.......40                                
                             -5....0........9.............................40 
                                   0........9.............................40 
                                      3.....9.............................40 
    0.2......................26...31........41                              

    S - Sanger        Phred+33,  raw reads typically (0, 40)
    X - Solexa        Solexa+64, raw reads typically (-5, 40)
    I - Illumina 1.3+ Phred+64,  raw reads typically (0, 40)
    J - Illumina 1.5+ Phred+64,  raw reads typically (3, 40)
    with 0=unused, 1=unused, 2=Read Segment Quality Control Indicator (bold) 
    (Note: See discussion above).
    L - Illumina 1.8+ Phred+33,  raw reads typically (0, 41)
 

So using the Illumina 1.8 encouding, which is what you will mostly see from now on, our first c is called with a Phred score of 0 and our Ns are called with a score of 2. Read quality is assessed using the Phred Quality Score.  This score is logarithmically based and the score values can be interpreted as follows:

|Phred Quality Score |Probability of incorrect base call |Base call accuracy|
|:-------------------|:---------------------------------:|-----------------:|
|10	|1 in 10 |	90%|
|20	|1 in 100|	99%|
|30	|1 in 1000|	99.9%|
|40	|1 in 10,000|	99.99%|
|50	|1 in 100,000|	99.999%|
|60	|1 in 1,000,000|	99.9999%|

## FastQC
FastQC (http://www.bioinformatics.babraham.ac.uk/projects/fastqc/) provides a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines. It provides a modular set of analyses which you can use to give a quick impression of whether your data has any problems of which you should be aware before doing any further analysis.

The main functions of FastQC are
* Import of data from BAM, SAM or FastQ files (any variant)
* Providing a quick overview to tell you in which areas there may be problems
* Summary graphs and tables to quickly assess your data
* Export of results to an HTML based permanent report
* Offline operation to allow automated generation of reports without running the interactive application


## Running FASTQC

### A. Stage your data


#### Create a working directory for your analysis

      $ cd

>this command takes us to the home directory     
             
     $ mkdir dc_workshop
     
#### Create three three subdirectories

     $ mkdir dc_workshop/data
     $ mkdir dc_workshop/docs
     $ mkdir dc_workshop/results

  > The sample data we will be working with is in a hidden directory (placing a '.' in front of a directory name hides the directory. In the next step we will move some of those hidden files into our new dirctories to start our project. 
* Move our sample data to our working (home) directory
   

    $ cp -a ~/.dc_sampledata_lite/untrimmed_fastq/ ~/dc_workshop/data/


### B. Run FastQC

#### Navigate to the initial fastq dataset
   
    
    $ cd ~/dc_workshop/data/untrimmed_fastq/
    

To run the fastqc program, we call it from its location in ``~/FastQC``.  fastqc will accept multiple file names as input, so we can use the *.fastq wildcard.

#### Run FastQC on all fastq files in the directory

    
    $ ~/FastQC/fastqc *.fastq
    

Now, let's create a home for our results
    
    $ mkdir ~/dc_workshop/results/fastqc_untrimmed_reads

    
#### Next, move the files there (recall, we are still in ``~/dc_workshop/data/untrimmed_fastq/``)
    
    $ mv *.zip ~/dc_workshop/results/fastqc_untrimmed_reads/
    $ mv *.html ~/dc_workshop/results/fastqc_untrimmed_reads/
    
### C. Results

Lets examine the results in detail

#### Navigate to the results and view the directory contents

   
    $ cd ~/dc_workshop/results/fastqc_untrimmed_reads/
    $ ls

> The zip files need to be unpacked with the 'unzip' program.  
#### Use unzip to unzip the FastQC results: 
   
    $ unzip *.zip

Did it work? No, because 'unzip' expects to get only one zip file.  Welcome to the real world. We *could* do each file, one by one, but what if we have 500 files?  There is a smarter way. We can save time by using a simple shell 'for loop' to iterate through the list of files in *.zip. After you type the first line, you will get a special '>' prompt to type next next lines. You start with 'do', then enter your commands, then end with 'done' to execute the loop.

#### Build a ``for`` loop to unzip the files

    
     $ for zip in *.zip
      > do
      > unzip $zip
      > done


  Note that, in the first line, we create a variable named 'zip'.  After that, we call that variable with the syntax $zip.  $zip is assigned the value of each item (file) in the list *.zip, once for each iteration of the loop.

This loop is basically a simple program.  When it runs, it will run unzip once for each file (whose name is stored in the $zip variable). The contents of each file will be unpacked into a separate directory by the unzip program.

The for loop is interpreted as a multipart command.  If you press the up arrow on your keyboard to recall the command, it will be shown like so:
   
    $ for zip in *.zip; do echo File $zip; unzip $zip; done


When you check your history later, it will help your remember what you did!

### D. Document your work

To save a record, let's cat all fastqc summary.txts into one full_report.txt and move this to ``~/dc_workshop/docs``. You can use wildcards in paths as well as file names.  Do you remember how we said 'cat' is really meant for concatenating text files?

    
    $ cat */summary.txt > ~/dc_workshop/docs/fastqc_summaries.txt

