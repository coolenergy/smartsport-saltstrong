import 'package:latlong2/latlong.dart';
import 'package:salt_strong_poc/playground/modelsV2/salt_strong_marker.dart';

class MarkerInfo extends SaltStrongMarker {
  final int? feedid;
  final int? ownerId;
  final int? userCommentId;
  final String? title;
  final String? content;
  final String? postText;
  final DateTime timestamp;
  final int? lure;
  final int? feedTopics;
  final int? feedRegion;
  final String? tipstactics;
  final String? formattedAddress;
  final int? impressions;
  final int? groupid;
  final int? meetingid;
  final int? chapterids;
  final String? userRank;
  final String? profilePhoto;
  final String? firstName;
  final String? lastName;
  final int? isInnerCircle;
  final int? foundersClub;
  final String? email;
  final String? city;
  final int? regionid;
  final int? locationid;
  final String? lureName;
  final int? lureid;
  final int? lureid1;
  final int? lureid2;
  final int? lureid3;
  final int? lureid4;
  final String? lureName1;
  final String? lureName2;
  final String? lureName3;
  final String? lureName4;
  final int? postType;
  final int? isStrongCatch;
  final String? speciesname;
  final String? speciesname1;
  final String? speciesname2;
  final String? speciesname3;
  final String? speciesname4;
  final int? speciesid;
  final int? speciesid1;
  final int? speciesid2;
  final int? speciesid3;
  final int? speciesid4;
  final int? topicid;
  final String? topicname;
  final String? regionName;
  final String? regionState;

  String get username => "$firstName $lastName";

  String get speciesNames => [speciesname, speciesname1, speciesname2, speciesname3, speciesname4]
      .where((element) => element != null)
      .join(", ");
  String get lureNames => [
        lureName,
        lureName1,
        lureName2,
        lureName3,
        lureName4,
      ].where((element) => element != null).join(", ");

  MarkerInfo({
    required this.feedid,
    required this.ownerId,
    this.userCommentId,
    required this.title,
    required this.content,
    required this.postText,
    required this.timestamp,
    required this.lure,
    required this.feedTopics,
    required this.feedRegion,
    required this.tipstactics,
    required LatLng point,
    required this.formattedAddress,
    required this.impressions,
    this.groupid,
    this.meetingid,
    this.chapterids,
    required this.userRank,
    required this.profilePhoto,
    required this.firstName,
    required this.lastName,
    required this.isInnerCircle,
    required this.foundersClub,
    required this.email,
    required this.city,
    required this.regionid,
    required this.locationid,
    required this.lureName,
    required this.lureid,
    this.lureid1,
    this.lureid2,
    this.lureid3,
    this.lureid4,
    this.lureName1,
    this.lureName2,
    this.lureName3,
    this.lureName4,
    required this.postType,
    required this.isStrongCatch,
    required this.speciesname,
    this.speciesname1,
    this.speciesname2,
    this.speciesname3,
    this.speciesname4,
    required this.speciesid,
    required this.speciesid1,
    required this.speciesid2,
    required this.speciesid3,
    this.speciesid4,
    this.topicid,
    this.topicname,
    required this.regionName,
    required this.regionState,
  }) : super(point);

  factory MarkerInfo.fromMap(Map<String?, dynamic> map) {
    return MarkerInfo(
      feedid: map['feedid'] as int?,
      ownerId: map['ownder_id'] as int?,
      userCommentId: map['usercommentid'] as int?,
      title: map['title'] as String?,
      content: map['content'] as String?,
      postText: map['postText'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      feedTopics: map['feed_topics'] as int?,
      feedRegion: map['feed_region'] as int?,
      tipstactics: map['tipstactics'] as String?,
      point: LatLng(
        double.tryParse(map['lat'].toString()) ?? 0.0,
        double.tryParse(map['lng'].toString()) ?? 0.0,
      ),
      formattedAddress: map['FormattedAddress'] as String?,
      impressions: map['Impressions'] as int?,
      groupid: map['groupid'] as int?,
      meetingid: map['meetingid'] as int?,
      chapterids: map['chapterids'] as int?,
      userRank: map['user_rank'] as String?,
      profilePhoto: map['profile_photo'] as String?,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      isInnerCircle: map['isInnerCircle'] as int?,
      foundersClub: map['founders_club'] as int?,
      email: map['email'] as String?,
      city: map['city'] as String?,
      regionid: map['regionid'] as int?,
      locationid: map['locationid'] as int?,
      lureName: map['lure_name'] as String?,
      lureid: map['lureid'] as int?,
      lureid1: map['lureid1'] as int?,
      lureid2: map['lureid2'] as int?,
      lureid3: map['lureid3'] as int?,
      lureid4: map['lureid4'] as int?,
      lureName1: map['lure_name1'] as String?,
      lureName2: map['lure_name2'] as String?,
      lureName3: map['lure_name3'] as String?,
      lureName4: map['lure_name4'] as String?,
      postType: map['postType'] as int?,
      isStrongCatch: map['isStrongCatch'] as int?,
      speciesname: map['speciesname'] as String?,
      speciesname1: map['speciesname1'] as String?,
      speciesname2: map['speciesname2'] as String?,
      speciesname3: map['speciesname3'] as String?,
      speciesname4: map['speciesname4'] as String?,
      speciesid: map['speciesid'] as int?,
      speciesid1: map['speciesid1'] as int?,
      speciesid2: map['speciesid2'] as int?,
      speciesid3: map['speciesid3'] as int?,
      speciesid4: map['speciesid4'] as int?,
      topicid: map['topicid'] as int?,
      topicname: map['topicname'] as String?,
      regionName: map['regionName'] as String?,
      regionState: map['regionState'] as String?,
      lure: map['lure'] as int?,
    );
  }

  @override
  String toString() {
    return 'MarkerInfo{feedid: $feedid, ownerId: $ownerId, userCommentId: $userCommentId, title: $title, content: $content, postText: $postText, timestamp: $timestamp, lure: $lure, feedTopics: $feedTopics, feedRegion: $feedRegion, tipstactics: $tipstactics, formattedAddress: $formattedAddress, impressions: $impressions, groupid: $groupid, meetingid: $meetingid, chapterids: $chapterids, userRank: $userRank, profilePhoto: $profilePhoto, firstName: $firstName, lastName: $lastName, isInnerCircle: $isInnerCircle, foundersClub: $foundersClub, email: $email, city: $city, regionid: $regionid, locationid: $locationid, lureName: $lureName, lureid: $lureid, lureid1: $lureid1, lureid2: $lureid2, lureid3: $lureid3, lureid4: $lureid4, lureName1: $lureName1, lureName2: $lureName2, lureName3: $lureName3, lureName4: $lureName4, postType: $postType, isStrongCatch: $isStrongCatch, speciesname: $speciesname, speciesname1: $speciesname1, speciesname2: $speciesname2, speciesname3: $speciesname3, speciesname4: $speciesname4, speciesid: $speciesid, speciesid1: $speciesid1, speciesid2: $speciesid2, speciesid3: $speciesid3, speciesid4: $speciesid4, topicid: $topicid, topicname: $topicname, regionName: $regionName, regionState: $regionState}';
  }

  @override
  List<Object> get props => [toString()];
}
