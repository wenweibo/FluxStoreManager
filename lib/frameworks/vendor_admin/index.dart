import 'package:flutter/material.dart';

import '../woocommerce/index.dart';
import 'screens/main_screen/main_screen.dart';

export 'services/vendor_admin_mixin.dart';
export 'vendor_admin_app.dart';

class VendorAdminWidget extends WooWidget {
  @override
  Widget renderVendorDashBoard() {
    return const VendorAdminMainScreen();
  }
}
