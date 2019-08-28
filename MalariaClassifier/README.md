# Building a Malaria Classifier from scratch using [R](https://r-project.org), [R Suite](https://rsuite.io) and [R Interface to Keras](https://keras.rstudio.com/)

Author: Urszula Białończyk

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->

## Table of Contents ##

- [Introduction](#introduction)
- [Preliminary requirements](#preliminary-requirements)
    - [RSuite installation](#rsuite-installation)
    - [Git installation](#git-installation)
- [Malaria project step by step](#malaria-project-step-by-step)
    - [Creating a R Suite project: MalariaClassifier](#creating-a-r-suite-project-malariaclassifier)
    - [Creating packages in project: DataPreparation](#creating-packages-in-project-datapreparation)
    - [Creating packages in project: MalariaModel](#creating-packages-in-project-malariamodel)
    - [Adding a new folder in project: Work](#adding-a-new-folder-in-project-work)
    - [Adding a new folder in project: Models](#adding-a-new-folder-in-project-models)
    - [Creating Python environment](#creating-python-environment)
    - [Developing packages in project: DataPreparation](#developing-packages-in-project-datapreparation)
    - [Developing packages in project: MalariaModel](#developing-packages-in-project-malariamodel)
    - [Creating and developing a masterscript: m_train_model.R](#creating-and-developing-a-masterscript-m_train_modelr)
    - [Creating and developing a masterscript: m_score_model.R](#creating-and-developing-a-masterscript-m_score_modelr)
    - [Creating and developing a masterscript: m_validate_model.R](#creating-and-developing-a-masterscript-m_validate_modelr)
    - [config.txt and config_templ.txt file](#configtxt-and-configtempltxt-file)
    - [Running the project](#running-the-project)
    - [Deployment: building deployment package](#deployment-building-deployment-package)
    - [Deployment: installing deployment package](#deployment-installing-deployment-package)
    - [Summary](#summary)
- [Understanding malaria project step by step](#understanding-malaria-project-step-by-step)
    - [Introduction](#introduction-1)
    - [Understanding the task](#understanding-the-task)
    - [Understanding package: DataPreparation](#understanding-package-datapreparation)
    - [Understanding package: MalariaModel](#understanding-package-malariamodel)
        - [Functions needed to create the model](#functions-needed-to-create-the-model)
        - [Functions used for saving and loading files](#functions-used-for-saving-and-loading-files)
    - [Understanding masterscript: m_train_model.R](#understanding-masterscript-m_train_modelr)
    - [Understanding masterscript: m_validate_model.R](#understanding-masterscript-m_validate_modelr)
    - [Understanding masterscript: m_score_model.R](#understanding-masterscript-m_score_modelr)
- [Results](#results)    
    
<!-- markdown-toc end -->


## Introduction ##

Imagine you're a data scientist working in a science lab. One day you are asked to analise some data involving malaria and the results you obtain are horrifying: the number of people affected by this disease has started to raise dramatically over the past few months. You know nothing about biology, so you can't help with curing it, but you're good at detecting patterns, so you may be able to build a model which recognises wether a person is infected or not. You ask around a little and you learn that to check the patient's health status, the first step is to analise their drop of blood. This is a quite good information, because you know that to classify images you need to bulild a convolutional neural network. You encounter two problems, though. First, you know that the best results in classifing images can be obtained using Python's library Keras. The problem is, you've been working with R your whole life and there is no time to learn Python now. Second, your coworkers have to be able to use your solution and since they are biologists, they know nothing about R or any other programming language. So what you need to do is to build an application in R which gives as good results as if it was built in Python, which can be used on different computers and which is pretty simple in deployment. All of the above at the same time. Seems impossible?
You're a pretty good data scientist, so you don't give up that easily. You dig a little deeper and find a few names that will enable you to complete your task:

1. **R Suite** - an R package for reproducible projects with controlled dependencies and configuration. Apart from this, one of the biggest advantages of an RSuite project is the fact that it is really clearly written. Everyone is able to understand what's going on in particular parts of it due to the way how they are divided.

2. **reticulate** - an R interface to Python which made all of it possible. Thanks to it, we can take the most of the two languages. It combines the power of R and Python, making machine learning the most accessible it's ever been.

3. **Keras** - a powerful Python package which enables to build complicated machine learning models (in particular neural networks) with relatively little effort. It’s a great tool and if you don’t know or simply don’t like Python and prefer R instead, as for today there are three ways to use Keras package in R.

You can combine all of the above tools and build a Malaria Classifier in R. More specifically, you are about to build a convolutional neural network detecting whether the patient is infected or not based on the image of the patient's drop of blood. 
More than this - you will create a project divided into three parts: first responsible for preparing and training the model, second for scoring it - this is your job. The third part will be for your coworkers - it will use the models trained in the first two parts to predict the outcome of the examination.

Lucky for you, I've already fulfilled such task, so I will guide you through preparation and deployment of the project. I hope that after this tutorial you will be able to create similar solution all by yourself.

## Preliminary requirements ##

This particular project was created on MacOS however all of the needed tools are also available for Windows and Linux.  To be able to recreate the case, your computer needs to be equipped with:

- R [download here](https://www.r-project.org)
- RStudio [download here](https://www.rstudio.com/products/rstudio/download/)
- Miniconda [download here](https://docs.conda.io/en/latest/miniconda.html)
- R Suite CLI [download here](https://rsuite.io/RSuite_Download.php)
- Git [download here](https://git-scm.com/downloads)
- Malaria Cell Images Dataset [download here](https://www.kaggle.com/iarunava/cell-images-for-detecting-malaria)

I won't be describing the installation of R, RStudio, Git and Miniconda in detail. There are many tutorials on the Internet which provide you with a step by step description. So take your time, install them properly and when everything is ready, you can move on to the next step - installing RSuite. I will help you with it, although there is nothing to fear - the installation is really easy.

### RSuite installation ###

After downloading R Suite CLI and installing you're ready to install R Suite package. The easiest way is to open the terminal and type:

```
> rsuite install 
```
in your console. 

### Git installation ###

When R Suite is installed, you need to download and install Git. RSuite forces you to use GIT, so you need to install it before starting a project. When Git is installed on your computer, RSuite will automatically put your project under GIT control when starting it. Speaking of projects... Everything's ready, so you're now able to build your first malaria classifier in R.

## Malaria project step by step ##

### Creating a R Suite project: MalariaClassifier ###

First, we are going to create a new RSuite project. We will call it "MalariaClassifier". How to do it? There are three ways of managing projects in RSuite:

- Command Line Interface
- Using R functions
- Using RStudio Add-in

For me, the easiest option is the third one, so this is the one I'm going to describe. If you want to know something about the other ways, click [here](https://www.slideshare.net/WLOGSolutions/large-scale-machine-learning-projects-with-r-suite-82007142).

To create a new project, open RStudio and click Addins at the top of the page. What you will see should look like this:

![Starting an RSuite project pt 1](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/Start_proj_1.png)

Then you need to click "Start project" and fill in the necessary blanks such as the name of the project and its directory:

![Starting an RSuite project pt 2](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/MalariaClassifierprojstart.png) 

Then you simply click "Start" and voilà! Your first RSuite project is created.

Let's take a quick look at the structure of the project:

![Project Structure](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/projstr.png) 

There are three extremely important folders there:

1. **Deployment** - you will find two subfolders in here: libs and sbox. Libs is the folder where all packages which are needed to run your project are stored. Because of this you don't need to be afraid that somebody won't be able to open your project on their computer - every package they'll need to use will be installed automatically from this folder. Sbox is a folder where you store packages which only you need while creating a project. Let's say you want to plot something using ggplot2, but you don't need to include the plot in your project. Then you can install it locally, it will be stored in sbox and the person you've sent your project to, won't have it installed. To install a package in sbox, you just need to use a usual R function "install_packages()" in an RStudio console. Because you're in the project, it will be installed in sbox. As for how to install packages inside a project, we'll get to this later.

2. **Packages** - this is where project packages are stored. Each of the packages should have different functionality so as to make the project clear and easy to deploy. So, for example, in our case one package is used for exploring and preparing the data, another is used for modelling it. In the packages, you don't store the main code. There, you just declare R packages needed for this particular part of the project (in the DESCRIPTION file) and define needed functions (in a subfolder named R).

3. **R** - it's a folder where the masterscripts are stored. These are R Script documents whose aim is only to execute the code on the data. So firstly you define functions in packages, then you use them in masterscripts. This way the code in a masterscript is short and easy to read. And if you want to learn more about the functions which were used there, you can always look them up in a documentation of the package!

### Creating packages in project: DataPreparation ###

We've created a project, it's time to build in its first functionality. We are going to create a package called "DataPreparation". It will serve as a place in a project, where we will write functions needed to prepare the data for modelling. 
How to create a package? Similarily to starting a project. Just below "Start project" in the Addins menu, you can see an instruction "Start package in project". Just click it and the rest is pretty intuitive. You need to name the package, the project folder will be set automatically to the project you're currently working on: 

![DataPreparation package](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/DataPreppkg.png) 

Then click "Start" and your package is created.

Take look at the structure of your newly created package:

![Project Structure](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/DataPrepstr.png) 

Again, two important things here:

1. **DESCRIPTION file** - this is where all important information is stored and the most important from all of them: the names of the R packages which you want to use in your project. You can declare which packages are needed in Imports.

Now we have to fill in our description. In our project, in the DESCRIPTION file of DataPreparation, we should import the following packages: 

![DataPreparation DESCRIPTION](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/dataprepdesc.png) 

The default in Imports is set only to logging. You can add your packages after a comma, just like I did. 

After adding new packages to Imports, you need to go back to Addins menu and click "Install dependencies". You'll know that everything was installed correctly when you see such message in your console:

![install_deps](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/install_deps.png)

After each dependencies installation, in order for them to work, you need to restart R session in R Studio. It's like with any other actualisation - you need to restart the system so as to implement the changes.

2. **R folder** - this is where you should save the R Script files with the functions you'll be using later in masterscripts. We will get to this later.

Now we have a package, where we will prepare images for further modelling. That's why we can add second functionality - modelling.

### Creating packages in project: MalariaModel ###

We need to build another package in project. We will call it "MalariaModel" and use it to write modelling functions. We will follow exactly the same steps as before with DataPreparation package.

So what we need to do first, is to go to Addins menu and to click "Start package in project":

![MalariaModel package](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/MalariaModel.png) 

After creating a new package, we need to add a few imports in the package's DESCRIPTION file:

![MalariaModel DESCRIPTION](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/MalariaModeldesc.png) 

We added new dependencies, now we need to install them. In order to do it, go to Addins menu and click "Install dependencies".
When all dependencies are successfully installed, restart R session so as to save changes. 

### Adding a new folder in project: Work ###

Because you want to build a model, evaluate it, then use it for scoring and, in addition to this, the whole code will be executed on server, you need to save the results somewhere. The best option is to add new folders inside a project. We will start with a folder named "Work". This folder won't be seen by your coworkers, it will serve as a place where you store the evaluation results just for your information. 

To create a folder, click a "New folder" icon in your project menu on the right side of the screen in RStudio:

![New folder](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/newfolder.png)

A new window will pop up, asking you to name the folder. We will call it "Work" because we will store there the results of our work:

![New folder](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/newfolder2.png)

After creating it, please copy .gitignore file there. This is because GIT doesn't allow you to store empty folders. Now, the content of the Work folder is supposed to have this structure:

![New folder](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/gitignore.png)

### Adding a new folder in project: Models ###

Now we need to create another folder - "Models". As the name suggests, this will be the place, where we will save the trained models.

The first part is the same as in a previous section. Click "New folder", name it "Models" and copy .gitignore file there. 

There is one more step, though. This is a folder, which will contain the trained models and their improvements, used later by your coworkers to predict patients' health status. Because of this, we want to make sure, that they will get it. This is why we need to go to PARAMETERS file in the main project folder. Open it and add "Models" to Artifacts just like you can see below:

![Models in Artifacts](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/modelsArt.png)

### Creating Python environment ###

In order to use Keras in R, you need to create a local Python environment inside an RSuite project. If you want to know how to do it from the console, please click [here](https://www.slideshare.net/WLOGSolutions/how-to-lock-a-python-in-a-cage-managing-python-environment-inside-an-r-project). My description will be slightly different than presented there, so you can choose the preferred method.  

When you have installed conda on your computer, you're halfway to create a local Python environment. We will do it in 4 steps:

1. Add system requirements to DataPreparation package. 

In DataPreparation package, in the DESCRIPTION file, require conda as well as all of the needed Python's packages. It should look as follows: 

![System requirements](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/sys_reqs.png)

2. Install the requirements.

For this open a new terminal (from RStudio -> Tools -> Terminal -> New Terminal) and type:
```
> Rsuite sysreqs install
```
3. Add conda folder to Artifacts in PARAMETERS.

Go to your main project folder and open "PARAMETERS" file. Add conda to Artifacts, just like you did with "Models" folder:

![Add conda to Artifacts](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/condainart.png)

Thanks to doing so, conda will be present while deploying your package and nobody will need to worry about installing Python or any Python's packages.

4. Force your project to use local Python. 

You can do it by typing
```
if (grepl("darwin|linux-gnu", R.version$os)) {
  #Linux or MacOS
  reticulate::use_python(python = file.path(script_path, "..", "conda", "bin"), require = TRUE)
} else {
  # Windows
  reticulate::use_python(python = file.path(script_path, "..", "conda"), require = TRUE)
}

```
in your masterscript (just after the beginning). This piece of code will automatically detect whether you're operating on Windows or Linux/MacOS, as a result it will set a peroper file path. I know we haven't created any masterscripts yet, this is the only step you're supposed to fulfill later. Don't worry, I will remind you to do it. 

Since we have the framework of our Malaria Classifier project, we can move on to developing our packages now.

### Developing packages in project: DataPreparation ###

We need to create a new RScript file (RStudio menu -> File -> New file -> R Script), where we will write all of the functions needed for preparing the images for modelling. We are going to name the file "data_prep.R". The content of the file you can copy from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/packages/DataPreparation/R/data_prep.R). Make sure you save it in DataPreparation's folder R. 

When you have all (at least for now) of the needed dependencies installed, and you created "data_prep.R" file, in order to use DataPreparation package in the masterscripts, you have to build it first. You can do it by going to Addins menu and clicking "Build Packages". A new window will pop up:

![data_prep file](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/build.png) 

Click "Build" and if everything has worked correctly, you should see a following message in your console:

![data_prep file](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/1pkginst.png) 

### Developing packages in project: MalariaModel ###

We need to add another RScript file, where all of our modelling functions will be stored. We will call it "api_modelling.R".
The content of the file you can copy from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/packages/MalariaModel/R/api_modelling.R).
Remember to save the file in R folder in MalariaModel package. 

The next step is to build the package. Again, go to Addins menu and choose "Build packages". When everything has been installed correctly, you should see this message:

![MalariaModel DESCRIPTION](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/2pkginst.png) 

We have all of the needed packages, time to create files, where we will use them.

### Creating and developing a masterscript: m_train_model.R ###

We need to create a new RScript file called "m_train_model.R". We will train our model there and declare where it is supposed to be saved. Because it is a masterscript, will save it in R folder in our MalariaClassifier project. The content of the masterscript, you can copy from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/R/m_train_model.R). Take a look at it. Do you recognize the piece of code from lines 22-28? This is the 4th step of creating Python environment (if you don't remember, go [here](#creating-python-environment))

### Creating and developing a masterscript: m_validate_model.R ###

The next step is to create the second masterscript, called "m_score_model.R". This is where we will evaluate the model trained in "m_train_model.R". Again, we will save it in R folder in MalariaClassifier project. The content of the script, you can copy from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/R/m_validate_model.R). 

### Creating and developing a masterscript: m_score_model.R ###

This is a sript which will be used later by your coworkers. They will be able to predict the outcome of the examination there, based on the model you built and evaluated in the previous scripts. In order to create it, start a new RScript file, copy its content from [here](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/R/m_score_model.R) and save it in R folder in your project.

### config.txt and config_templ.txt file ###

Before being able to run your masterscripts successfully, you need to take care of setting two files: config_templ.txt and cofig.txt.

Config_templ.txt is a file where you briefly describe what you include in config.txt. You should fill it in as follows:

![Config_templ.txt](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/configtempl.png) 

This is very important, because this is the file your coworkers will get. They will have to fill it accordingly to your instructions - their masterscripts will use it to create their config.txt files automatically based on what's inside config_templ.txt.

Config.txt file is where you declare paths to folders, number of samples etc. At first there is no such file in your project folder, it will appear after running the beginning of your masterscript code:

![Masterscript beginning](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/masterbegin.png) 

After running the code, open config.txt file which appeared in MalariaClassifier project folder and fill it similarily to mine:

![Config.txt](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/config.png)

Of course all of the paths to folders are supposed to be the paths to folders where YOU store your data. One more thing: we don't have our model yet, so we don't know our session_id number. Let's leave this for now, I will tell you when and how to fill it. And when it comes to images_for_analysis: you can copy a few images, both parasitized and uninfected, to a single folder. They will serve later as your "real" data.
 
### Running the project ###

So now we have everything we need to build a malaria classifier in R. The only thing you need to do, is to run two of the masterscripts: first "m_train_model.R", then "m_validate_model.R". 

When it comes to "m_train_model.R" - don't worry if it takes a while to train your model - the amount of time needed depends on the hardware you use. After installing everything properly and declaring the paths to folders as you were supposed to, after executing the whole code, this should appear in your Models folder:

![screenshot of the Models folder](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/insidemodels.png)

Do you see the number in the name of the model? This number is the session_id. So if you have your model now, please take a look at how it's called (your number will be different than mine) and copy the number from its name to session_id in your config.txt file. If you've done it, you can run the second masterscript.

After running "m_validate_model.R", your Work folder should consist of:

![screenshot of the Work folder](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/work_folder.png)

Of course the number in the name of subfolder "work + number" you see will be different on your computer - this is because of the fact that its name is based on session_id. Inside this folder, you should find two files: "evaluation_statistics" and "predictions 1". 

In addition to this, after executing "m_validate_model.R", in the Models folder, an RDS file called "calibration + session_id" should appear. The file is extremely important, because it's needed to successfully run "m_score_model.R".

And when it comes to "m_score_model.R" - it's dedicated to your coworkers, so there is no need for you to run it now. But of course, feel free to play around with it. You need to set a few arguments in config file, though. Firstly, a file path to images for analysis. Remember, it should be the path to one folder, where the samples are stored (both infected and uninfected). Secondly, "prediction_id". You have one model, so one session_id. When you ran "m_validate_model.R", a file called "predictions 1" was created in a folder "work + session_id". So as to avoid overwriting it, simply set "prediction_id" to 2. After running "m_score_model.R", two new files should appear in your work folder: "predictions 2" and "infected 2". Take a look at the current content of the work folder:

![work after score](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/work_after_score.png)

When you've done all of the above tasks, you're ready to deploy your project.

### Deployment: building deployment package ###

Remember it's not you, who will be using the malaria classifier, you've just build. It will go to your coworkers, that's why you need to prepare it for deployment so that it would be as easy to use as possible. The first step to achieve it was made: you created config_templ.txt file, where you briefly described how your friends are supposed to fill it in. The next step is to build a ZIP file containing all the files they will need to run your solution and to benefit from it. To build ZIP file, go to Addins menu and click "Build ZIP":

![Build ZIP](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/buildZIP.png)

After clicking it, a new window will pop up. Each of the created ZIP files needs to be labeled with its version. We will specify our project's version ourselves, by clicking "Specify version" and labeling it "001":

![Specify version](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/specifyversion.png)

### Deployment: installing deployment package ###

When you have a ZIP file, in order to use it, do the following: 

1. Create a new folder, name it "Production". Copy your ZIP file there and unzip it. Inside a ZIP file, you can find the following folders:

![first zip](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/first_zip.png)

What's inside them? In R folder, you will find the masterscripts. In libs, the packages are stored. Conda is a folder where Python or any Python-related tools are gathered and logs stores any logging information. And of course "Models" - where the models you created are present. So what are you supposed to do to deploy your project? 

2. Create a new folder inside MalariaClassifier folder - call it "Work". Now MalariaClassifier package should consist of:

![MalariaClassifier zip interior](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/zipcontent.png)

3. Fill config_templ.txt file as it states in the instructions. Declare path to folders, files and number of samples. In particular:

- **new_folder_path** - bear in mind that it should be the path to the folder "Work" you've just created. This way you will have all your results in one place. 
- **id_test, id_valid, id_train** - they are used for training and testing models, so they aren't needed for production (they aren't used in "m_validate_model.R" or "m_score_model.R"). They denote the indices of training, validation and testing samples (both parasitized and uninfected): [1, id_train] is the interval of the indices of training samples, [id_train+1, id_valid] of validation samples and [id_valid+1, id_test] of testing samples.
- **session_id** - this is extremely important for people using "m_validate_model.R" and "m_score_model.R". This id will indicate which of the models to use. Each of the models from "Models" folder will be named "model + number". And this number of a wanted model is what you're supposed to type in session_id.
- **images_for_analysis** - only for your coworkers. The path to a folder where they store folder with the samples to be tested using the models you built.
- **prediction_id** - also, very importand for your coworkers. When they want to use the same model to test different samples, they need to distinguish the files with the results somehow. And this is why they need to fill "prediction_id". It will appear in the name of the file with predictions (the file will be called "predictions + prediction_id").

4. Open the terminal and go to the folder "Production". Then open R folder and type:
```
Rscript m_train_model.R
```
This command should start executing the code from the masterscript "m_train_model.R". Your model is supposed to be trained and saved in the "Models" folder. When everything has run properly, type:
```
Rscript m_validate_model.R
```
This should execute the code from the masterscript "m_validate_model.R". After everything has run properly, in your "Work" folder, in subfolder "work + session_id", you should find the following files:

![insideWork](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/insideWork.png)

Apart from this, the content of the Models folder should look as follows:

![model after vlidation](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/model_after_score.png)

Now you can check out how "m_score_model.R" works. Set "prediction_id" number to 2 in your config file and type:
```
Rscript m_score_model.R
```
in your console. A new files called "predictions 2" and "infected 2" should appear in the subfolder "work + session_id".

Take a quick look on how the content of MalariaClassifier folder presents itself now:

![ZIP after](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/zipafter.png)

As you can see, there is one new folder - sbox. This is in case we require any packages in the masterscripts using R "library()" function - we load it only locally then. There is a new file too - config.txt. Its content was automatically copied from config_templ.txt.

And this is it. You created your first Malaria Classifier using R and prepared it for deployment. There is nothing left to do, than to present to your friends how to use it. By the way, [this subsection](#deployment-installing-deployment-package) is a great start for the description of how to use your solution, which should be given to your coworkers. This way they will know exactly what to do with the ZIP file you gave them. And if they want to know how you created the model - click [here](#understanding-malaria-project-step-by-step).

### Summary ###

So, let's sum up what we've just done:

- We created a project involving malaria classifier which uses Python but the whole code is written in R.
- Thanks to RSuite, the project is divided into three parts: one responsible for preparing the model, second for evaluating it and the third one is ready to be used by your coworkers to test real samples.
- We enabled the easy deployment of the project - even people who has never been programming are able to use the third part of the project in order to check whether a patient is sick or not. The only thing they need to do to achieve it, is to fill in a text file.

This means we successfully completed the task described in the introduction. If you're interested in creating and developing similar projects, please check out these articles:

- Classifying handwritten digits (MNIST dataset) using Keras and Shiny [click here](https://github.com/WLOGSolutions/Keras_and_Shiny)
-

And if you want to know exactly how and why the particular parts of the R code were created, the next section is for you.

## Understanding malaria project step by step ##

### Introduction ###

I will guide you through all of the project's functionalities. I will describe the idea behind the functions needed for preparing the data as well as the theory behind modelling it. I assume that you have some experience in the basics of machine learning techniques, especially classifying images, therefore the theory behind CNN's in general won't be covered in this section. You can expect a detailed description of the created model, though.

### Understanding the task ###

We want to partly automatize the process of detecting whether a patient has malaria or not. In order to do this, we can create a classifier which, based on the image it analises, returns value 1/0 if the patient is sick/healthy. We can go a bit further and require that it additionaly returns the probability of the image belonging to the predicted class. So our goal is to create a classifier which, after running, returns a file with a list of people who are likely to be sick with a probability, let's say, greater than 50%.

At our disposal we have: R, RSuite, RStudio, Conda and a large dataset to train our model. Our dataset consists of two folders: Parasitized and Uninfected. Each of the folders contains over 13k images of cells infected and uninfected respectively. Take a look on how the images present themselves (left - infected, right - uninfected):

![cell images](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/cellimages.png)

What can we deduct from the images that will help us accomplish the task? They are pretty simple, not very detailed, colorful. Perfect for building an image classifier based on a convolutional neural network. But before building the model, we need to prepare our images first.

### Understanding package: DataPreparation ###

In this package, in R folder, we have a few functions needed to prepare our data for modelling. We can divide this preparation into 2 steps:

1. Splitting the data into training, validation and testing samples.

For this, we have a function called `splitAndSave`. It creates a new folder containing three subfolders: train, validation and test. Each of the subfolders consists of two subsets: Parasitized and Uninfected.

2. Loading, converting and labeling the data. 

What you need to do next, is to load the images in a form of a data tensors, convert them and label them accordingly to their classes. This may seem as at least three steps, but thanks to Keras, it's really easy. The functions which help you do it, are `getLabelledImages`, `getTrainingImages` and `getUnlabelledImages`. Take a look at the first one:

```
getLabelledImages <- function(new_data_path, folder_name, batch_size) {

  generator <- keras::image_data_generator(rescale = 1/255)

  data_generator <- keras:: flow_images_from_directory(file.path(new_data_path, folder_name),
                                                       generator,
                                                       target_size = c(50, 50),
                                                       classes = c("Uninfected", "Parasitized"),
                                                       batch_size = batch_size,
                                                       class_mode = "binary")
  return(data_generator)
}
```
As you can see, `getLabelledImages` is based on two Keras's functions: 

- `image_data_generator` -  which generates the data and rescales pixel values from the range 1-255 into the range 0-1. We are supposed to normalize the values, because neural networks work better with smaller numbers.
- `flow_images_from_directory` - which uses the previously defined generator and applies it to the data. In addition, it changes image resolutions to 50x50 and labels the data. 

So what is the result of executing the function? It generates batches of RGB images in a size of 50x50 with binary labels. Every batch consists of the number of samples which we specify in `flow_images_from_directory` using `batch_size` argument (we will set it to 50). And thanks to using `classes` argument, we can declare the way of labelling the images (0 - Uninfected, 1 - Parasitized).

The second function, `getTrainingImages` is an advanced version of `getLabelledImages`. Take a look at it:

```
getTrainingImages <- function(new_data_path, folder_name, batch_size){

  aug_generator <- keras:: image_data_generator(rescale = 1/255,
                                                rotation_range=20,
                                                zoom_range=0.05,
                                                width_shift_range=0.05,
                                                height_shift_range=0.05,
                                                shear_range=0.05,
                                                horizontal_flip=TRUE,
                                                fill_mode="nearest")

  data_generator <- keras:: flow_images_from_directory(file.path(new_data_path, folder_name),
                                                       aug_generator,
                                                       target_size = c(50, 50),
                                                       classes = c("Uninfected", "Parasitized"),
                                                       batch_size = batch_size,
                                                       class_mode = "binary")
  return(data_generator)

}
```
In order to improve the ability of learning by our model, we need to augment the training samples. Thanks to it, the model will learn better and it will help us avoid overfitting. So what this function does, is that it generates batches of data, where each image is randomly rotated (`rotation_range`), randomly zoomed (`zoom_range`), randomly transformed (`width_shift`, `height_shift`), randomly cropped (`shear_range`), randomly mirrored (`horizontal_flip`) and when new pixels occur due to the rotation or shifting, they are filled with the nearest ones (`fill_mode`).

Of course, preparing the data for modelling is slightly different than preparing it for being used by the trained model. That's why we have one more function in DataPreparation package:

- `getUnlabelledImages` - its goal is to prepare the real data to be used by the model. It's very similar to `getLabelledImages`, but let's look at it:

```
getUnlabelled <- function(image_path){

  generator <- keras::image_data_generator(rescale=1/255)

  data_generator <- keras:: flow_images_from_directory(image_path,
                                                       generator,
                                                       target_size = c(150, 150),
                                                       batch_size = 1,
                                                       class_mode = NULL,
                                                       shuffle = FALSE)
  return(data_generator)
}
```

Can you see the differences? These are testing samples, so we don't have their labels. That's why we need to specify `class_mode` argument to "NULL". Another important thing here is argument `shuffle`: it needs to be set to FALSE, because it's better, when our testing data isn't mixed during being processed by our model. And be careful. While specifying `image_path`, you need to pass the path to the folder, where another folder (only one - the images are unlabelled, so they are stored altogether) is present. This is because Keras generators use folders to distiguish between classes. If your `image_path` is the direct path to the images, the generator won't find any samples, because it won't see any classes.

### Understanding package: MalariaModel ###

This package's purpose is to store the functions that have anything to do with the modelling. So whether it is building the model or using it in any way, functions needed to do it you can find in "api_modelling.R" file in MalariaModel. Functions in this script, we can divide into two groups: the ones, that create, evaluate and use the model and the ones needed to save or load the files. We will start with the first group, because the functions there are a little more interesting.

#### Functions needed to create the model ####

Remember how I pointed out at the beginning of this chapter, that our images aren't very complex? Well, this is important now, while creating the model. We have to pass to the model that it doesn't have to try to spot as many details as it could - this will help us shorten training time. So how to do it? Basically we have two functions that create and train the model:

1.  `createModel` - a function which defines the model's architecture and compiles it. What does it mean? Take a look at the function:

```
createModel <- function() {
  model_architecture <- keras::keras_model_sequential() %>%

    keras::layer_conv_2d(filters=16, kernel_size = c(2,2), activation = "relu", input_shape = c(50, 50, 3)) %>%
    keras::layer_max_pooling_2d(pool_size = c(2,2)) %>%
    keras::layer_conv_2d(filters=32, kernel_size = c(2,2), activation = "relu") %>%
    keras::layer_max_pooling_2d(pool_size = c(2,2)) %>%
    keras::layer_conv_2d(filters=64, kernel_size = c(2,2), activation = "relu") %>%
    keras::layer_max_pooling_2d(pool_size = c(2,2)) %>%

    keras::layer_dropout(rate=0.2) %>%
    keras::layer_flatten() %>%
    keras::layer_dense(units=500, activation = "relu") %>%
    keras::layer_dropout(rate=0.2) %>%
    keras::layer_dense(units = 1, activation = "sigmoid")

    model_architecture %>% keras::compile(loss="binary_crossentropy",
                                        optimizer = keras::optimizer_adam(),
                                        metrics = c("acc"))
  return(model_architecture)

}
```

As you can see, the first Keras function used in `createModel` is `keras_model_sequential()`. It's nothing more, than saying "my model will consist of a few layers, which I'm going to add now". And then comes the most important part: adding the layers. The "first part" of the model's architecture consists of two types of layers: 

- `layer_conv_2d` - convolutional layers used by the model to learn the patterns. The arguments `filters` and `kernel_size` passed to the model determine how precise the learning should be. The smaller the numbers of the arguments are, the bigger features of the pictures are spotted. That's why we start with setting `filters=16` and finish with `filters=64`. At first our model learns the features that are realatively easy to spot during training. As we are deeper in our neural network (further from the input image), we try to spot more nuances, therefore we increase `filters` argument. Our pictures aren't very detailed, that's why we don't need to use a lot of filters. 64 is a relatively small number, but it's perfectly sufficient for our images. And what about `kernel_size` argument? We set it to (2,2), because this is the most optimal number in our case. The pictures aren't big as for images to pass to the model and their construction is pretty simple, so it isn't necessary to use the bigger size (it would be less efficient computationally). Another argument in every convolutional layer is `activation`. It's where we specify our activation function. In our case it's "relu" which maps the values into a range 0-1. And `input_shape=c(50,50,3)` in the first layer tells our network what shape our samples have. 50x50 is their resolution, while 3 indicates color depth (we have RGB images - in such case it will always be 3).

- `layer_max_pooling_2d` - this type of layers is used for two reasons: it reduces the output shape within a model as well as it generalises the results of convolutional layers - they become invariant to scale or orientation changes. The argument `pool_size=c(2,2)` indicates by which to downscale (vertical, horizontal). In our case, the settings mean that the input will be halved in both spatial dimensions.

After last pooling layer, we need to use:

- `layer_dropout` - one of the ways to use dropout regularization technique in Keras. We set `rate=0.2` meaning that 20% of the features' values are substituted with 0 during training. It helps us avoid overfitting.

- `layer_flatten` - it reshapes the tensor to have a shape that is equal to the number of elements contained in the tensor. This is the same thing as making a 1d-array of elements. 

- `layer_dense` - it's a regular densely connected neural network layer. Argument `units` denotes the output size of the layer, while in `activation`, we can declare the activation function we want to use. In the first dense layer in our model, we set `units=500` and `activation="relu"`. Basically, we could set `units` to any other value and see how it works. There isn't any pattern in choosing units number in dense layer - you need to try out a few values and see which gives the best accuracy and the lowest loss value. In the second dense layer, this number is important, though. We set `units=1`, because our expected output is a vector of probabilities. This is also the reson, why we chose "sigmoid" as the activation function. 

We defined the model's architecture, so the next step is to prepare it for training. The second part of `createModel` uses Keras `compile` function. There, we define the parameters based on which our model is trained. Among these parameters is loss function (argument `loss` - we set it to "binary crossentropy", because our dataset consists of images belonging to two classes), metrics to be evaluated by the model during training and testing (argument `metrics` - in our case it's accuracy) and optimalization method (argument `optimalizer` set to "adam").

So, what `createModel` returns after executing it, is a compiled Keras model object, ready do be trained on the data. 

2. `trainModel` - a function based on Keras `fit_generator`, which trains the model on training and validation data. Take a look at it:

```
trainModel <- function(model) {

             model %>% fit_generator(train_data,
                                     steps_per_epoch = train_data$n/train_data$batch_size,
                                     epochs = 20,
                                     validation_data = valid_data,
                                     validation_steps = valid_data$n/valid_data$batch_size)
  return(model)
}
```
What is important here is that we *have to* use `fit_generator` instead of `fit`, because the prepared data will be passed on by generators. There are two arguments in `fit_generator` worth mentioning: `steps_per_epoch` and `validation_steps`. Their value is supposed to be set to number of samples divided by a batch size of the training and validation sets respectively. Of course, both arguments should be integers. You need to be careful while setting `epochs` too. Too many may result in overfitting, while too few in underfitting. 

3. `evaluateModel` - it simply evaluates the model on the testing data generator. It classifies the data and then compares the results with the real labels. As a result, we get accuracy and loss of our model stored in a data frame.

4. `predictClassesAndProbabilities` - the function returns a data frame with the index, predicted class and a probability based on which the class was determined. Take a quick look at the function:

```
predictClassesAndProbabilities <- function(model, test_data){


  probabilities <- keras::predict_generator(model, test_data, steps = test_data$n, verbose = 1)
  classes <- ifelse(probabilities > 0.5, 1, 0)
  index <- test_data$filenames

  dt <- data.table::data.table(Id = index,
                               Class = classes,
                               Probability = probabilities)
  colnames(dt) <- c("Id", "Class", "Probability")

  return(dt)
}
```
As you can see, it uses Keras `predict_generator` function, which returns the values, based on which the samples are assigned to classes. Using `ifelse` we can obtain these classes. 

5. `calibrateProbabilities` - it returns the accurate estimate of the probabilities that each test sample is the member of the class of interest. Take a look at the function:
```
calibrateProbabilities <- function(dataset, dt){
  classes <- dataset$classes
  levels(classes) <- c(0,1)
  calibration <- CORElearn::calibrate(classes,
                                      dt$Probability,
                                      class1 = 1,
                                      method = "isoReg",
                                      assumeProbabilities = TRUE)
  calibration$interval <- round(calibration$interval, 3)
  calibration$calProb <- round(calibration$calProb, 3)
  return(calibration)
}
```
Its basis is `calibrate` function from CORElearn package. It takes the vector of true classes as the first argument and the probability scores obtained after executing `predictClassesAndProbabilities` as the second argument. It uses isotonic regression to calibrate the probabilities and returns a list of the boundaries of the intervals as well as the calibrated probabilities for each corresponding interval. As we set `class1` argument to 1, the probability we obtain is the probability of each sample belonging to class 1 (parasitized). Note, that we need to specify classes' levels - otherwise `calibrate` won't understand the argument set in `class1`.

6. `applyCalibration` - as the name suggests, it applies the previously calculated calibration to the data. Take a look at it:
```
applyCalibration <- function(f_path, session_id, dt){

  data_frame <- dt
  calibration_name <- sprintf("calibration %s", as.character(session_id))
  calibration <- readRDS(file.path(f_path, calibration_name))

  calibrated_probabilities <- CORElearn::applyCalibration(dt$Probability, calibration)

  for(i in 1:nrow(dt)){
    if(data_frame$Class[i]==1){
      data_frame$Probability[i] <- calibrated_probabilities[i]
    }else{
      data_frame$Probability[i] <- (1 - calibrated_probabilities[i])
    }

  }

 pkg_loginfo("Probabilities calibrated using '%s' file.", calibration_name)
 return(data_frame)

}
```
It loads the calibration file (thanks to session_id, calibration always corresponds to the model you're currently using) and applies the calibration to the data passed in a form of a data frame (the data frame created in `predictClassesAndProbabilities`). In addition it changes the probability - as `calibrateProbabilities` returns the probability of the sample belonging to class 1, we use a loop to modify it accordingly to the predicted class. As a result, we get the same data frame, but with a modified Probability column - now our probabilities are well calibrated and we can interpret them as an actual probability of the image belonging to the predicted class.

7. `getInfectedIndices` - it reads the file with predictions and returns a data frame with the index and the probability of a person being infected. It looks only among people who have been identified with class 1 (parasitized) during the examination. In addition, there is `treshold` parameter, which denotes the probability above which we want to have the sample's characteristics written in the data frame.


#### Functions used for saving and loading files ####

1. `saveModel` - saves the model into a hdf5 file using Keras `save_model_hdf5` function. After executing the function, you can find the trained model on the previously specified saving path, under the name "model + session_id".

2. `getSessionId` - generates `session_id` based on a numeric version of `Sys.time()`. Note that for each trained model, a different `session_id` is assigned to its name. Later, while making predictions, they are saved in a "work + session_id" folder, where "session_id" is the used model's "session_id".

3. `loadModel` - loads the model which was previously saved into a hdf5 file. It uses Keras `load_model_hdf5` function under the hood.

4. `saveCalibration` - saves the calculated calibration into RDS file. After executing the function, you can find a file named "calibration + session_id" in the Models folder. This location is important, because the file needs to be delivered to your coworkers - they will use it while running "m_score.R".

5. `savePredictions`, `saveInfected` - they both save the previously created data frames into .csv files. At first they check whether a folder "work + session_id" exists and if not, they create it. After executing `savePredictions`, you will find a file called "predictions + pred_id" there, while after executing `saveInfected`, you will find a file called "infected + pred_id".

### Understanding masterscript: m_train_model.R ###

This masterscript is a place to create the model. We can do it by using: 

1. `splitAndSave` function, where we specify the number of samples using config file. The dataset is split and saved under a chosen folder path.

2. `getTrainingImages` to generate training samples in a proper form

3. `getLabelledImages` to generate validation samples in a proper form.

4. `createModel` and `trainModel` functions to obtain a trained model.

5. `getSessionId` and `saveModel` to save the trained model in our "Models" folder under a name "model + session_id"

After running the whole masterscript, we should obtain a trained model, saved on our disk.

### Understanding masterscript: m_validate_model.R ###

This masterscript is a place to evaluate the previously created model. We can do it, by using:

1. `loadModel` to read the model created in "m_train_model.R" called "model + session_id".

2. `getLabelledImages` to generate testing data in a proper form.

3. `resetGenerator` to reset the generator of the testing samples.

3. `evaluateModel` and `saveModelEvaluation` to evaluate our model on the testing samples and save the evaluation into a .csv file.

4. `predictClassesAndProbabilities` to check how the samples from the testing data have been classified and to obtain probability scores needed for calibration.

5. `calibrateProbabilities`, `saveCalibration` and `applyCalibration` to obtain the calibrated probabilities, apply it to data and save it for later use.

6. `savePredictions` to save the results of the predictions.

After running the whole masterscript, we should obtain two .csv files saved in our work folder called "work + session_id": "evaluation" and "prediction + pred_id". In addition to this, in Models folder, there should appear a file called "calibration + session_id".

### Understanding masterscript: m_score_model.R ###

This masterscript is designed as a place, where real data should be tested. We can do it, by using:

1. `loadModel` to read the model created in "m_train_model.R" called "model + session_id".

2. `getUnlabelledImages` to generate testing data in a proper form. 

3. `predictClassesAndProbabilities` and `applyCalibration` to check how each of the samples has been classified and to obtain its exact probability of belonging to the predicted class.

4. `getInfectedIndices` and `saveInfected` to extract only these samples, which are likely to be infected and to save them in a separate .csv file.

After running the whole masterscript, we should obrain two .csv files: "predictions + pred_id" and "infected + pred_id" saved in our work folder called "work + session_id". 

## Results ##

Using the exactly same piece of code I've just described, I was able to obtain over 95% training accuracy and 97% validation accuracy:

![screen from training](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/modelokok.png)

while accuracy on my testing sample was over 93%:

![screen of acc and loss](https://github.com/WLOGSolutions/RSuite-examples/blob/malaria/MalariaClassifier/ImagesForDescriptionToExport/lossANDacc.png)

Take into account, that the training dataset consisted only of 3000 images of each class, while the validation consisted of 1000 images of each class. I trained the model for 20 epochs, and I don't recommend increasing this number - it results in model overfitting. 
