import 'package:coord_translator/maths/LatLongEllipsodialDatum.dart';

import 'maths/Datums.dart';
import 'maths/LatLong.dart';
import 'maths/OSRef.dart';

class Converter {

  ///Returns the easting and northing values of OSGB36 reference given the decimal latitude and longitude values
  getOSGBfromDec(double lat, double long) {
    //since we are converting from WGS84 lat/long, we need to provide the converter with its datum so it knows what it's converting from
    LatLong latLong = new LatLong(lat, long, 0, Datums.WGS84); //gives the lat and long coordinates to the converter along with the height and the Datum of the lat long coords
    OSRef osRef = latLong.toOsGrid(); //returns an array with 2 elements, the first is the easting and the second is the northing
    return osRef;
  }

  getOSGBfromDms(double latdeg, double latmin, double latsec, double longdeg, double longmin, double longsec) {
    LatLong latLong = new LatLong.fromDms(latdeg, latmin, latsec, longdeg, longmin, longsec, 0, Datums.WGS84);
    OSRef osRef = latLong.toOsGrid();
    return osRef;
  }

  getLatLongFromOSGB(double easting, double northing) {
    OSRef osRef = new OSRef(easting, northing);
    LatLong latLong = osRef.toLatLon();
    return latLong;
  }

  ///Returns the decimal value of a lat or long coordinate given its degrees minutes and seconds
  getDecimalFromDegree(double deg, double min, double sec) {
    double decimalDegree = deg;
    if (decimalDegree < 0) { //turns the decimal degree positive for the calculation
      decimalDegree *= -1;
    }
    decimalDegree += (min/60);
    decimalDegree += (sec/3600);

    if (deg < 0) { //turns the decimal degree back to negative if the original degree was
      decimalDegree *= -1;
    }
    return decimalDegree;
  }

  ///Returns the degrees minutes and seconds of a coordinate given its decimal value
  getDegreeFromDecimal(double dec) {
    double positiveDec = dec;
    if (dec < 0) { //if the decimal is negative, switch it to positive for the calculations
      positiveDec *= -1;
    }
    int degrees = positiveDec.toInt();
    int minutes = ((positiveDec - degrees) * 60).toInt();
    double seconds = (positiveDec - degrees - minutes/60) * 3600;
    return [dec.toInt(), minutes, seconds];
  }

}