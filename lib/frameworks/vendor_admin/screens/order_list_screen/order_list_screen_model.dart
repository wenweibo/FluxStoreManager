import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../models/index.dart' show Order, User;
import '../../../../models/order/order.dart';
import '../../../../services/dependency_injection.dart';
import '../../services/vendor_admin.dart';

enum VendorAdminOrderListScreenModelState { loading, loaded }

enum SearchOption { name, orderId }

class VendorAdminOrderListScreenModel extends ChangeNotifier {
  /// Service
  final _services = injector<VendorAdminService>();

  /// State
  var state = VendorAdminOrderListScreenModelState.loaded;

  /// Your Other Variables Go Here
  OrderStatus? status;
  List<Order> orders = [];
  List<Order> searchedOrders = [];
  var _page = 1;
  final int _perPage = 10;
  User? user;
  RefreshController orderController = RefreshController();
  final TextEditingController nameSearchController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  var searchOption = SearchOption.orderId;

  /// Constructor
  VendorAdminOrderListScreenModel(this.user, this.orders);

  /// Update state
  void _updateState(state) {
    /// Use try/catch to ignore the dispose error in case of
    /// user immediately goes back after accessing a new route
    try {
      this.state = state;
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  /// Your Defined Functions Go Here
  void updateStatusOption(OrderStatus? status) {
    this.status = status;
    _updateState(VendorAdminOrderListScreenModelState.loaded);
  }

  bool updateSearchOption(SearchOption option) {
    if (searchOption != option) {
      searchOption = option;
      searchController.clear();
      nameSearchController.clear();
      _updateState(VendorAdminOrderListScreenModelState.loaded);
      return true;
    }
    return false;
  }

  Future<void> getVendorOrders() async {
    if (searchController.text == '' && nameSearchController.text == '') {
      searchedOrders.clear();
    }
    _updateState(VendorAdminOrderListScreenModelState.loading);
    _page = 1;

    orders = await _services.getVendorAdminOrders(
        cookie: user!.cookie!,
        page: _page,
        status: status?.content,
        perPage: _perPage);
    orderController.loadComplete();
    orderController.refreshCompleted();
    _updateState(VendorAdminOrderListScreenModelState.loaded);
  }

  Future<void> loadMoreVendorOrders() async {
    _page++;
    var list = await _services.getVendorAdminOrders(
        cookie: user!.cookie!,
        page: _page,
        status: status?.content,
        perPage: _perPage);
    if (list.isEmpty) {
      orderController.loadNoData();
    } else {
      orderController.loadComplete();
      orders.addAll(list);
    }
    _updateState(VendorAdminOrderListScreenModelState.loaded);
  }

  void searchVendorOrders() {
    EasyDebounce.cancel('searchProduct');
    EasyDebounce.debounce(
        'searchVendorOrders', const Duration(milliseconds: 500), () async {
      _updateState(VendorAdminOrderListScreenModelState.loading);
      if (searchController.text != '' || nameSearchController.text != '') {
        searchedOrders.clear();
        searchedOrders = await _services.getVendorAdminOrders(
            cookie: user!.cookie!,
            page: 1,
            status: status?.content,
            search: searchOption != SearchOption.orderId
                ? null
                : searchController.text,
            name: searchOption != SearchOption.name
                ? null
                : nameSearchController.text,
            perPage: _perPage);
      } else {
        searchedOrders.clear();
      }
      _updateState(VendorAdminOrderListScreenModelState.loaded);
    });
  }

  Future<void> updateOrder(Order order, String status,
      {String? customerNote}) async {
    _updateState(VendorAdminOrderListScreenModelState.loading);
    await _services.updateOrder(order.id,
        status: status, customerNote: customerNote, token: user!.cookie);
    await getVendorOrders();
    _updateState(VendorAdminOrderListScreenModelState.loaded);
  }
}
