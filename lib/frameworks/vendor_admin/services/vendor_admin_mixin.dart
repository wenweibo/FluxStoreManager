import 'package:flutter/cupertino.dart';

import '../../../services/dependency_injection.dart';
import '../../../services/service_config.dart';
import '../index.dart';
import 'vendor_admin.dart';

mixin VendorAdminMixin on ConfigMixin {
  @override
  void configVendorAdmin(appConfig) {
    final vendorAdminService = VendorAdminService(
      domain: appConfig['url'],
      blogDomain: appConfig['blog'],
      consumerSecret: appConfig['consumerSecret'],
      consumerKey: appConfig['consumerKey'],
      platform: appConfig['platform'],
    );
    api = vendorAdminService;
    widget = VendorAdminWidget();
    injector.registerSingleton<VendorAdminService>(vendorAdminService);
  }

  /// Get Vendor Admin App
  @override
  Widget getVendorAdminApp({languageCode, user, isFromMV}) {
    return VendorAdminApp(locale: languageCode, user: user, isFromMV: isFromMV);
  }
}
