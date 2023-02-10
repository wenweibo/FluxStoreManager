import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/index.dart' show Order, SaleStats;
import '../../common_widgets/index.dart';
import '../../models/authentication_model.dart';
import 'order_list_screen_model.dart';
import 'widgets/order_earning_chart.dart';
import 'widgets/order_search.dart';

class VendorAdminOrderListScreen extends StatelessWidget {
  final List<Order> orders;
  final SaleStats? saleStats;
  final Function? updateOrdersInHomeScreen;
  final Function? updateSaleStats;
  final Function? updateNotification;

  const VendorAdminOrderListScreen({
    Key? key,
    required this.orders,
    this.saleStats,
    this.updateOrdersInHomeScreen,
    this.updateSaleStats,
    this.updateNotification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user;

    return ChangeNotifierProvider<VendorAdminOrderListScreenModel>(
      create: (_) => VendorAdminOrderListScreenModel(
          user, orders.length > 10 ? orders.sublist(0, 10) : orders),
      child: Consumer<VendorAdminOrderListScreenModel>(
        builder: (context, model, _) => Scaffold(
          appBar: AppBar(
            title: Text(
              S.of(context).yourOrders,
              style: Theme.of(context).primaryTextTheme.headline5,
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            centerTitle: true,
            backgroundColor: Theme.of(context).backgroundColor,
            iconTheme: Theme.of(context).iconTheme,
          ),
          body: Container(
            width: size.width,
            height: size.height,
            color: Theme.of(context).backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SmartRefresher(
              controller: model.orderController,
              onLoading: model.loadMoreVendorOrders,
              onRefresh: () {
                model.getVendorOrders().then((value) {
                  updateOrdersInHomeScreen!(list: model.orders);
                });
              },
              enablePullUp: model.searchedOrders.isEmpty &&
                  (model.searchController.text == '' &&
                      model.nameSearchController.text == ''),
              enablePullDown: model.searchedOrders.isEmpty &&
                  (model.searchController.text == '' &&
                      model.nameSearchController.text == ''),
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return VendorAdminOrderEarningChart(
                      saleStats: saleStats,
                    );
                  }
                  if (index == 1) {
                    return VendorAdminOrderSearch(
                      updateOrdersInHomeScreen: updateOrdersInHomeScreen,
                      controller: model.searchController,
                      nameController: model.nameSearchController,
                      onSearchOrder: model.searchVendorOrders,
                    );
                  }
                  if (index == 2) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 10.0,
                        top: 10.0,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              S.of(context).orderNo,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              S.of(context).status,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              S.of(context).earnings,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final showOrderList = model.searchedOrders.isEmpty &&
                      model.searchController.text == '' &&
                      model.nameSearchController.text == '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: model.state ==
                            VendorAdminOrderListScreenModelState.loading
                        ? VendorOrderLoadingItem()
                        : showOrderList
                            ? OrderItem(
                                order: model.orders[index - 3],
                                onCallBack:
                                    (String status, String customerNote) {
                                  model
                                      .updateOrder(
                                          model.orders[index - 3], status,
                                          customerNote: customerNote)
                                      .then((value) {
                                    updateOrdersInHomeScreen!(
                                        list: model.orders);
                                    updateSaleStats!();
                                    updateNotification!();
                                  });
                                },
                              )
                            : model.searchedOrders.isEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(
                                      top: 20.0,
                                    ),
                                    child: Center(
                                        child: Text(
                                            S.of(context).cantFindThisOrderId)),
                                  )
                                : OrderItem(
                                    order: model.searchedOrders[index - 3],
                                    onCallBack:
                                        (String status, String customerNote) {
                                      model
                                          .updateOrder(
                                              model.searchedOrders[index - 3],
                                              status,
                                              customerNote: customerNote)
                                          .then((value) {
                                        updateOrdersInHomeScreen!();
                                        updateSaleStats!();
                                      });
                                    },
                                  ),
                  );
                },
                itemCount:
                    model.state == VendorAdminOrderListScreenModelState.loading
                        ? 8
                        : model.searchedOrders.isEmpty &&
                                model.searchController.text == '' &&
                                model.nameSearchController.text == ''
                            ? model.orders.length + 3
                            : model.searchedOrders.isEmpty
                                ? 4
                                : model.searchedOrders.length + 3,
                cacheExtent: 1000,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
