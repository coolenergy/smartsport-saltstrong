import 'dart:math' as math;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';

class MarineChartNetworkTileProvider extends NetworkTileProvider {
  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final boundingBox = xyzToBounds(coordinates.x, coordinates.y, coordinates.z, null);
    logger.info(boundingBox);
    return 'https://community.saltstrong.com/arcgis/rest/services/MCS/ENCOnline/MapServer/exts/MaritimeChartService/WMSServer?EncColorScheme=Dusk&SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&SRS=EPSG:3857&FORMAT=PNG&UNIT=0&LAYERS=1,2,3,6&WIDTH=256&HEIGHT=256&TRANSPARENT=false&DisplayDepthUnits=1&display_params=%7B%22ECDISParameters%22%3A%7B%22version%22%3A%2210.8.1%22%2C%22DynamicParameters%22%3A%7B%22Parameter%22%3A%5B%7B%22name%22%3A%22AreaSymbolizationType%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22AttDesc%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22ColorScheme%22%2C%22value%22%3A0%7D%2C%7B%22name%22%3A%22CompassRose%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22DataQuality%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22DateDependencyRange%22%2C%22value%22%3A%22%22%7D%2C%7B%22name%22%3A%22DateDependencySymbols%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22DeepContour%22%2C%22value%22%3A17%7D%2C%7B%22name%22%3A%22DisplayAIOFeatures%22%2C%22value%22%3A%221%2C2%2C3%2C4%2C5%2C6%2C7%22%7D%2C%7B%22name%22%3A%22DisplayCategory%22%2C%22value%22%3A%221%2C2%2C4%22%7D%2C%7B%22name%22%3A%22DisplayDepthUnits%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22DisplaySafeSoundings%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22HonorScamin%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22IntendedUsage%22%2C%22value%22%3A%220%22%7D%2C%7B%22name%22%3A%22IsolatedDangers%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22IsolatedDangersOff%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22LabelContours%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22LabelSafetyContours%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22MovingCentroid%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22OptionalDeepSoundings%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22PointSymbolizationType%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22RemoveDuplicateText%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22SafetyContour%22%2C%22value%22%3A11%7D%2C%7B%22name%22%3A%22SafetyDepth%22%2C%22value%22%3A80%7D%2C%7B%22name%22%3A%22ShallowContour%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22TextHalo%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%22TwoDepthShades%22%2C%22value%22%3A1%7D%5D%2C%22ParameterGroup%22%3A%5B%7B%22name%22%3A%22AreaSymbolSize%22%2C%22Parameter%22%3A%5B%7B%22name%22%3A%22scaleFactor%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22minZoom%22%2C%22value%22%3A0.05%7D%2C%7B%22name%22%3A%22maxZoom%22%2C%22value%22%3A1.2%7D%5D%7D%2C%7B%22name%22%3A%22DatasetDisplayRange%22%2C%22Parameter%22%3A%5B%7B%22name%22%3A%22minZoom%22%2C%22value%22%3A0.3%7D%2C%7B%22name%22%3A%22maxZoom%22%2C%22value%22%3A1.2%7D%5D%7D%2C%7B%22name%22%3A%22LineSymbolSize%22%2C%22Parameter%22%3A%5B%7B%22name%22%3A%22scaleFactor%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22minZoom%22%2C%22value%22%3A0.75%7D%2C%7B%22name%22%3A%22maxZoom%22%2C%22value%22%3A1%7D%5D%7D%2C%7B%22name%22%3A%22PointSymbolSize%22%2C%22Parameter%22%3A%5B%7B%22name%22%3A%22scaleFactor%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22minZoom%22%2C%22value%22%3A0.75%7D%2C%7B%22name%22%3A%22maxZoom%22%2C%22value%22%3A1%7D%5D%7D%2C%7B%22name%22%3A%22TextGroups%22%2C%22Parameter%22%3A%5B%7B%22name%22%3A%2211%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2221%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2223%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2224%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2225%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2226%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2227%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2228%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2229%22%2C%22value%22%3A2%7D%2C%7B%22name%22%3A%2230%22%2C%22value%22%3A2%7D%5D%7D%2C%7B%22name%22%3A%22TextSize%22%2C%22Parameter%22%3A%5B%7B%22name%22%3A%22scaleFactor%22%2C%22value%22%3A1%7D%2C%7B%22name%22%3A%22minZoom%22%2C%22value%22%3A0.75%7D%2C%7B%22name%22%3A%22maxZoom%22%2C%22value%22%3A1%7D%5D%7D%5D%7D%7D%7D&layers=show:0,2,3,4,5,6,7&BBOX=$boundingBox';
  }
}

class HiResNetworkTileProvider extends NetworkTileProvider {
  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    var imgSize = "256,256";
    final bounds = xyzToBounds(coordinates.x, coordinates.y, coordinates.z, null);

    var url =
        "https://community.saltstrong.com/hiressat/arcgis/rest/services/World_Imagery/MapServer/export?bboxSR=&layers=&layerDefs=&size=1024,1024&imageSR=&historicMoment=&format=png&transparent=false&dpi=&time=&timeRelation=esriTimeRelationOverlaps&layerTimeOptions=&dynamicLayers=&gdbVersion=&mapScale=&rotation=&datumTransformations=&layerParameterValues=&mapRangeValues=&layerRangeValues=&clipping=&spatialFilter=&f=image&bbox=$bounds";

    return url;
  }
}

class BingTileProvider extends TileProvider {
  BingTileProvider({
    super.headers,
  });

  String _getQuadKey(int x, int y, int z) {
    final StringBuffer quadKey = StringBuffer();
    for (int i = z; i > 0; i--) {
      int digit = 0;
      final int mask = 1 << (i - 1);
      if ((x & mask) != 0) {
        digit++;
      }
      if ((y & mask) != 0) {
        digit++;
        digit++;
      }
      quadKey.write(digit);
    }
    return quadKey.toString();
  }

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    String url = options.urlTemplate ?? '';

    return url
        .replaceAll('{subdomain}', 't0')
        .replaceAll('{quadkey}', _getQuadKey(coordinates.x.toInt(), coordinates.y.toInt(), coordinates.z.toInt()))
        .replaceAll('{culture}', 'en-US');
  }

  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) {
    return CachedNetworkImageProvider(getTileUrl(coordinates, options));
  }
}

class BingNetworkTileProvider extends NetworkTileProvider {
  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final qk = tileXYToQuadKey(coordinates.x, coordinates.y, coordinates.z);
    var url =
        'https://t.ssl.ak.dynamic.tiles.virtualearth.net/comp/ch/' + qk + '?it=A,G,RL&shading=t&n=z&og=1914&o=png';

    return url;
  }

  String tileXYToQuadKey(int tileX, int tileY, int levelOfDetail) {
    StringBuffer quadKey = StringBuffer();
    for (int i = levelOfDetail; i > 0; i--) {
      String digit = '0';
      int mask = 1 << (i - 1);
      if ((tileX & mask) != 0) {
        digit = String.fromCharCode(digit.codeUnitAt(0) + 1);
      }
      if ((tileY & mask) != 0) {
        digit = String.fromCharCode(digit.codeUnitAt(0) + 2);
      }
      quadKey.writeCharCode(digit.codeUnitAt(0));
    }
    return quadKey.toString();
  }
}

// ignore: non_constant_identifier_names
final EXTENT = [-math.pi * 6378137, math.pi * 6378137];

String xyzToBounds(int x, int y, int z, mode) {
  var tileSize = (EXTENT[1] * 2) / math.pow(2, z);

  if (mode == "1024") {
    tileSize = tileSize * 4;
  }

  var minx = EXTENT[0] + x * tileSize;
  var maxx = EXTENT[0] + (x + 1) * tileSize;

  var miny = EXTENT[1] - (y + 1) * tileSize;
  var maxy = EXTENT[1] - y * tileSize;

  return '$minx,$miny,$maxx,$maxy';
}
