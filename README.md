# Coordinate translator

A flutter application for converting coordinates from Lat/Long to OSGB36 grid references and vice versa

[Now available on Google Play!](https://play.google.com/store/apps/details?id=com.latlonpackage.coord_translator)

## Building the project

This repository is a flutter project, not a built app, so you can clone it and edit the project however you want. 
The build is available under the release section of the repository in the form of an APK for Android devices; unfortunately I haven't got any experience with iOS devices so there isn't a build for it. If you would like the build on an iOS device then you will have to clone the repository and build it yourself.

## Translating coordinates

The app takes an input of latitude and longitude coordinates using the WGS84 datum (this is the most widely used datum around the world for lat and long coordinates used by GPS systems).
Any coordinates retrieved via GPS (most phones) will be in WGS84 format
Coordinates can be inputted in either decimal format or in degrees, minutes and seconds.
The resulting conversion will output a 6 digit easting and a 6 digit northing reference along with the full Ordnance Survey reference in letter pair format.

There is also an option to enter in a 6 digit easting and 6 digit northing, or full OS reference in letter pair format, which the app will convert into latitude and longitude coordinates.
As in the first section, these lat and long coordinates can be presented in decimal format or degrees, minutes and seconds.

### Get the package

I have written the converter and maths up into its own package so anyone can import it into their dart or flutter projects, you can find the package on the pub.dev site [here](https://pub.dev/packages/latlong_to_osgrid), and the source code on github [here](https://github.com/FunkyPenguin24/latlong_to_osgrid). Please see the source code for examples on using the package and the details on how the maths works.
