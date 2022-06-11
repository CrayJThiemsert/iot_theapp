import 'package:iot_theapp/pages/device/entity/item_entity.dart';
import 'package:iot_theapp/pages/device/model/item.dart';
import 'package:meta/meta.dart';

@immutable
class Device extends Item{
  final String id;
  final String uid;
  final int index;
  final String name;
  final String mode;
  final String localip;
  final int readingInterval;
  final double humidity;
  final double temperature;
  final double readVoltage;
  final String updatedWhen;


  double notifyHumidLower;
  double notifyHumidHigher;
  double notifyTempLower;
  double notifyTempHigher;
  String notifyEmail;

  final String wTankType;
  final double wFilledDepth;
  final double wHeight;
  final double wWidth;
  final double wDiameter;
  final double wSideLength;
  final double wLength;

  // List<Header> headers;
  // List<ItemData> itemDatas;
  // Topic topic;

  Device({
    String? id,
    String? uid,
    int index = 0,
    String name = '',
    String mode = '',
    String localip = '',
    int readingInterval = 0,
    double humidity = 0,
    double temperature = 0,
    double readVoltage = 0,
    String updatedWhen = '',
    bool isSendNotify = false,

    double notifyHumidLower = 0,
    double notifyHumidHigher = 0,
    double notifyTempLower = 0,
    double notifyTempHigher = 0,
    String notifyEmail = '',
    String wTankType = '',
    double wFilledDepth = double.nan,
    double wHeight = double.nan,
    double wWidth = double.nan,
    double wDiameter = double.nan,
    double wSideLength = double.nan,
    double wLength = double.nan,

    // List<Header> headers,
    // List<ItemData> itemDatas,
    // Topic topic,

  })
    : this.index = index,
      this.name = name ?? '',
      this.mode = mode ?? '',
      this.localip = localip ?? '',
      this.readingInterval = readingInterval ?? 0,
      this.humidity = humidity ?? 0,
      this.temperature = temperature ?? 0,
      this.readVoltage = readVoltage ?? 0,
      this.id = id ?? '',
      this.uid = uid ?? '',
      this.updatedWhen = updatedWhen ?? '',

      this.notifyHumidLower = notifyHumidLower ?? 0,
      this.notifyHumidHigher = notifyHumidHigher ?? 0,
      this.notifyTempLower = notifyTempLower ?? 0,
      this.notifyTempHigher = notifyTempHigher ?? 0,
      this.notifyEmail = notifyEmail ?? '',
      this.wTankType = wTankType ?? '',

      this.wFilledDepth = double.nan,
      this.wHeight = double.nan,
      this.wWidth = double.nan,
      this.wDiameter = double.nan,
      this.wSideLength = double.nan,
      this.wLength = double.nan
      // this.headers = headers,
      // this.itemDatas = itemDatas,
      // this.topic = topic
    ;

  Device copyWith({
    String? id,
    String? uid,
    int? index,
    String? name,
    String? mode,
    String? localip,
    int? readingInterval,
    double? humidity,
    double? temperature,
    double? readVoltage,
    String? updatedWhen,
    bool? isSendNotify,

    double? notifyHumidLower,
    double? notifyHumidHigher,
    double? notifyTempLower,
    double? notifyTempHigher,

    String? notifyEmail,
    String? wTankType,
    double? wFilledDepth,
    double? wHeight,
    double? wWidth,
    double? wDiameter,
    double? wSideLength,
    double? wLength,

    // List<Header> headers,
    // List<ItemData> itemDatas,
    // Topic topic,
  }) {
    return Device(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      index: index ?? this.index,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      localip: localip ?? this.localip,
      readingInterval: readingInterval ?? this.readingInterval,
      humidity: humidity ?? this.humidity,
      temperature: temperature ?? this.temperature,
      readVoltage: readVoltage ?? this.readVoltage,
      updatedWhen: updatedWhen ?? this.updatedWhen,


      notifyHumidLower: notifyHumidLower ?? this.notifyHumidLower,
      notifyHumidHigher: notifyHumidHigher ?? this.notifyHumidHigher,
      notifyTempLower: notifyTempLower ?? this.notifyTempLower,
      notifyTempHigher: notifyTempHigher ?? this.notifyTempHigher,
      notifyEmail: notifyEmail ?? this.notifyEmail,
      wTankType: wTankType ?? this.wTankType,

      wFilledDepth: wFilledDepth ?? this.wFilledDepth,
      wHeight: wHeight ?? this.wHeight,
      wWidth: wWidth ?? this.wWidth,
      wDiameter: wDiameter ?? this.wDiameter,
      wSideLength: wSideLength ?? this.wSideLength,
      wLength: wLength ?? this.wLength,

      // headers: headers ?? this.headers,
      // itemDatas: itemDatas ?? this.itemDatas,
      // topic: topic ?? this.topic,
    );
  }

  @override
  int get hashCode =>
      id.hashCode ^
      uid.hashCode ^
      index.hashCode ^
      name.hashCode ^
      mode.hashCode ^
      localip.hashCode ^
      readingInterval.hashCode ^
      humidity.hashCode ^
      temperature.hashCode ^
      readVoltage.hashCode ^
      updatedWhen.hashCode ^

      notifyHumidLower.hashCode ^
      notifyHumidHigher.hashCode ^
      notifyTempLower.hashCode ^
      notifyTempHigher.hashCode ^
      notifyEmail.hashCode ^
      wTankType.hashCode ^
      wFilledDepth.hashCode ^
      wHeight.hashCode ^
      wWidth.hashCode ^
      wDiameter.hashCode ^
      wSideLength.hashCode ^
      wLength.hashCode
  ;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&

          runtimeType == other.runtimeType &&
          id == other.id &&
          uid == other.uid &&
          index == other.index &&
          mode == other.mode &&
          localip == other.localip &&
          readingInterval == other.readingInterval &&
          humidity == other.humidity &&
          temperature == other.temperature &&
          readVoltage == other.readVoltage &&
          updatedWhen == other.updatedWhen &&

          notifyHumidLower == other.notifyHumidLower &&
          notifyHumidHigher == other.notifyHumidHigher &&
          notifyTempLower == other.notifyTempLower &&
          notifyTempHigher == other.notifyTempHigher &&

          notifyEmail == other.notifyEmail &&
          wTankType == other.wTankType &&

          wFilledDepth == other.wFilledDepth &&
          wHeight == other.wHeight &&
          wWidth == other.wWidth &&
          wDiameter == other.wDiameter &&
          wSideLength == other.wSideLength &&
          wLength == other.wLength &&

          name == other.name; // &&
        // headers == other.headers &&
        // itemDatas == other.itemDatas &&
        // topic == other.topic;

  @override
  String toString() {
    return 'Device { id: $id, uid: $uid, index: $index, name: $name, mode: $mode, localip: $localip, readingInterval: $readingInterval, humidity: $humidity, temperature: $temperature, readVoltage: $readVoltage, updatedWhen: $updatedWhen, notifyHumidLower: $notifyHumidLower, notifyHumidHigher: $notifyHumidHigher, notifyTempLower: $notifyTempLower, notifyTempHigher: $notifyTempHigher, notifyEmail: $notifyEmail, '
        'wTankType: $wTankType,'
        'wFilledDepth: $wFilledDepth,'
        'wHeight: $wHeight,'
        'wWidth: $wWidth,'
        'wDiameter: $wDiameter,'
        'wSideLength: $wSideLength,'
        'wLength: $wLength,'
        '}'; //, headers: $headers, itemDatas: ${itemDatas}, topic: ${topic} }';
  }

  ItemEntity toEntity() {
    return ItemEntity(id, uid, index, name);
  }

  static Device fromEntity(ItemEntity entity) {
    return Device(
      id: entity.id,
      uid: entity.uid,
      index: entity.index,
      name: entity.name,
    );
  }
}