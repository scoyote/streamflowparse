# streamflowparse
Tools for parsing realtime streamflow feeds from USGS
This is one of the repositories that I have created to explore doing a series of tasks with various tools.

In this case the process of E(L)T from USGS, prepping the time series and making the transfer function set is the parse part
From there, the following tasks are attempted in variuos languages

* calculation and plotting of the crosscorrelation function, identification of the ccf order
* various time series identification steps
* Fitting arimax or other transfer function model 

By far, the most devloped library for doing all of this, particularly the transfer function calculations, is in SAS but since it is proprietary and expensive, it is unlikely that many users have access to it. the TSA package of R is the next closest, and I am researching how to do this in Python and the other tools. KNIME would be a great place to do this visually, but the time series libraries there are not ready for this level of complexity yet. 

Enjoy
