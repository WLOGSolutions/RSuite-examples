# Building REST API with RSuite and [Plumber](https://www.rplumber.io/)

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Introduction](#introduction)
- [TL;DR](#tldr)
- [Preliminary requirements](#preliminary-requirements)
- [Build the application](#build-the-application)
- [Run the application](#run-the-application)
- [Application API](#application-api)
    - [Build models](#build-models)
    - [Score](#score)

<!-- markdown-toc end -->


## Introduction ##

Simple example how to build REST API using [Plumber](https://www.rplumber.io/) altogether with [R Suite](https://rsuite.io/RSuite_Download.php). This example is based on apartments data taken from package [DALEX](https://cran.r-project.org/web/packages/DALEX/index.html). 

## TL;DR

If you are using Windows 10 you can just download deployment pkg using this [link](https://wlog-share.s3.eu-central-1.amazonaws.com/rsuite_examples_win10_Plumber_1.0x.zip). To run the app you have to unzip the archive and jump to [Run the application](#run-the-application).

[Run the app]: #run-the-application

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
