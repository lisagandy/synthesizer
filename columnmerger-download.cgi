#!/usr/bin/env python

# Created by Mike Piatek-Jimenez on September 26, 2014.
# Copyright 2014, Gaucho Software, LLC.  All rights reserved.

import cgi, os
import cgitb; cgitb.enable()

form = cgi.FieldStorage()

filetext = "Missing file upload."

if form.has_key('csv'):
	fileitem = form['csv']
	if fileitem.file:
		filetext = fileitem.file.read()
elif form.has_key('csv_text'):
	filetext = form.getvalue('csv_text')

print "Content-Type:text/csv; name=\"MergedColumns.csv\"\nContent-Disposition: attachment; filename=\"MergedColumns.csv\"\n\n"
print filetext
