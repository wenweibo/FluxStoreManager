import '../../../common/config.dart';

ManagerConfig get managerConfig =>
    ManagerConfig.fromJson(Configurations.managerConfig ?? {});

String get kAppLogo => managerConfig.appLogo;
String get kAppName => managerConfig.appName;

/// SET THIS TO FALSE IF YOUR APP DOES NOT SUPPORT DELIVERY
bool get kEnableDeliveryFeature => managerConfig.enableDeliveryFeature;

class ManagerConfig {
  late String appLogo;
  late String appName;
  late bool enableDeliveryFeature;

  ManagerConfig.fromJson(dynamic json) {
    appLogo = json['appLogo'] ?? 'assets/images/app_icon_transparent.png';
    appName = json['appName'] ?? 'FluxStore Admin';
    enableDeliveryFeature = json['enableDeliveryFeature'] ?? true;
  }

  Map toJson() {
    return {
      'appLogo': appLogo,
      'appName': appName,
      'enableDeliveryFeature': enableDeliveryFeature,
    };
  }
}
