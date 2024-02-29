import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Color;
import 'package:intl/intl.dart';

import 'package:salt_strong_poc/playground/helpers/date_time_extension.dart';

import '../constants/colors.dart';

class DailyStrikeScoreResponse {
  final List<DailyStrikeScore> dailyStrikeScore;
  final TidesOfTheDay tidesOfTheDay;
  final FeedingOfTheDay feedingOfTheDay;
  final List<SunMoon> sunMoon;
  final String timeZone;
  final List<TideFillerPeriod> tidesFiller;
  final List<MoonPhase> moonPhase;
  DailyStrikeScoreResponse({
    required this.moonPhase,
    required this.dailyStrikeScore,
    required this.tidesOfTheDay,
    required this.feedingOfTheDay,
    required this.timeZone,
    required this.sunMoon,
    required this.tidesFiller,
  });

  factory DailyStrikeScoreResponse.fromMap(Map<String, dynamic> json) => DailyStrikeScoreResponse(
        dailyStrikeScore: List<DailyStrikeScore>.from(
            json["dailyStrikeScore"].map((x) => DailyStrikeScore.fromMap(x))),
        timeZone: json["timeZone"],
        moonPhase: List<MoonPhase>.from(json["moonPhase"].map((x) => MoonPhase.fromMap(x))),
        tidesOfTheDay: TidesOfTheDay.fromMap(json["tidesOfTheDay"]),
        feedingOfTheDay: FeedingOfTheDay.fromMap(json["feedingOfTheDay"]),
        sunMoon: List<SunMoon>.from(json["sunMoon"].map((x) => SunMoon.fromMap(x))),
        tidesFiller: List<TideFillerPeriod>.from(
            json["tidesFiller"].map((x) => TideFillerPeriod.fromMap(x))),
      );
}

class MoonPhase extends Equatable {
  final DateTime dateTimeISO;
  final String moonIcon;
  final String name;

  const MoonPhase({
    required this.dateTimeISO,
    required this.moonIcon,
    required this.name,
  });

  @override
  List<Object?> get props => [dateTimeISO, moonIcon, name];

  factory MoonPhase.fromMap(Map<String, dynamic> map) {
    final datetimeString = map["dateTimeISO"];
    DateTime parsedDateTime2 = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(datetimeString);

    return MoonPhase(
      dateTimeISO: parsedDateTime2,
      moonIcon: map['moonIcon'] as String,
      name: map['name'] as String,
    );
  }
}

class TideFillerPeriod extends Equatable {
  final DateTime dateTimeISO;
  final String type;
  final double heightFT;
  final double heightM;

  const TideFillerPeriod({
    required this.dateTimeISO,
    required this.type,
    required this.heightFT,
    required this.heightM,
  });

  String get text {
    return heightFT.toStringAsFixed(2);
  }

  String get _typeLabel {
    return type == 'h' ? 'High' : 'Low';
  }

  // format example: 1:13am (High 1.645 ft)
  String get formatted {
    final hourOfTheDay = DateFormat('h:mma').format(dateTimeISO).toLowerCase();
    final typeAndHeightFtText = '$_typeLabel ${heightFT.toStringAsFixed(3)} ft';
    return '$hourOfTheDay ($typeAndHeightFtText)';
  }

  factory TideFillerPeriod.fromMap(Map<String, dynamic> map) {
    final datetimeString = map["dateTimeISO"];
    DateTime parsedDateTime2 = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(datetimeString);

    return TideFillerPeriod(
      dateTimeISO: parsedDateTime2,
      type: map['type'] as String,
      heightFT: double.parse(map['heightFT'].toString()),
      heightM: double.parse(map['heightM'].toString()),
    );
  }

  @override
  List<Object?> get props => [dateTimeISO, type, heightFT, heightM];
}

class DailyStrikeScore extends Equatable {
  final double strikeScore;
  final String dayShort;
  final String dayLong;
  final String icon;
  final double windSpeedMPH;
  final double windSpeedMinMPH;
  final double windSpeedMaxMPH;
  final double windGustMPH;
  final double maxTempF;
  final double minTempF;
  final String moonIcon;
  final String weatherPrimary;

  DateTime get dateTime => DateFormat('MM/dd/yyyy').parse(dayLong);

  DailyStrikeScore({
    required this.weatherPrimary,
    required this.windSpeedMaxMPH,
    required this.windSpeedMinMPH,
    required this.minTempF,
    required this.maxTempF,
    required this.moonIcon,
    required this.windGustMPH,
    required this.windSpeedMPH,
    required this.strikeScore,
    required this.dayShort,
    required this.dayLong,
    required this.icon,
  });

  factory DailyStrikeScore.fromMap(Map<String, dynamic> json) => DailyStrikeScore(
        weatherPrimary: json["weatherPrimary"],
        windGustMPH: double.parse(json["windGustMPH"].toString()),
        minTempF: double.parse(json["minTempF"].toString()),
        windSpeedMinMPH: double.parse(json["windSpeedMinMPH"].toString()),
        windSpeedMaxMPH: double.parse(json["windSpeedMaxMPH"].toString()),
        maxTempF: double.parse(json["maxTempF"].toString()),
        moonIcon: json["moonIcon"],
        windSpeedMPH: double.parse(json["windSpeedMPH"].toString()),
        strikeScore: double.parse(json["strikeScore"].toString()),
        dayShort: json["dayShort"],
        dayLong: json["dayLong"],
        icon: json["icon"],
      );

  @override
  List<Object?> get props => [strikeScore, dayShort, dayLong, icon, moonIcon];
}

extension StrikeScoreDoubleExtension on double {
  static double threshold = 9;

  Color? get color => this >= threshold ? SaltStrongColors.btnRed : null;
}

class FeedingOfTheDay {
  final List<FeedingActivityArr> feedingActivityArr;
  final List<ForecastOfTheDay> forecastOfTheDay;

  FeedingOfTheDay({
    required this.feedingActivityArr,
    required this.forecastOfTheDay,
  });

  factory FeedingOfTheDay.fromMap(Map<String, dynamic> json) => FeedingOfTheDay(
        feedingActivityArr: List<FeedingActivityArr>.from(
            json["feedingActivityArr"].map((x) => FeedingActivityArr.fromMap(x))),
        forecastOfTheDay: List<ForecastOfTheDay>.from(
            json["forecastOfTheDay"].map((x) => ForecastOfTheDay.fromMap(x))),
      );
}

class FeedingActivityArr {
  final int feedingVal;
  final DateTime dateTimeIso;
  final String dateF;

  FeedingActivityArr({
    required this.feedingVal,
    required this.dateTimeIso,
    required this.dateF,
  });

  factory FeedingActivityArr.fromMap(Map<String, dynamic> json) {
    return FeedingActivityArr(
      feedingVal: json["feedingVal"],
      dateTimeIso: json["dateF"].toString().toDateTime(),
      dateF: json["dateF"],
    );
  }

  Map<String, dynamic> toMap() => {
        "feedingVal": feedingVal,
        "dateTimeISO": dateTimeIso.toIso8601String(),
        "dateF": dateF,
      };
}

class ForecastOfTheDay extends Equatable {
  final int timestamp;
  final DateTime dateTimeIso;
  final int maxTempC;
  final int maxTempF;
  final int minTempC;
  final int minTempF;
  final int avgTempC;
  final int avgTempF;
  final int tempC;
  final int tempF;
  final String icon;
  final dynamic windSpeedMinMph;
  final dynamic windSpeedMaxMph;
  final dynamic windDir;
  final int windGustMph;
  final String weather;
  final String weatherPrimary;

  ForecastOfTheDay({
    required this.windSpeedMinMph,
    required this.windSpeedMaxMph,
    required this.windGustMph,
    required this.windDir,
    required this.timestamp,
    required this.dateTimeIso,
    required this.maxTempC,
    required this.maxTempF,
    required this.minTempC,
    required this.minTempF,
    required this.avgTempC,
    required this.avgTempF,
    required this.tempC,
    required this.tempF,
    required this.icon,
    required this.weather,
    required this.weatherPrimary,
  });

  factory ForecastOfTheDay.fromMap(Map<String, dynamic> json) {
    final datetimeString = json["dateTimeISO"];
    DateTime parsedDateTime2 = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(datetimeString);
    return ForecastOfTheDay(
      timestamp: json["timestamp"],
      dateTimeIso: parsedDateTime2,
      maxTempC: json["maxTempC"],
      maxTempF: json["maxTempF"],
      minTempC: json["minTempC"],
      minTempF: json["minTempF"],
      avgTempC: json["avgTempC"],
      avgTempF: json["avgTempF"],
      tempC: json["tempC"],
      tempF: json["tempF"],
      icon: json["icon"],
      windDir: json["windDir"],
      windSpeedMaxMph: json["windSpeedMaxMPH"],
      windSpeedMinMph: json["windSpeedMinMPH"],
      windGustMph: json["windGustMPH"],
      weather: json["weather"],
      weatherPrimary: json["weatherPrimary"],
    );
  }

  @override
  List<Object?> get props => [
        timestamp,
        dateTimeIso,
        maxTempC,
        maxTempF,
        minTempC,
        minTempF,
        avgTempC,
        avgTempF,
        tempC,
        tempF,
        icon,
        weather,
        weatherPrimary
      ];
}

class SunMoon {
  final int timestamp;
  final DateTime dateTimeIso;
  final Loc loc;
  final Sun sun;
  final Moon? moon;

  SunMoon({
    required this.timestamp,
    required this.dateTimeIso,
    required this.loc,
    required this.sun,
    required this.moon,
  });

  factory SunMoon.fromMap(Map<String, dynamic> json) {
    final datetimeString = json["dateTimeISO"];
    DateTime parsedDateTime2 = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(datetimeString);
    return SunMoon(
        timestamp: json["timestamp"],
        dateTimeIso: parsedDateTime2,
        loc: Loc.fromMap(json["loc"]),
        sun: Sun.fromMap(json["sun"]),
        moon: json["moon"] == null ? null : Moon.fromMap(json["moon"]),
      );
  }
}

class Loc {
  final double lat;
  final double long;

  Loc({
    required this.lat,
    required this.long,
  });

  factory Loc.fromMap(Map<String, dynamic> json) => Loc(
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "lat": lat,
        "long": long,
      };
}

class Moon {
  final DateTime? riseIso;
  final DateTime? setIso;
  final DateTime? underfootIso;
  final String phaseName;

  Moon({
    required this.riseIso,
    required this.setIso,
    required this.underfootIso,
    required this.phaseName,
  });

  factory Moon.fromMap(Map<String, dynamic> json) {
    var riseIso, setIso;
    if (json["riseISO"] != null) riseIso = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json["riseISO"]);
    if (json["setISO"] != null) setIso = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json["setISO"]);

    return Moon(
      riseIso: riseIso,
      setIso: setIso,
      underfootIso: DateTime.tryParse(json["underfootISO"].toString()),
      phaseName: json["phase"]["name"].toString(),
    );
  }
}

class Sun {
  final int rise;
  final DateTime riseIso;
  final int sunSet;
  final DateTime setIso;
  final int transit;
  final DateTime transitIso;

  Sun({
    required this.rise,
    required this.riseIso,
    required this.sunSet,
    required this.setIso,
    required this.transit,
    required this.transitIso,
  });

  factory Sun.fromMap(Map<String, dynamic> json) {
    final riseIso = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json["riseISO"]);
    final setIso = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json["setISO"]);

    return Sun(
      rise: json["rise"],
      riseIso: riseIso,
      sunSet: json["set"],
      setIso: setIso,
      transit: json["transit"],
      transitIso: DateTime.parse(json["transitISO"]),
    );
  }

  Map<String, dynamic> toMap() => {
        "rise": rise,
        "riseISO": riseIso.toIso8601String(),
        "set": sunSet,
        "setISO": setIso.toIso8601String(),
        "transit": transit,
        "transitISO": transitIso.toIso8601String(),
      };
}

class TidesOfTheDay {
  final List<TidePeriod> tidePeriods;

  TidesOfTheDay({
    required this.tidePeriods,
  });

  factory TidesOfTheDay.fromMap(Map<String, dynamic> json) => TidesOfTheDay(
        tidePeriods: List<TidePeriod>.from(json["tidePeriods"].map((x) => TidePeriod.fromMap(x))),
      );
}

class TidePeriod {
  final DateTime dateTime;
  final int timestamp;
  final String type;
  final double heightFt;
  final double heightM;
  final String dateF;
  final String dateFHh;

  TidePeriod({
    required this.dateTime,
    required this.timestamp,
    required this.type,
    required this.heightFt,
    required this.heightM,
    required this.dateF,
    required this.dateFHh,
  });

  factory TidePeriod.fromMap(Map<String, dynamic> json) {
    try {
      return TidePeriod(
        timestamp: json["timestamp"],
        dateTime: json["dateF"].toString().toDateTime(),
        type: json["type"],
        heightFt: json["heightFT"]?.toDouble(),
        heightM: json["heightM"]?.toDouble(),
        dateF: json["dateF"],
        dateFHh: json["dateF_hh"],
      );
    } catch (e) {
      print(e);
      return null!;
    }
  }
}
