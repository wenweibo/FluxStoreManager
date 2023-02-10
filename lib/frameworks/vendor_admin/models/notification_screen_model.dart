import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/index.dart' show Order, User, WCFMNotification;
import '../../../services/dependency_injection.dart';
import '../services/vendor_admin.dart';

enum VendorAdminNotificationScreenModelState {
  loading,
  loaded,
  loadMore,
  empty,
  loadItem,
}

class VendorAdminNotificationScreenModel extends ChangeNotifier {
  /// Service
  final _services = injector<VendorAdminService>();

  /// State
  var state = VendorAdminNotificationScreenModelState.loaded;

  /// Your Other Variables Go Here
  List<WCFMNotification> notifications = [];
  RefreshController refreshController = RefreshController();
  int _page = 1;
  final int _perPage = 10;
  User? user;
  bool _isDisposed = false;

  /// Constructor
  VendorAdminNotificationScreenModel(this.user) {
    getNotification();
  }

  /// Update state
  void _updateState(state) {
    if (_isDisposed) {
      return;
    }
    this.state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here

  Future<void> getNotification({bool ignoreCheck = false}) async {
    if (!ignoreCheck &&
        (state == VendorAdminNotificationScreenModelState.loading ||
            state == VendorAdminNotificationScreenModelState.loadMore)) {
      return;
    }
    refreshController.loadComplete();
    _updateState(VendorAdminNotificationScreenModelState.loading);
    _page = 1;
    notifications.clear();
    var list = <WCFMNotification>[];
    list = await _services.getNotifications(
        cookie: user!.cookie, page: _page, perPage: _perPage);
    if (list.isEmpty) {
      refreshController.refreshCompleted();
      _updateState(VendorAdminNotificationScreenModelState.empty);
      return;
    }
    notifications.addAll(list);
    refreshController.refreshCompleted();

    _updateState(VendorAdminNotificationScreenModelState.loaded);
  }

  Future<void> loadMoreNotification() async {
    if (state == VendorAdminNotificationScreenModelState.loading ||
        state == VendorAdminNotificationScreenModelState.loadMore) {
      return;
    }

    _updateState(VendorAdminNotificationScreenModelState.loadMore);
    _page++;
    var list = <WCFMNotification>[];
    list = await _services.getNotifications(
        cookie: user!.cookie, page: _page, perPage: _perPage);
    if (list.isEmpty) {
      refreshController.loadNoData();
      _updateState(VendorAdminNotificationScreenModelState.loaded);
      return;
    }
    notifications.addAll(list);
    refreshController.loadComplete();
    _updateState(VendorAdminNotificationScreenModelState.loaded);
  }

  Future<Order?> searchVendorOrders({String? orderID}) async {
    _updateState(VendorAdminNotificationScreenModelState.loadItem);

    /// remember to check for existed list tomorrow
    var orders = await _services.getVendorAdminOrders(
        cookie: user!.cookie!, page: 1, search: orderID, perPage: 10);
    if (orders.isNotEmpty) {
      _updateState(VendorAdminNotificationScreenModelState.loaded);
      return orders.first;
    }
    _updateState(VendorAdminNotificationScreenModelState.loaded);
    return null;
  }

  void showLoadingWhenUpdateOrder() {
    _updateState(VendorAdminNotificationScreenModelState.loading);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
