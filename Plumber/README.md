# Building REST API with RSuite and [Plumber](https://www.rplumber.io/)

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
- [Bibliography](#bibliography)
    
<!-- markdown-toc end -->


## Introduction ##

Simple example how to build REST API using [Plumber](https://www.rplumber.io/) altogether with [R Suite](https://rsuite.io/RSuite_Download.php). This example is based on apartments data taken from package [DALEX](https://cran.r-project.org/web/packages/DALEX/index.html). 

## TL;DR

If you are using Windows 10 you can just download deployment pkg using this [link](https://wlog-share.s3.eu-central-1.amazonaws.com/rsuite-example_Plumber_1.0x.zip). To run the app you have to unzip the archive and jump to <>

## Preliminary requirements ##

- R [download here](https://www.r-project.org)
- RStudio [download here](https://www.rstudio.com/products/rstudio/download/)
- R Suite CLI [download here](https://rsuite.io/RSuite_Download.php)
- Git [download here](https://git-scm.com/downloads)

## Build the application

Just run the following instructions from the command line (from within project folder):

1. Install dependencies - `rsuite proj depsinst`
2. Build project pkgs - `rsuite proj build`

## Run the application

Now you are ready to run the app. You do this with the following command

```
Rscript R\master.R
```

The app is available (using Swagger) from the browser with <http://127.0.0.1:8000/__swagger__/>

## Application API

### Build models

You have to run this first. This function builds models and stores them in `work` folder.

### Score

You can score models using one of the two functions:

1. Score specific row - `score`
2. Score providing variables' values - `score_vars`

Scoring models is combined with scoring explanation delivered by [DALEX](https://cran.r-project.org/web/packages/DALEX/index.html) pkg.
