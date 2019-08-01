---
title: <p align="center"> Building a Malaria Classifier from scratch using R and RSuite </p>
author: "Urszula Bialonczyk"
date: "7/25/2019"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Introduction

Imagine you're a data scientist working in a science lab. One day you analise some data and you realise that the number of people affected by malaria has started to raise dramatically over the past few months. You know nothing about biology, so you can't help with curing it, but you're good at detecting patterns, so you may be able to build a model which recognises wether a person is infected or not. You ask around a little and you learn that to check the patient's health status, the first step is to analise their drop of blood. This is a quite good information, because you know that to classify images you need to bulild a convolutional neural network. You encounter two problems, though. First, you know that the best results in classifing images can be obtained using Python's library Keras. The problem is, you've been working with R your whole life and there is no time to learn Python now. Second, your coworkers have to be able to use your solution and since they are biologists, they know nothing about R or any other programming language. So what you need to do is to build an application in R which gives as good results as if it was built in Python, which can be used on different computers and which is pretty simple in deployment. All of the above at the same time. Seems impossible?
You're a pretty good data scientist, so you don't give up that easily. You dig a little deeper and find a few names that will enable you to complete your task:

1. RSuite - an R package for reproducible projects with controlled dependencies and configuration. Apart from this, one of the biggest advantages of an RSuite project is the fact that it is really clearly written. Everyone is able to understand what's going on in particular parts of it due to the way how they are divided.

2. Reticulate - an R interface to Python which made all of it possible. Thanks to it, we can take the most of the two languages. It combines the power of R and Python, making machine learning the most accessible it's ever been.

3. Keras - a powerful Python package which enables to build complicated machine learning models (in particular neural networks) with relatively little effort. It’s a great tool and if you don’t know or simply don’t like Python and prefer R instead, as for today there are three ways to use Keras package in R.

You can combine all of the above tools and build a Malaria Classifier in R. More specifically, you are about to build a convolutional neural network detecting whether the patient is infected or not based on the image of the patient's drop of blood. 
Lucky for you, I've already filfilled such task, so I will guide you through preparation and deployment of the project. I hope that after this tutorial you will be able to create similar solution all by yourself.


## Table of contents

## Shortcuts



## Preliminary requirements

This particular project was created on MacOS however all of the needed tools are also available for Windows and Linux. 
To be able to recreate the case, your computer needs to be equipped with:

- R [download here](https://www.r-project.org)
- RStudio [download here](https://www.rstudio.com/products/rstudio/download/)
- Miniconda [download here](https://docs.conda.io/en/latest/miniconda.html)
- R Suite CLI [download here](https://rsuite.io/RSuite_Download.php)
- Git [download here](https://git-scm.com/downloads)
- Malaria Cell Images Dataset [download here](https://www.kaggle.com/iarunava/cell-images-for-detecting-malaria)

I won't be describing the installation of R, RStudio, Git and Miniconda in detail. There are many tutorials on the Internet which provide you with a step by step description. So take your time, install them properly and when everything is ready, you can move on to the next step - installing RSuite. I will help you with it, although there is nothing to fear - the installation is really easy.

## RSuite installation
After downloading R Suite CLI you're ready to install it. The easiest way is to open the terminal and type:
```
> rsuite install 
```
in your console. When RSuite is installed, you need to download and install Git. RSuite forces you to use GIT, so you need to install it before starting a project.
When Git is installed on your computer, RSuite will automatically put your project under git control when starting it. Speaking of projects... Everything's ready, so you're now able to build your first malaria classifier in R.

## Malaria project step by step

## Creating a project: MalariaClassifier

First, we are going to create a new RSuite project. We will call it "MalariaClassifier". How to do it? There are three ways of managing projects in RSuite:

- Command Line Interface
- Using R functions
- Using RStudio Add-in

For me, the easiest option is the third one, so this is the one I'm going to describe. If you want to know something about the other ways, click [here](https://www.slideshare.net/WLOGSolutions/large-scale-machine-learning-projects-with-r-suite-82007142).

To create a new project, open RStudio and click Addins at the top of the page. What you will see should look like this:

![Starting an RSuite project pt 1](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/Start_proj_1.png){width=750px}

Then you need to click "Start project" and fill in the necessary blanks such as the name of the project and its directory:

![Starting an RSuite project pt 2](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/MalariaClassifierprojstart.png){width=300px}


Then you simply click "Start" and voilà! Your first RSuite project is created.

Let's take a quick look at the structure of the project:

![Project Structure](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/projstr.png){width=300px}


There are three extremely important folders there:

1. Deployment - you will find two subfolders in here: libs and sbox. Libs is the folder where all packages which are needed to run your project are stored. Because of this you don't need to be afraid that somebody won't be able to open your project on their computer - every package they'll need to use will be installed automatically from this folder. Sbox is a folder where you store packages which only you need while creating a project. Let's say you want to plot something using ggplot2, but you don't need to include the plot in your project. Then you can install it locally, it will be stored in sbox and the person you've sent your project to, won't have it installed. To install a package in sbox, you just need to use a usual R function "install_packages()" in an RStudio console. Because you're in the project, it will be installed in sbox. As for how to install packages inside a project, we'll get to this later.

2. Packages - this is where project packages are stored. Each of the packages should have different functionality so as to make the project clear and easy to understand. So, for example, in our case one package is used for exploring and preparing the data, another is used for modelling it. In the packages, you don't store the main code. There, you just declare R packages needed for this particular part of the project (in the DESCRIPTION file) and define needed functions (in a subfolder named R).

3. R - it's a folder where the masterscripts are stored. These are R Script documents whose aim is only to execute the code on the data. So firstly you define functions in packages, then you use them in master scripts. This way the code in a masterscript is short and easy to read. And if you want to learn more about the functions which were used there, you can always look them up in a documentation of the package!

## Creating packages in project: DataPreparation

We've created a project, it's time build in its first functionality. We are going to create a package called "DataPreparation". It will serve as a place in a project, where we will write functions needed to prepare the data for modelling. 
How to create a package? Similarily to starting a project. Just below "Start project" in the Addins menu, you can see an instruction "Start package in project". Just click it and the rest is pretty intuitive. You need to name the package, the project folder will be set automatically to the project you're currently working on: 

![DataPreparation package](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/DataPreppkg.png){width=300px}

Then click "Start" and your package is created.

Take look at the structure of your newly created package:

![Project Structure](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/DataPrepstr.png){width=300px}


Again, two important things here:

1. DESCRIPTION file - this is where all important information is stored and the most important from all of them: the names of the R packages which you want to use in your project. You can declare which packages are needed in Imports.

Now we have to fill in our description. In our project, in the DESCRIPTION file of DataPreparation, we should import the following packages: 

![DataPreparation DESCRIPTION](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/dataprepdesc.png){width=300px}

The default in Imports is set only to logging. You can add your packages after a comma, just like I did. 

After adding new packages to Imports, you need to go back to Addins menu and click "Install dependencies". You'll know that everything was installed correctly when you see such message in your console:

![install_deps](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/install_deps.png){width=400px}

After each dependencies installation, in order for them to work, you need to restart R session. It's like with any other actualisation - you need to restart the system so as to implement the changes.

2. R folder - this is where you should save the R Script files with the functions you'll be using later in masterscripts. We will get to this later.


Now we have a package, where we will prepare images for further modelling. That's why we can add second functionality - modelling.

## Creating packages in project: MalariaModel

We need to build another package in project. We will call it "MalariaModel" and use it to write modelling functions. We will follow exactly the same steps as before with DataPreparation package.

So what we need to do first, is to go to Addins menu and to click "Start package in project":

![MalariaModel package](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/MalariaModel.png){width=300px}

After creating a new package, we need to add a few imports in the package's DESCRIPTION file:

![MalariaModel DESCRIPTION](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/MalariaModeldesc.png){width=300px}

We added new dependencies, now we need to install them. In order to do it, go to Addins menu and click "Install dependencies".
When all dependencies are successfully installed, restart R session so as to save changes. 

## Adding a new folder in project: Work

Because you want to build a model, then score it and, in addition to it, the whole code will be executed on server, you need to save the results somewhere. The best option is to create a new folder inside a project. It won't be seen by your coworkers unless you specify it in PARAMETERS, so it's the best method to store the results in one place. 

To create a folder, click a "New folder" icon in your project menu on the right side of the screen in RStudio:

![New folder](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/newfolder.png)

A new window will pop up, asking you to name the folder:

![New folder](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/newfolder2.png)

After creating it, please copy .gitignore file there. This is because GIT doesn't allow you to store empty folders. Now, the content of the Work folder is supposed to have this structure:

![New folder](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/gitignore.png)

## Creating Python environment

In order to use Keras in R, you need to create a local Python environment inside an RSuit project. If you want to know how to do it from the console, please click [here](https://www.slideshare.net/WLOGSolutions/how-to-lock-a-python-in-a-cage-managing-python-environment-inside-an-r-project). My description will be slightly different than presented there, so you can choose the preferred method.  

When you have installed conda on your computer, you're halfway to create a local Python environment. We will do it in 3 steps:

1. Add system requirements to DataPreparation package. 
In DataPreparation package, in the DESCRIPTION file, require conda as well as all of the needed Python's packages. It should look as follows: 

![System requirements](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/sysreqs.png){width=400px}

2. Install the requirements.
For this open a new terminal (from RStudio -> Tools -> Terminal -> New Terminal) and type:
```
> Rsuite sysreqs install
```
3. Force your project to use local Python. 
You can do it by typing
```
reticulate::use_python(python = dirname(...), require = TRUE)
```
in your masterscript (just after the beginning). 

And... That's it! You can now use Keras in it's full power. 

Since we have the framework of our Malaria Classifier project, we can move on to developing our packages now.

## Developing packages in project: DataPreparation

We need to create a new RScript file (RStudio menu -> File -> New file -> R Script), where we will write all of the functions needed for preparing the images for modelling. We are going to name the file "data_prep.R". The content of the file you can copy from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/packages/DataPreparation/R/data_prep.R). Make sure you save it in DataPreparation's folder R. Take a look on how the beginning of the file is supposed to look like:

![data_prep file](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/data_prep.png){width=300px}

When you have all (at least for now) of the needed dependencies installed, and you created "data_prep.R" file, in order to use DataPreparation package, you have to build it first. You can do it by going to Addins menu and clicking "Build Packages". A new window will pop up:

![data_prep file](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/build.png){width=300px}

Click "Build" and if everything has worked correctly, you should see a following message in your console:

![data_prep file](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/1pkginst.png){width=300px}

## Developing packages in project: MalariaModel

We need to add another RScript file, where all of our modelling functions will be stored. We will call it "api_modelling.R".
The content of the file you can copy from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/packages/MalariaModel/R/api_modelling.R).
Remember to save the file in R folder in MalariaModel package. Take a look at the first lines of the code:

![MalariaModel DESCRIPTION](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/api_modelling.png){width=300px}

The next step is to build the package. Again, go to Addins menu and choose "Build packages". When everything has been installed correctly, you should see this message:

![MalariaModel DESCRIPTION](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/2pkginst.png){width=300px}

We have all of the needed packages, time to create a file, where we will use them.

## Creating and developing a masterscript: m_model.R

We need to create a new RScript file called "m_model.R". We will train our model there. Because it is a masterscript, will save it in R folder in our MalariaClassifier project. The content of the masterscript, you can copy from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/R/m_model.R). 

## Creating and developing a masterscript: m_score.R

The next step is to create the second masterscript, called "m_score.R". As the name suggests, this is where we will evaluate the model trained in "m_model.R". Again, we will save it in R folder in MalariaClassifier project. The content of the script, you can copy from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/R/m_score.R). 

## config.txt and config_templ.txt file

Before being able to run your masterscripts successfully, you need to take care of setting two files: config_templ.txt and cofig.txt.

Config_templ.txt is a file where you briefly describe what should be included in config.txt. You should fill it in as follows:

![Config_templ.txt](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/configtempl.png){width=300px}

This is very important, because this is what your coworkers will get and that's how they will know what they should write in config.txt file. 

Config.txt file is where you declare paths to folders, number of samples etc. At first there is no such file in your project folder, it will appear after running the beginning of your masterscript code:

![Masterscript beginning](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/masterbegin.png){width=300px}

After running the code, open config.txt file which appeared in MalariaClassifier project folder and fill it similarily to mine:

![Config.txt](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/config.png){width=300px}

Of course all of the paths to folders are supposed to be the paths to folders where YOU store your data.  

## Running the project

So now we have everything we need to build a malaria classifier in R. The only thing you need to do, is to run both of the masterscripts: first "m_model.R", then "m_score.R". Don't worry if it takes a while to train your model - the amount of time needed depends on the hardware you use. When you installed everything you needed properly and declared the paths to folders as you were supposed to, after executing the whole code, this should appear in your Work folder:

<screenshot of the work folder>

## Deployment

