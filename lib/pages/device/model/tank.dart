import 'package:iot_theapp/pages/device/entity/item_entity.dart';
import 'package:iot_theapp/pages/device/model/item.dart';
import 'package:meta/meta.dart';

@immutable
class Tank extends Item{
  final String id;
  final String uid;
  final int index;
  final String name;
  final String deviceId;

  final String updatedWhen;

  String wTankType;
  double wFilledDepth;
  double wHeight;
  double wWidth;
  double wDiameter;
  double wSideLength;
  double wLength;

  Tank({
    String? id,
    String? uid,
    int index = 0,
    String name = '',
    String deviceId = '',

    String updatedWhen = '',

    String wTankType = '',
    double wFilledDepth = 0,
    double wHeight = 0,
    double wWidth = 0,
    double wDiameter = 0,
    double wSideLength = 0,
    double wLength = 0,

  })
    : this.index = index,
      this.name = name ?? '',
      this.deviceId = deviceId ?? '',

      this.id = id ?? '',
      this.uid = uid ?? '',
      this.updatedWhen = updatedWhen ?? '',


      this.wTankType = wTankType ?? '',
      this.wFilledDepth = wFilledDepth ?? 0,
      this.wHeight = wHeight ?? 0,
      this.wWidth = wWidth ?? 0,
      this.wDiameter = wDiameter ?? 0,
      this.wSideLength = wSideLength ?? 0,
      this.wLength = wLength ?? 0

    ;

  Tank copyWith({
    String? id,
    String? uid,
    int? index,
    String? name,
    String? deviceId,
    String? updatedWhen,

    String? wTankType,
    double? wFilledDepth,
    double? wHeight,
    double? wWidth,
    double? wDiameter,
    double? wSideLength,
    double? wLength,

  }) {
    return Tank(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      index: index ?? this.index,
      name: name ?? this.name,
      deviceId: deviceId ?? this.deviceId,
      updatedWhen: updatedWhen ?? this.updatedWhen,

      wTankType: wTankType ?? this.wTankType,
      wFilledDepth: wFilledDepth ?? this.wFilledDepth,
      wHeight: wHeight ?? this.wHeight,
      wWidth: wWidth ?? this.wWidth,
      wDiameter: wDiameter ?? this.wDiameter,
      wSideLength: wSideLength ?? this.wSideLength,
      wLength: wLength ?? this.wLength,
    );
  }

  @override
  int get hashCode =>
      id.hashCode ^
      uid.hashCode ^
      index.hashCode ^
      name.hashCode ^
      deviceId.hashCode ^
      updatedWhen.hashCode ^
      wTankType.hashCode ^
      wFilledDepth.hashCode ^
      wHeight.hashCode ^
      wWidth.hashCode ^
      wDiameter.hashCode ^
      wSideLength.hashCode ^
      wLength.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tank &&

          runtimeType == other.runtimeType &&
          id == other.id &&
          uid == other.uid &&
          index == other.index &&
          deviceId == other.deviceId &&
          updatedWhen == other.updatedWhen &&

          wTankType == other.wTankType &&
          wFilledDepth == other.wFilledDepth &&
          wHeight == other.wHeight &&
          wWidth == other.wWidth &&

          wDiameter == other.wDiameter &&
          wSideLength == other.wSideLength &&
          wLength == other.wLength &&

          name == other.name; // &&

  @override
  String toString() {
    return 'Tank { id: $id, '
        'uid: $uid, '
        'index: $index, '
        'name: $name, '
        'deviceId: $deviceId, '
        'updatedWhen: $updatedWhen, '
        'wTankType: $wTankType, '
        'wFilledDepth: $wFilledDepth, '
        'wHeight: $wHeight, '
        'wWidth: $wWidth, '
        'wDiameter: $wDiameter, '
        'wSideLength: $wSideLength, '
        'wLength: $wLength}';
  }

  ItemEntity toEntity() {
    return ItemEntity(id, uid, index, name);
  }

  static Tank fromEntity(ItemEntity entity) {
    return Tank(
      id: entity.id,
      uid: entity.uid,
      index: entity.index,
      name: entity.name,
    );
  }

  factory Tank.fromJson(Map<dynamic, dynamic> json) {
    print('Tank.fromJson json= ${json}');
    return Tank(
      uid: json['uid'] ?? '',
      deviceId: json['deviceId'] ?? '',
      wTankType: json['wTankType'] ?? '',
      wFilledDepth: json['wFilledDepth'].toDouble() ?? 0,
      wHeight: json['wHeight'].toDouble() ?? 0,
      wWidth: json['wWidth'].toDouble() ?? 0,
      wDiameter: json['wDiameter'].toDouble() ?? 0,
      wSideLength: json['wSideLength'].toDouble() ?? 0,
      wLength: json['wLength'].toDouble() ?? 0,
    );
  }


}