/*
 * CMCommon.j
 * ColumnMerger
 *
 * Created by Mike Piatek-Jimenez.
 * Copyright 2014, Gaucho Software, LLC.  All rights reserved.
 *
 * This isn't a class, it just provides a few common global variables that several of the other classes use.
 */

// Notifications
CMURLLoadedNotification = "CMURLLoadedNotification";

// Column Names
CMOldIDColumnName = "Old ID/Grouping";
CMNewIDColumnName = "New ID";
CMSpreadsheetColumnName = "Spreadsheet";

// Colors
CMPrimaryColorHue = 0.622;
CMPrimaryColorSaturation = 0.609;
CMPrimaryColorBrightness = 0.933;

// Gradients
CMHeadingGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithHue:CMPrimaryColorHue saturation:CMPrimaryColorSaturation brightness:CMPrimaryColorBrightness alpha:1] endingColor:[CPColor colorWithHue:CMPrimaryColorHue saturation:0.663 brightness:0.816 alpha:1]];
CMColumnEditorHeadingGradient = [[CPGradient alloc] initWithStartingColor:[CPColor colorWithWhite:1 alpha:1] endingColor:[CPColor colorWithWhite:0.92 alpha:1]];