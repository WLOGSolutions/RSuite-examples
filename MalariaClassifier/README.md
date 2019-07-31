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

As for a person who has never had anything to do with Python, building my first convolutional neural network (CNN) was a pretty pleasant experience. All thanks to the fact that, although I was using Python all the time, I didn’t have to use Python’s code at all! How was it possible? The aim of this article is for you to find out and to be able to recreate my steps.

There are a few names you need to be aware of first (I will expand upon them later):

1. RSuite - a great package for reproducible projects with controlled dependencies and configuration. Apart from this, one of the biggest advantages of an RSuite project is the fact that it is really clearly written. Everyone is able to understand what's going on in particular parts of it due to the way how they are divided.

2. Keras - a powerful Python package which enables to build complicated machine learning models (in particular neural networks) with relatively little effort. It’s a great tool and if you don’t know or simply don’t like Python and prefer R instead, as for today there are three ways to use Keras package in R.

3. Reticulate - an R interface to Python which made all of it possible. Thanks to it, we can take the most of the two languages. It combines the power of R and Python, making machine learning the most accessible it's ever been.

We will combine all of the above tools and build a Malaria Classifier. More specifically we will build a convolutional neural network detecting whether the patient is infected or not based on the image of the patient's drop of blood. Curious how to do it? Let's find out!


## Table of contents

## Shortcuts

+ If you want to know the theory behind the project first, click [link to the second article]()
+ If you are already familiar with RSuite and you just want to know how to use Python in an RSuite project, click [here](#creating-a-python-environment)
+ If you don't want to create the project yourself, but you want to see how it works, click [here]()


## Preliminary requirements

This particular project was created on MacOS however all of the needed tools are also available for Windows and Linux. 
To be able to recreate the case, your computer needs to be equipped with:

- R [download here](https://www.r-project.org)
- RStudio [download here](https://www.rstudio.com/products/rstudio/download/)
- Miniconda [download here](https://docs.conda.io/en/latest/miniconda.html)
- R Suite CLI [download here](https://rsuite.io/RSuite_Download.php)
- Git [download here](https://git-scm.com/downloads)

I won't be describing the installation of R, RStudio and Miniconda in detail. There are many tutorials on the Internet which provide you with a step by step description. So take your time, install them properly and when everything is ready, you can move on to the next step - installing RSuite. I will help you with it, although there is nothing to fear - the installation is really easy.

## RSuite installation
After downloading R Suite CLI you're ready to install it. The easiest way is to open the terminal and type:
```
> rsuite install 
```
in your console. When RSuite is installed, you need to download and install Git. RSuite forces you to use git, and while it may seem unnecessary to you at first, it's actually pretty useful. You don't want to lose all your work due to an unexpected system error, do you?
When Git is installed on your computer, RSuite will automatically connect with it when starting a new project. Speaking of projects... How to create them? You'll learn it in a moment!

## Creating a project
There are three ways of managing projects in RSuite:

- Command Line Interface
- Using R functions
- Using RStudio Add-in

For me, the easiest option is the third one, so this is the one I'm going to describe. If you want to know something about the other ways, click [here](https://www.slideshare.net/WLOGSolutions/large-scale-machine-learning-projects-with-r-suite-82007142).

To create a new project, open RStudio and click Addins at the top of the page. What you will see should look like this:

![Starting an RSuite project pt 1](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/Start_proj_1.png){width=750px}

Then you need to click "Start project" and fill in the necessary blanks such as the name of the project and its directory:

![Starting an RSuite project pt 2](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/Start_proj_2.png){width=300px}


Then you simply click "Start" and voilà! Your first RSuite project is created.

Let's take a quick look at the structure of the project:

![](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/proj_structure.png){width=300px}


There are three extremely important folders there:

1. Deployment - you will find two subfolders in here: libs and sbox. Libs is the folder where all packages which are needed to run your project are stored. Because of this you don't need to be afraid that somebody won't be able to open your project on their computer - every package they'll need to use will be installed automatically from this folder. Sbox is a folder where you store packages which only you need while creating a project. Let's say you want to plot something using ggplot2, but you don't need to include the plot in your project. Then you can install it locally, it will be stored in sbox and the person you've sent your project to, won't have it installed. To install a package in sbox, you just need to use a usual R function "install_packages()" in an RStudio console. Because you're in the project, it will be installed in sbox. As for how to install packages inside a project, we'll get to this later.

2. Packages - this is where project packages are stored. Each of the packages should have different functionality so as to make the project clear and easy to understand. So for example one package is used for exploring and preparing the data, another is used for modelling it. In the packages, you don't store the main code. There, you just declare R packages needed for this particular part of the project (in the DESCRIPTION file) and define needed functions (in a subfolder named R).

3. R - it's a folder where the masterscripts are stored. These are R Script documents whose aim is only to execute the code on the data. So firstly you define functions in packages, then you use them in master scripts. This way the code in a masterscript is short and easy to read. And if you want to learn more about the functions which were used there, you can always look them up in a documentation of the package!

## Developing packages
So, by now you're probably extremely curious how to create and develop a package in RSuite. Remember how we started a project? Just below "Start project" in Addins menu, you can see an instruction "Start package in project". Just click it and the rest is pretty intuitive. You need to name the package (best if the name corresponds to what the package does), the project folder will be set automatically to the project you're currently working on. Then click "Start" and your package is created.
Take look at the structure of your newly created package:

![Package structure](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/pkg_structure.png){width=300px}

Again, two important things here:

1. R folder - this is where you should save the R Script files with the functions you'll be using later in masterscripts.

2. DESCRIPTION file - this is where all important information is stored and the most important from all of them: the names of the R packages which you want to use in your project. You can declare which packages are needed in Imports:

![Description file](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/description.png){width=300px}

The default in Imports is set only to logging. You can add your packages after a comma, just like I did with data.table. 

After adding new packages to imports, you need to go back to Addins menu and click "Install dependencies". You'll know that everything was installed correctly when you see such message in your console:

![install_deps](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/install_deps.png){width=400px}

After each dependencies installation, in order for them to work, you need to restart R session. It's like with any other actualisation - you need to restart the system so as to implement the changes.

So, when you have all (at least for now) of the needed packages installed, you can start building your package. You'll probably want to add some functions which will be used later in the masterscripts. As I mentioned earlier, you need to have them in R files, saved in R folder in your package. So let's look at the example:

![Example function](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/function.png){width=300px}

This R script file is saved in my project package called "Example". Now, if I want to use it in my masterscript, I need to build this package first. I can do it using Addins command "Build packages" (I can do it, because all of the declared dependencies are installed. If you add some new dependencies, you need to install them before building a package). After clicking "Build" in a window which pops up, you should see something like this in your console:

![Installed package](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/pkg_installed.png){width=400px}

You have a package, a function, now you're ready to develop a masterscript!

## Developing masterscripts

So, each masterscript should be an R Script file (or Rmarkdown) where you execute your functions. When you go to R folder in the main folder of your project, you will find a file called "master.R". You have to copy everything what's inside it and place it at the beginning of every masterscript in your project. This is because this piece of code connects the packages with the masterscripts. 
As I told you previously, all of the  masterscripts should be saved in R folder in your project. I will show you my examplary masterscript and explain why it looks like this. 

![Masterscript](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/master.png){width=400px}

The first 18 lines is this beginning of each masterscript I told you about. One thing to mention here: config file. At first in your project there is only config_templ.txt. After running the beginning of the script for the first time, config.txt pops up in your main project folder. And this two files are what it takes to make the project a little more interactive. Config.txt is for you. In my examplary project it looks like this:

![Config.txt](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/config.png){width=400px}

This is where you can declare paths to folders, names, numbers etc. But these are the things that don't have to, or sometimes can't, be same for two different computers. The person who receives your project has to declare the paths to folders themselves and basically they can declare anything else you want them to (you'll see later how I manipulated with the seize of the samples using config). So anything you add to your config file, should be briefly descripted in config_templ.txt. For example, my config_templ.txt looks like this:

![Config_templ.txt](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/config_templ.png){width=400px}

When it comes to your piece of code in a masterscript, one of the things you need to know is how to request packages that you build. It's nothing more than using a usual R functions: "library()" or "request()". Then, all of the functions from the loaded package are ready to use! 
Another important thing: try to avoid requiring packages which aren't project packages in the masterscripts. Declare them in the description file in one of the packages, and you can use them as usual calling your built-in package. You can even build a special package dedicated to installing dependencies you need. This way you can be sure that even if there have been some updates to the packages, erverything will run properly. 

I think that by now you know how to build and develop an RSuite project. I can give you one more tip, though. While developing a project, you may want to see how your newly created functions work, what results they give. Instead of clicking "Build packages" all the time, you can use a simple command from devtools package:

```
devtools::load_all(file.path(script_path, "..", "packages", "name_of_the_package"))
```

Thanks to doing so, you can try out all of the newly created functions without building packages all the time. Although you have to remember to build packages before finishing the project - the changes which load_all() commits are local, they won't be present after zipping your project. 


##Zipping

After finishing your project, you may want to save its current version. Thanks to it you'll be able to develop your work without loosing the possibility to start from the point you left. In order to do it, choose "Build ZIP" from the Addins menu. It will require to specify the version of your project. You have to type it and the rest is done automatically.

Inside a ZIP file, you'll find, among others:

- R - a folder where the masterscripts are stored
- libs - a folder with the packages
- logs - a folder for logs
- config_templ.txt - a file which you have to fill properly

Now you know everything about RSuite projects. There's nothing left for me than to show you how to use combine R and Python in an RSuite project!

## Creating a Python environment

I will describe what you need to do to create a local Python environment inside an RSuit project. If you want to know how to do it from the console, please click [here](https://www.slideshare.net/WLOGSolutions/how-to-lock-a-python-in-a-cage-managing-python-environment-inside-an-r-project). My description will be slightly different than presented there, co you can choose the preferred method.  

When you have installed conda on your computer, you're halfway to create a local Python environment. We can divide the whole process into a few steps, so that it would be more clear:

1. Add system requirements to one of the existing packages. 
In one of the packages in the description file, require conda as well as needed Python's packages. It should look like this (of course the packages are examplary): 

![System requirements](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/sysreqs.png){width=400px}

You can require specific versions of the needed packages using "=", "<", ">", ">=", "<=" operators and the number of the required version.

2. Then, you need to install the requirements. For this open a new terminal (from RStudio -> Tools -> Terminal -> New Terminal) and type:

```
> Rsuite sysreqs install
```
3. When the installation is completed, you have to "force" your project to use local Python. You can do it by typing
```
reticulate::use_python(python = dirname(...), require = TRUE)
```
in your masterscript (just after the beginning). 

And... That's it! You can now use Keras in it's full power. 

## Ways to use Keras in R

Basically there are three ways of using Keras in R:

1. Keras R package. It follows R syntax, so it's most natural for R users. It still uses reticulate and runs Python under the hood, though.

2. Reticulate interface. It carries out a conversion between Python and R. 

3. Running raw Python. It's handy when you already have some script in Python, but it's hard to control Python script execution from R.

In my project, I used the first option, so in a moment you will see how it works. There is nothing left to do than to create your first Malaria Classifier using R and RSuite!

## The Malaria project step by step

I will guide you through the creation of the project step by step. There are two things that I strongly recommend to do first, though:

+ Click [here - link to the whole project on github]() and take a look at the structure of the project. See what is inside each of the folders - it will be easier for you to understand what we will be doing while creating the project.
+ Click [here - link to the second article]() and read about the theory behind the project - you will know what particular functions do and why I chose to use them. It will help you understand the project more. 

To create exactly the same Malaria Classifier I built, follow these steps:

1. Create an RSuite project called Malaria_CNN
2. Add package: DataPreparation
3. Add dependencies: all needed dependencies you can see on the screenshot below
4. Install dependencies

![Steps 1 - 4](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/first_four.jpg)

5. Add package: modeling
6. Add dependencies: all needed dependencies you can see on the screenshot below
7. Install dependencies

![Steps 5 - 7](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/second_three.jpg)

8. Add system requirements to the DESCRIPTION file of one of the existing packages
9. Install system requirements


![Steps 8 - 9](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/third_two.jpg)


10. Develop DataPreparation package.
    i. Create a new RScript file and name it "data_prep". Save it in the package DataPreparation in a folder named "R". 
    ii. Copy the content of data_prep from [link to data_prep file](link to data_prep file)
    iii. Build packages
11. Develop modeling package
    i. Create a new RScript file and name it "api_modelling". Save it in the package modeling in a folder named "R"
    ii. Copy the content of modeling file from [link to modeling file](link to modeling file)
    iii. Build packages  
12. Set the config.txt file. Add paths to the needed folders and the numbers of samples for each group
13. Set the config_templ.txt file. Describe what you did in the config.txt file
14. Create and develop a masterscript
    i. Create a new RScript file and name it "m_model". Save it in a folder named "R" in your project.
    ii. Copy the content of the masterscript from [link to the masterscript](link to the masterscript)
    iii. Run the file. 
15. (OPTIONAL) Create a ZIP file

## How to unzip the project - configuration

If you've just built your own Malaria Classifier, you can skip this section. For those, who haven't:

Under this [link](link to a zipped file) you can find a zipped RSuite project containing Malaria Clasiffier. Download it to your computer and do as follows:

1. Unzip the project. You will see three folders: libs, logs and R and the config_templ.txt file.
2. Set the config_templ.txt file. It should consist of:

![config_templ](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/configtmpl.png)

Where letters m-r indicate which photos should be taken to each of the datasets. So images 1-m (from each category, parasitized and uninfected) are training samples, n-o are validation samples and p-r are testing samples.

To give you an example, my config file looks like this:

![my config](/Users/urszulabialonczyk/Documents/Wlog/Images_for_description/confignew.png)

3. In R folder, you will find "m_model.R" file. Open it and run in RStudio. Don't worry if it takes a long time to build the model - the time needed depends on the system you use.
4. After the model has been built, you can find it in the folder which you declared under "new_folder_path" in the config_templ.txt. You can use it anytime you want calling "loadModel()" function from the "modeling" package. 

## Summary

This is all I wanted to teach you for now. If you're interested in learning more about machine learning in RSuite projects, check the following links:

+ Links to other projects
