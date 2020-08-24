# Coordinate translator

A flutter application for converting coordinates from Lat/Long to OSGB36 grid references and vice versa

## Building the project

This repository is a flutter project, not a built app, so you can clone it and edit the project however you want. 
The build is available under the release section of the repository in the form of an APK for Android devices; unforuntately I haven't got any experience with iOS devices so there isn't a build for it. If you would like the build on an iOS device then you will have to clone the repository and build it yourself.

## Translating coordinates

The app takes an input of latitude and longitude coordinates using the WGS84 datum (this is the most widely used datum around the world for lat and long coordinates used by GPS systems).
Any coordinates retrieved via GPS (most phones) will be in WGS84 format
Coordinates can be inputted in either decimal format or in degrees, minutes and seconds.
The resulting conversion will output a 6 digit easting and a 6 digit northing reference along with the full Ordnance Survey reference in letter pair format.

There is also an option to enter in a 6 digit easting and 6 digit northing, or full OS reference in letter pair format, which the app will convert into latitude and longitude coordinates.
As in the first section, these lat and long coordinates can be presented in decimal format or degrees, minutes and seconds.

## The maths

First of all I would like to give a big thanks to Movable Type Scripts, whilst I had a slight understanding of the maths behind the conversion they have an open source JavaScript library on their website (https://www.movable-type.co.uk/scripts/latlong-os-gridref.html) that allowed me to translate the maths into dart and made this app possible.
This readme won't go into the details of any mathematic algorithms, but will point to the dart file in the project where it is stored

The main thing I learned from their website that I wasn't aware of was that there is different types of latitude and longitude that use different datums.
Each datum has an ellipsoid that it uses that is used for converting to cartesian coordinates.
The Ordnance Survey Grid uses latitude and longitude coordinates of the OSGB36 datum which has been deprecated since 2014.
Since the OS Grid is still based off the OSGB36 datum, in order to translate WGS84 latitude and longitudes to Grid References, they must first be transformed into OSGB36 latitude and longitudes.
The OSGB36 datum uses the Airy 1830 ellipsoid, whilst the WGS84 datum uses the WGS84 ellipsoid.

### Get the package

I have written the converter and maths up into its own package so anyone can import it into their dart or flutter projects, you can find the package on the pub.dev site [here](https://pub.dev/packages/latlong_to_osgrid), and the source code on github [here](https://github.com/FunkyPenguin24/latlong_to_osgrid). Please see the source code for examples on using the package.

### Translating coordinates between datums

The coordinates are converted between datums in a three step process, one of which uses what is known as a "Helmert transformation"

1. The starting datum coordinates are converted into geocentric cartesian coordinates with an x y z. This is done using the ellipsoid parameters for the datum. (see toCartesian() in [LatLongEllipsodialDatum](lib/maths/LatLongEllipsodialDatum.dart) and [LatLongEllipsodial](lib/maths/LatLongEllipsodial.dart))
2. The resulting cartesian coordinates are put through a 7-parameter Helmert transformation which applies a 3-dimensional shift and rotation as well as a scale factor to give a new cartesian. (see applyTransform() in [Cartesian](lib/maths/Cartesian.dart))
  2. The parameters for the Helmert transformation are given by the datum you're converting to's transform parameters (see [Datums](lib/maths/Datums.dart))
3. The new cartesian is then converted back to latitude and longitude coordinates using the datum you're converting to's ellipsoid parameters. These new latitude and longitudes will be in the destination datum.

### Translating OSGB36 lat and long to OS Grid Reference

The [Latitude and Longitude object](lib/maths/LatLong.dart) contains the function toOsGrid() which converts it's latitude and longitude coordinates to the OSGB36 datum as above, and then runs them through an algorithm to calculate an easting and northing reference.
Please see the function toOsGrid() for the full maths.

### Translating OS Grid Reference to OSGB36

The [Ordnance Survey Reference object](lib/maths/OSRef.dart) contains the function toLatLon() which by converts it's given easting and northing (specified on initialisation) into OSGB36 lat and long then converts them by default to WGS84 coordinates.
If you're going to use the library in any projects and want to convert OS Grid References to another datum for any reason, you can specify this as a parameter when you call the toLatLon function (no parameter means it'll return WGS84)
All datums are available through the [Datums file](lib/maths/Datums.dart), simply import that and pass the datums object that you want to convert the reference to (e.g. Datums.WGS84)
Please see the function toLatLong() for the full maths.
