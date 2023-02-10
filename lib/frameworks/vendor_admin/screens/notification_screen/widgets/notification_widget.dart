import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../models/entities/wcfm_notification.dart';
import '../../../models/main_screen_model.dart';
import '../../../models/notification_screen_model.dart';
import '../../order_item_details_screen.dart';

class VendorAdminNotificationWidget extends StatelessWidget {
  final WCFMNotification? notificationVendorAdmin;

  const VendorAdminNotificationWidget({Key? key, this.notificationVendorAdmin})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final mainModel =
        Provider.of<VendorAdminMainScreenModel>(context, listen: false);

    Widget buildNotificationIcon() {
      var color = Colors.white;
      var icon = Icon(
        Icons.warning,
        color: color,
      );

      if (notificationVendorAdmin!.messageType == 'order') {
        icon = Icon(
          CupertinoIcons.cart_fill,
          color: color,
        );
      }
      if (notificationVendorAdmin!.messageType == 'review' ||
          notificationVendorAdmin!.messageType == 'product review') {
        icon = Icon(
          CupertinoIcons.eye,
          color: color,
        );
      }
      if (notificationVendorAdmin!.messageType == 'status update') {
        icon = Icon(
          CupertinoIcons.mail,
          color: color,
        );
      }

      return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 20,
        child: icon,
      );
    }

    Widget buildMessageTypeText() {
      Color color = Colors.red;
      if (notificationVendorAdmin!.messageType == 'order') {
        color = Colors.green;
      }
      if (notificationVendorAdmin!.messageType == 'status update') {
        color = Colors.orangeAccent;
      }
      if (notificationVendorAdmin!.messageType == 'review' ||
          notificationVendorAdmin!.messageType == 'product review') {
        color = Colors.purpleAccent;
      }

      return Text(
        notificationVendorAdmin!.messageType!.toUpperCase(),
        style: TextStyle(fontSize: 12.0, color: color),
      );
    }

    void goToOrderDetailScreen(String orderID) async {
      if (orderID.isEmpty) {
        return;
      }
      final model =
          Provider.of<VendorAdminMainScreenModel>(context, listen: false);
      final notifyModel = Provider.of<VendorAdminNotificationScreenModel>(
          context,
          listen: false);

      /// To avoid open multiple screens causes by slow connection
      if (notifyModel.state ==
          VendorAdminNotificationScreenModelState.loadItem) {
        return;
      }
      var orders;
      orders = model.orders.where((ord) => ord.id == orderID);

      var order;

      /// Have to check for length, cannot use isNotEmpty
      if (orders.length > 0) {
        order = orders.first;
      }

      order ??= await notifyModel.searchVendorOrders(orderID: orderID);
      if (order == null) {
        return;
      }

      await Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => VendorAdminOrderItemDetailsScreen(
                order: order,
                onCallBack: (String status, String customerNote) async {
                  notifyModel.showLoadingWhenUpdateOrder();
                  await mainModel.updateOrder(order, status,
                      customerNote: customerNote);
                  await Future.delayed(const Duration(milliseconds: 300)).then(
                      (value) =>
                          notifyModel.getNotification(ignoreCheck: true));
                },
              )));
    }

    return InkWell(
      onTap: () => goToOrderDetailScreen(notificationVendorAdmin!.orderId!),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
        padding: const EdgeInsets.all(
          10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).primaryColorLight,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildNotificationIcon(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificationVendorAdmin!.created!,
                    style: const TextStyle(fontSize: 10.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notificationVendorAdmin!.message!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  buildMessageTypeText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
