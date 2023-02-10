import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/index.dart' show Order, SaleStats, User;
import '../../../services/dependency_injection.dart';
import '../services/vendor_admin.dart';

enum VendorAdminMainScreenModelState { loading, loaded }

class VendorAdminMainScreenModel extends ChangeNotifier {
  /// Service
  final _services = injector<VendorAdminService>();

  /// State
  var state = VendorAdminMainScreenModelState.loading;

  /// Your Other Variables Go Here
  SaleStats? saleStats = SaleStats();
  List<Order> orders = [];
  var _page = 1;
  User? user;
  RefreshController orderController = RefreshController();

  String? status;

  bool _isDisposed = false;

  /// Constructor
  VendorAdminMainScreenModel(this.user) {
    Future.wait([getSaleStats(), getVendorOrders()]);
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

  void updateStatusOption(String status) {
    this.status = status;
    _updateState(VendorAdminMainScreenModelState.loaded);
  }

  Future<void> getSaleStats() async {
    if (state != VendorAdminMainScreenModelState.loading) {
      _updateState(VendorAdminMainScreenModelState.loading);
    }

    saleStats = await _services.getSaleStats(cookie: user!.cookie);
    _updateState(VendorAdminMainScreenModelState.loaded);
  }

  Future<void> getVendorOrders({List<Order>? list}) async {
    _page = 1;
    if (list != null) {
      orders = list;
      _updateState(VendorAdminMainScreenModelState.loaded);
      return;
    }
    orders = await _services.getVendorAdminOrders(
        cookie: user!.cookie!, page: _page, status: status);
    _updateState(VendorAdminMainScreenModelState.loaded);
  }

  Future<void> loadMoreVendorOrders() async {
    _page++;
    var list = await _services.getVendorAdminOrders(
        cookie: user!.cookie!, page: _page, status: status);
    if (list.isEmpty) {
      orderController.loadNoData();
    } else {
      orderController.loadComplete();
      orders.addAll(list);
    }
    _updateState(VendorAdminMainScreenModelState.loaded);
  }

  Future<void> updateOrder(Order order, String status,
      {String? customerNote}) async {
    _updateState(VendorAdminMainScreenModelState.loading);
    await _services.updateOrder(order.id,
        status: status, token: user!.cookie, customerNote: customerNote);
    await getVendorOrders();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
