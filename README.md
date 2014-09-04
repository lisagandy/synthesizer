mergecolumns
============

This is a web application that uses the Cappuccino framework to group columns from multiple spreadsheets.  It is designed to run at the root level of a domain or virtual domain, but a few adjustments could be made to run it in a sub-directory of a domain as well.

File Structure
--------------
- index.html:  The primary HTML file, which just provides a frame for Cappuccino/Objective-J to run in.  
- main.j:  The technical (function-based) start of the Objective-J execution.  Just starts the runtime for the object-based execution later (which is in AppController.j). 
- AppController.j:  This is the main Objective-J class that sets everything up when the web app is started.  The first method that is called is applicationDidFinishLaunching.
- Base:  These are Objective-J classes that provide basic and universal functionality such as parsing CSV files, loading URL data, etc.
- Frameworks:  This directory holds all the Cappuccino frameworks and the code that provides the Objective-J language on top of Javascript.  There is no custom code in this folder.
- Model:  These are Objective-J classes to provide the data model for the app.
- Resources:  Mostly image files for elements used in the interface.
- Views:  These are CPView subclasses that are used to draw the content in the various areas of the web app.

Configuration
-------------
There's not much to configure in the web app, but here is one configuration option that might be used.

AppController.j:  You can adjust the path of the input values CSV files.  In the parseArguments method, the valuesURL variable is instantiated with a string URL.  The default path is /input\_data/*-values.csv.  The * is passed in as part of the URI when launching the web app (see Usage below).  If the file name passed in is "ABC", then the web app will try to download the /input\_data/ABC-values.csv file for it's input.

Usage
-----
Check out the repository into the base directory of a domain or virtual domain of a web host.  Then just point your browser to http://domain/ to launch the application.  

You must specify an input values file name when calling the URL, or the app won't show any columns or groups.  To do this, you'll add a # to the end of the URL and follow that by a filename.  For example, http://domain/#ABC
