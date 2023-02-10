import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../models/app_model.dart';
import '../../../models/order/order.dart';
import '../screens/order_item_details_screen.dart';

class OrderItem extends StatelessWidget {
  final Order order;
  final Function(String, String)? onCallBack;

  const OrderItem({
    Key? key,
    required this.order,
    this.onCallBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency = order.currencyCode ?? Provider.of<AppModel>(context, listen: false).currencyCode;
    final currencyRate =
    (order.currencyCode?.isEmpty ?? true) ? Provider.of<AppModel>(context, listen: false).currencyRate : null;

    return InkWell(
      onTap: onCallBack != null
          ? () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => VendorAdminOrderItemDetailsScreen(
                    order: order,
                    onCallBack: onCallBack,
                  ),
                ),
              )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.number}',
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      DateFormat('d MMM, HH:mm').format(order.createdAt!),
                      style: const TextStyle(fontSize: 10.0),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.person,
                          size: 12.0,
                        ),
                        const SizedBox(width: 5.0),
                        Expanded(
                          child: Text(
                            order.shipping?.firstName ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(fontSize: 12.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Text(
                order.status!.getTranslation(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.0, color: order.status!.displayColor),
              )),
              Expanded(
                  child: Text(
                PriceTools.getCurrencyFormatted(
                  order.total,
                  currencyRate,
                  currency: currency,
                )!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.0),
              )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(height: 1),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
