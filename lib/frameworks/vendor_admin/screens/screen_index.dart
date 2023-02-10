import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../models/entities/fstore_notification_item.dart';
import '../../../services/dependency_injection.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/service_config.dart';
import '../models/export.dart';
import 'chat_screen/vendor_chat_screen.dart';
import 'main_screen/main_screen.dart';
import 'notification_screen/notification_screen.dart';
import 'product_list_screen/product_list_screen.dart';
import 'review_approval_screen/review_approval_screen.dart';
import 'setting_screen/setting_screen.dart';

class ScreenIndex extends StatefulWidget {
  final bool isFromMv;

  const ScreenIndex({Key? key, this.isFromMv = false}) : super(key: key);

  @override
  State<ScreenIndex> createState() => ScreenIndexState();
}

class ScreenIndexState extends State<ScreenIndex>
    implements NotificationDelegate {
  int pageIndex = 0;
  var _context;

  void _refreshData() {
    final model = Provider.of<VendorAdminNotificationScreenModel>(_context,
        listen: false);
    final model2 =
        Provider.of<VendorAdminMainScreenModel>(_context, listen: false);

    /// To prevent the APIs call twice
    if (model.state == VendorAdminNotificationScreenModelState.loading ||
        model2.state == VendorAdminMainScreenModelState.loading) {
      return;
    }
    model.getNotification();
    Future.wait([model2.getSaleStats(), model2.getVendorOrders()]);
  }

  @override
  void onMessage(FStoreNotificationItem notification) {
    _refreshData();
  }

  @override
  void onMessageOpenedApp(FStoreNotificationItem notification) {
    _refreshData();
  }

  @override
  void initState() {
    /// Init VendorAdminProductAttributeModel to get all default attributes
    Provider.of<VendorAdminProductAttributeModel>(context, listen: false);

    super.initState();
    _context = context;

    /// Because the late variable can't be checked if it already initialized or not.
    /// So this code must be put in a try catch to avoid this error
    /// LateInitializationError: Field 'delegate' has not been initialized
    /// If you have a better solution, enlighten me!
    try {
      final notificationService = injector<NotificationService>();
      if (!widget.isFromMv && !notificationService.isInitialized) {
        notificationService.init(notificationDelegate: this);
        notificationService.requestPermission();
      }
    } catch (e) {
      printLog(e);
    }
  }

  List<Map<dynamic, dynamic>> _buildScreens() {
    var screens = List<Map>.from(managerTab);
    if (widget.isFromMv) {
      screens.removeWhere((element) => element['type'] == 'settings');
    }
    var framework = ServerConfig().platform;
    if ([ConfigType.woo, ConfigType.dokan, ConfigType.wcfm].contains(ServerConfig().type)) {
      framework = ServerConfig().typeName;
    }
    /// Init screens
    switch (framework) {
      case 'dokan':
        screens.removeWhere((element) => element['type'] == 'notifications');
        break;
      case 'woo':
        screens.removeWhere((element) =>
            ['notifications', 'reviews'].contains(element['type']));
        break;
      case 'wcfm':
      default:
    }
    return screens;
  }

  @override
  Widget build(BuildContext context) {
    var screens = _buildScreens();

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
        currentIndex: pageIndex,
        onTap: (int newValue) {
          setState(() {
            pageIndex = newValue;
          });
        },
        items: List.generate(
          screens.length,
          (index) => BottomNavigationBarItem(
            icon: screens[index]['icon'],
            label: screens[index]['label'],
          ),
        ),
      ),
      // ignore: missing_return
      tabBuilder: (BuildContext context, int index) {
        switch (screens[index]['type']) {
          case 'dashboard':
            return VendorAdminMainScreen(isFromMv: widget.isFromMv);
          case 'products':
            return VendorAdminProductListScreen();
          case 'notifications':
            return VendorAdminNotificationScreen();
          case 'reviews':
            return VendorAdminReviewApprovalScreen();
          case 'chatListScreen':
            return VendorChatScreen();
          case 'settings':
            return VendorAdminSettingScreen(
              isFromMV: widget.isFromMv,
            );
          default:
            return Container();
        }
      },
    );
  }
}

extension ExtensionScreen on ScreenIndexState {
  List<Map> get managerTab => [
        {
          'type': 'dashboard',
          'icon': const Icon(
            CupertinoIcons.rectangle_grid_2x2_fill,
            key: Key('dashboardTab'),
            size: 22,
          ),
          'label': S.of(context).dashboard,
        },
        {
          'type': 'products',
          'icon': const Icon(
            CupertinoIcons.cube_fill,
            key: Key('productsTab'),
            size: 22,
          ),
          'label': S.of(context).products,
        },
        {
          'type': 'notifications',
          'icon': const Icon(
            CupertinoIcons.bell_fill,
            key: Key('notificationsTab'),
            size: 22,
          ),
          'label': S.of(context).notifications,
        },
        {
          'type': 'chatListScreen',
          'icon': const Icon(
            CupertinoIcons.chat_bubble_text_fill,
            key: Key('chatListTab'),
            size: 22,
          ),
          'label': S.of(context).chatListScreen,
        },
        {
          'type': 'settings',
          'icon': const Icon(
            CupertinoIcons.square_list_fill,
            key: Key('settingsTab'),
            size: 22,
          ),
          'label': S.of(context).settings,
        },
      ];
}
