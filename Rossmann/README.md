# RSuite Rossmann Example

## DESCRIPTION

The project allows to forecast daily mean of sales per store based on the date, day of week and the fact whether the promo is on or not.

This particular project was based on a slightly modified Rossmann sales dataset (the original one can be found on Kaggle), but basically it is possible to model any daily mean of sales per store provided that in the dataset there are columns named: Date, DayOfWeek, Promo and Sales.

The project consists of three packages:
 DataPreparation, where you can find functions that are necessary to access the data and to prepare them for further analysis.
 DataVisual, where you can find functions that enable to visualise your data.
 ARIMAmodelling, where you can find tools necessary to build an ARIMA model and to check its basic assumptions.

The main part of the project is in folder named “R” - you can find the masterscripts there. There are two of them:
* m_data_visual - it draws a few plots 
* m_modelling - it models and forecasts the mean of daily sales per store using ARIMA

## TECHNICAL PART

In a folder Dane, you have the data based on which the project was built (train_filled_order.csv) and the test set (test.csv) on which the forecast was prepared. 

Whether you want to use your own data or not, you have to fill in the file config_templ.txt first. You should do it as follows:
* data_path - it should contain a path to a folder where the data is stored
* f_name_train - it should contain the name of the training dataset
* f_name_test - it should contain the name of the test dataset

It is advisable to plot the data first - it will be easier to check if the obtained model is reasonable.
Then you can move on to modelling your data.
