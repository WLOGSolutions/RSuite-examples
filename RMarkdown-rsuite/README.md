# Using [R Markdown](https://rmarkdown.rstudio.com/) with [R Suite](https://rsuite.io) #
<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Register template](#register-template)
- [Create a new project using *RMarkdownTmpl* template](#create-a-new-project-using-rmarkdowntmpl-template)
    - [`notebooks` folder](#notebooks-folder)
        - [`render_notebooks.R` master script](#rendernotebooksr-master-script)

<!-- markdown-toc end -->

## Register template ##

After cloning repository you can register RMarkdown template for R Suite projects using commands:

```
rsuite tmpl register -p RMarkdownTmpl
```

If everything worked properly you can see a new template issuing command

```
rsuite tmpl list
```

At my computer I have the following templates registered. The third one is template for R Markdown.

```
Name: blog_post
HasProjectTemplate: TRUE
HasPackageTemplate: FALSE
Path: C:/Users/WitJakuczun/.rsuite/templates/blog_post

Name: RMarkdownRSuite
HasProjectTemplate: TRUE
HasPackageTemplate: TRUE
Path: C:/Users/WitJakuczun/.rsuite/templates/RMarkdownRSuite

Name: RMarkdownTmpl
HasProjectTemplate: TRUE
HasPackageTemplate: TRUE
Path: C:/Users/WitJakuczun/.rsuite/templates/RMarkdownTmpl

Name: workflowr_template
HasProjectTemplate: TRUE
HasPackageTemplate: FALSE
Path: C:/Users/WitJakuczun/.rsuite/templates/workflowr_template

Name: builtin
HasProjectTemplate: TRUE
HasPackageTemplate: TRUE
Path:
        D:/Workplace/Tools/R/R-3.6.0/library/RSuite/extdata/builtin_templates.zip
```		

## Create a new project using *RMarkdownTmpl* template ##

Now we will create a new project called `EDA` using `RMarkdownTmpl` template

```
rsuite proj start -n EDA -t RMarkdownTmpl
```

After project was sucessfuly created you can check its structure using `ls` command. Below you see how it should look like.

```
2019-08-06  14:30    <DIR>          .
2019-08-06  14:30    <DIR>          ..
2019-08-06  14:24                71 .gitignore
2019-08-06  14:33             2 984 .Rhistory
2019-08-06  14:24               153 .Rprofile
2019-08-06  14:24    <DIR>          .Rproj.user
2019-08-06  14:24                16 config.txt
2019-08-06  14:24                16 config_templ.txt
2019-08-06  14:33    <DIR>          deployment
2019-08-06  14:30               371 EDA.Rproj
2019-08-06  14:24    <DIR>          logs
2019-08-06  14:32    <DIR>          notebooks
2019-08-06  14:24    <DIR>          packages
2019-08-06  14:24               143 PARAMETERS
2019-08-06  14:24    <DIR>          R
2019-08-06  14:24    <DIR>          tests
```

### `notebooks` folder ###

The most important is folder **notebooks**. It is where you can keep you notebooks (using extension `Rmd`). In the template you can find an exemplary notebook.

**Remark** It is important, when you create a new notebook, to add `chunk` named `rsuite_setup` as the first chunk in the notebook. You can safely ignore outputs of this chunk and not include it in your reports.

#### `render_notebooks.R` master script ####

In folder **R** you can find master script called `render_notebooks.R`. This script walks through all notebooks (using regexp `*\\.Rmd$`) in `notebooks` folder and generates html files.

You can generate all notebooks using command (you must be in `EDA` folder)

```
Rscript R\render_notebooks.R
```
