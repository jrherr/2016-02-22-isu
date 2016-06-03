#! bin/R

b <- sqrt(a)

round(3.14159)

args(round)

?round

round(3.14159, digits=2)

round(3.14159, 2)

?barplot

args(lm)

??geom_point

help.search("kruskal")

dput(head(iris)) # iris is an example data.frame that comes with R

saveRDS(iris, file="/tmp/iris.rds")

some_data <- readRDS(file="/tmp/iris.rds")

sessionInfo()

knitr::opts_chunk$set(results='hide', fig.path='img/r-lesson-')

#########

3 + 5
12/7

genome_length_mb <- 4.6

genome_length_mb

genome_length_mb / 978.0

genome_length_mb <- 3000.0
genome_length_mb / 978.0

genome_weight_pg <- genome_length_mb / 978.0

genome_length_mb <- 100

mass <- 47.5           # mass?
age  <- 122            # age?
mass <- mass * 2.0     # mass?
age  <- age - 20       # age?
massIndex <- mass/age  # massIndex?

### Vectors and data types

lengths <- c(4.6, 3000, 50000)
lengths

species <- c("ecoli", "human", "corn")
species

length(lengths)
length(species)

class(lengths)
class(species)

str(lengths)
str(species)

lengths <- c(lengths, 90) # adding at the end
lengths <- c(30, lengths) # adding at the beginning
lengths


# Looking at Metadata

metadata <- read.csv('~/Desktop/Ecoli_metadata.csv')

(metadata <- read.csv('~/Desktop/Ecoli_metadata.csv'))

head(metadata)

str(metadata)

# Inspecting `data.frame` objects

### Factors

sex <- factor(c("male", "female", "female", "male"))

levels(sex)
nlevels(sex)

expression <- factor(c("low", "high", "medium", "high", "low", "medium", "high"))
levels(expression)
expression <- factor(expression, levels=c("low", "medium", "high"))
levels(expression)
min(expression) ## doesn't work
expression <- factor(expression, levels=c("low", "medium", "high"), ordered=TRUE)
levels(expression)
min(expression) ## works!

### Converting factors

f <- factor(c(1, 5, 10, 2))
as.numeric(f)               ## wrong! and there is no warning...
as.numeric(as.character(f)) ## works...
as.numeric(levels(f))[f]    ## The recommended way.

### Challenge

## Question: How can you recreate this plot but by having "control"
## being listed last instead of first?
exprmt <- factor(c("treat1", "treat2", "treat1", "treat3", "treat1", "control",
                   "treat1", "treat2", "treat3"))
table(exprmt)
barplot(table(exprmt))

exprmt <- factor(exprmt, levels=c("treat1", "treat2", "treat3", "control"))
barplot(table(exprmt))

# source("setup.R")
metadata <- read.csv("data/Ecoli_metadata.csv")

## The data.frame class

some_data <- read.csv("data/some_file.csv", stringsAsFactors=FALSE)

example_data <- data.frame(animal=c("dog", "cat", "sea cucumber", "sea urchin"),
                           feel=c("furry", "furry", "squishy", "spiny"),
                           weight=c(45, 8, 1.1, 0.8))
str(example_data)

example_data <- data.frame(animal=c("dog", "cat", "sea cucumber", "sea urchin"),
                           feel=c("furry", "furry", "squishy", "spiny"),
                           weight=c(45, 8, 1.1, 0.8), stringsAsFactors=FALSE)
str(example_data)

##  There are a few mistakes in this hand crafted `data.frame`,
##  can you spot and fix them? Don't hesitate to experiment!

author_book <- data.frame(author_first=c("Charles", "Ernst", "Theodosius"),
                                author_last=c(Darwin, Mayr, Dobzhansky),
                                year=c(1942, 1970))

## Can you predict the class for each of the columns in the following example?
## Check your guesses using `str(country_climate)`. Are they what you expected?
##  Why? why not?
country_climate <- data.frame(country=c("Canada", "Panama", "South Africa", "Australia"),
                              climate=c("cold", "hot", "temperate", "hot/temperate"),
                              temperature=c(10, 30, 18, "15"),
                              north_hemisphere=c(TRUE, TRUE, FALSE, "FALSE"),
                              has_kangaroo=c(FALSE, FALSE, FALSE, 1))


## Indexing and sequences

expression[2] # what level of expression is in the second element of the vector?
expression[c(3, 2)]
expression[2:4]
expression[c(3,2, 2:4)] # combining both what do you get?

seq(1, 10, by=2)
seq(5, 10, length.out=3)       # equal breaks of sequence into vector length = length.out
seq(50, by=5, length.out=10)   # sequence 50 by 5 until you hit vector length = length.out
seq(1, 8, by=3)                # sequence by 3 until you hit 8

metadata[1, 1]   # first element in the first column of the data frame
metadata[1, 6]   # first element in the 6th column
metadata[1:3, 7] # first three elements in the 7th column
metadata[3, ]    # the 3rd element for all columns
metadata[, 7]    # the entire 7th column
head_meta <- metadata[1:6, ] # surveys[1:6, ] is equivalent to head(surveys)

### The function `nrow()` on a `data.frame` returns the number of
### rows. Use it, in conjuction with `seq()` to create a new
### `data.frame` called `surveys_by_10` that includes every 10th row
### of the survey data frame starting at row 10 (10, 20, 30, ...)

meta_by_2 <- metadata[seq(2, nrow(metadata), by=2), ]

# Indexing and sequences (within a `data.frame`)

metadata$strain

metadata[, c("strain", "clade")]

# source("setup.R")
metadata <- read.csv("~/Desktop/Ecoli_metadata.csv")

install.packages("dplyr") ## install

library("dplyr")          ## load

select(metadata, sample, clade, cit, genome_size)

filter(metadata, cit == "plus")

metadata %>%
  filter(cit == "plus") %>%
  select(sample, generation, clade)

meta_citplus <- metadata %>%
  filter(cit == "plus") %>%
  select(sample, generation, clade)

meta_citplus

### Challenge
# Using pipes, subset the data to include rows where the clade is 'Cit+'. Retain columns
# `sample`, `cit`, and `genome_size.`

### Mutate

metadata %>%
  mutate(genome_bp = genome_size *1e6)

metadata %>%
  mutate(genome_bp = genome_size *1e6) %>%
  head

metadata %>%
  mutate(genome_bp = genome_size *1e6) %>%
  filter(!is.na(clade)) %>%
  head

### Split-apply-combine data analysis and the summarize() function


metadata %>%
  group_by(cit) %>%
  tally()

metadata %>%
  group_by(cit) %>%
  summarize(mean_size = mean(genome_size, na.rm = TRUE))

metadata %>%
  group_by(cit, clade) %>%
  summarize(mean_size = mean(genome_size, na.rm = TRUE))

metadata %>%
  group_by(cit, clade) %>%
  summarize(mean_size = mean(genome_size, na.rm = TRUE)) %>%
  filter(!is.na(clade))

metadata %>%
  group_by(cit, clade) %>%
  summarize(mean_size = mean(genome_size, na.rm = TRUE),
            min_generation = min(generation))

## Data vizualization

metadata <- read.csv('~/Desktop/Ecoli_metadata.csv')

# Basic plots in R

genome_size <- metadata$genome_size

## Scatterplot

plot(genome_size)

plot(genome_size, pch=8)

plot(genome_size, pch=8, main="Scatter plot of genome sizes")

## Histogram

hist(genome_size)

##Boxplot

boxplot(genome_size ~ cit, metadata)

boxplot(genome_size ~ cit, metadata,  col=c("pink","purple", "darkgrey"),
        main="Average expression differences between celltypes", ylab="Expression")

# Advanced figures (`ggplot2`)

library(ggplot2)

ggplot(metadata) # note the error

ggplot(metadata) +
  geom_point() # note what happens here

ggplot(metadata) +
  geom_point(aes(x = sample, y= genome_size))

ggplot(metadata) +
  geom_point(aes(x = sample, y= genome_size, color = generation, shape = cit), size = rel(3.0)) +
  theme(axis.text.x = element_text(angle=45, hjust=1))


## Histogram

ggplot(metadata) +
  geom_bar(aes(x = genome_size))

## default histogram

ggplot(metadata) +
  geom_bar(aes(x = genome_size), stat = "bin", binwidth=0.05)

## Boxplot

ggplot(metadata) +
  geom_boxplot(aes(x = cit, y = genome_size, fill = cit)) +
  ggtitle('Boxplot of genome size by citrate mutant type') +
  xlab('citrate mutant') +
  ylab('genome size') +
  theme(panel.grid.major = element_line(size = .5, color = "grey"),
          axis.text.x = element_text(angle=45, hjust=1),
          axis.title = element_text(size = rel(1.5)),
          axis.text = element_text(size = rel(1.25)))


## Writing figures to file

pdf("figure/boxplot.pdf")

ggplot(example_data) +
  geom_boxplot(aes(x = cit, y =....) +
  ggtitle(...) +
  xlab(...) +
  ylab(...) +
  theme(panel.grid.major = element_line(...),
          axis.text.x = element_text(...),
          axis.title = element_text(...),
          axis.text = element_text(...)
  ))

dev.off()

download.file("https://ndownloader.figshare.com/files/2292169", "data/portal_data_joined.csv")
