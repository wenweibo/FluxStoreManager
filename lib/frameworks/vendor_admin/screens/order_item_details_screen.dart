import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/widgets/skeleton_widget/skeleton_widget.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/delivery_user.dart';
import '../../../models/index.dart' show AppModel, OrderNote;
import '../../../models/order/order.dart';
import '../../../services/dependency_injection.dart';
import '../../../services/service_config.dart';
import '../../../widgets/common/box_comment.dart';
import '../../../widgets/common/expansion_info.dart';
import '../../../widgets/html/index.dart';
import '../config/app_config.dart';
import '../models/authentication_model.dart';
import '../services/vendor_admin.dart';

part '../actions/order_item_details_actions.dart';

class VendorAdminOrderItemDetailsScreen extends StatefulWidget {
  final Order order;
  final Function? onCallBack;

  const VendorAdminOrderItemDetailsScreen({
    Key? key,
    required this.order,
    this.onCallBack,
  });

  @override
  State<VendorAdminOrderItemDetailsScreen> createState() =>
      VendorAdminOrderItemDetailsScreenState();
}

class VendorAdminOrderItemDetailsScreenState
    extends State<VendorAdminOrderItemDetailsScreen> {
  final _noteController = TextEditingController();
  final fontSize = 16.0;
  final _services = injector<VendorAdminService>();
  final _perPage = 10;
  int page = 1;
  List<OrderNote> orderNotes = [];
  bool orderNotesLoading = true;

  final statuses = OrderStatus.values;
  OrderStatus? _dropdownStatusValue;
  bool _enableEdit = false;
  final List<DeliveryUser> _deliveryUsers = [];
  final _list = <OrderStatus>[
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.cancelled,
    OrderStatus.refunded,
    OrderStatus.completed,
    OrderStatus.onHold,
    OrderStatus.failed
  ];

  @override
  void initState() {
    _dropdownStatusValue = widget.order.status;
    super.initState();

    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) {
        _getOrderNotes();
      }
    });
  }

  void _onDeliveryUserAssigned(DeliveryUser user) {
    final index = _deliveryUsers.indexWhere((element) => element.id == user.id);
    if (index == -1) {
      _deliveryUsers.add(user);
    }
  }

  String get fullName => widget.order.shipping?.fullName ?? '';

  String get fullAddress => widget.order.shipping?.fullAddress ?? '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currency = widget.order.currencyCode ??
        Provider.of<AppModel>(context, listen: false).currencyCode;
    final currencyRate = (widget.order.currencyCode?.isEmpty ?? true)
        ? Provider.of<AppModel>(context, listen: false).currencyRate
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).orderDetail,
          style: Theme.of(context).primaryTextTheme.headline5,
        ),
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).backgroundColor,
        actions: [
          InkWell(
            onTap: () => setState(() {
              _enableEdit = !_enableEdit;
              if (!_enableEdit) {
                _cancelEdit();
              }
            }),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Text(
                    !_enableEdit
                        ? S.of(context).editWithoutColon
                        : S.of(context).cancel,
                    style: TextStyle(
                      color: Theme.of(context).iconTheme.color,
                    )),
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      floatingActionButton: _enableEdit
          ? InkWell(
              onTap: _updateOrder,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  S.of(context).updateStatus,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${widget.order.number}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSize),
                    ),
                  ),
                  if (!_enableEdit ||
                      (_enableEdit &&
                          [
                            OrderStatus.canceled,
                            OrderStatus.cancelled,
                            OrderStatus.refunded,
                            OrderStatus.failed
                          ].contains(widget.order.status)))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        widget.order.status!.getTranslation(context),
                        style: TextStyle(
                            color: widget.order.status!.displayColor,
                            fontSize: fontSize),
                      ),
                    ),
                  if (_enableEdit &&
                      ![
                        OrderStatus.canceled,
                        OrderStatus.cancelled,
                        OrderStatus.refunded,
                        OrderStatus.failed
                      ].contains(widget.order.status))
                    _buildListStatuses(),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.order.createdAt.toString(),
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 10),
              if (fullName.isNotEmpty) ...[
                Text(
                  S.of(context).receiver,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: fontSize),
                ),
                const SizedBox(height: 5),
                Text(
                  fullName,
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                S.of(context).deliveredTo,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              ),
              const SizedBox(height: 5),
              Text(
                fullAddress,
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 10),
              if (widget.order.paymentMethodTitle != null &&
                  widget.order.paymentMethodTitle!.isNotEmpty) ...[
                Text(
                  S.of(context).paymentMethod,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: fontSize),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.order.paymentMethodTitle!,
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(height: 10),
              ],
              if (widget.order.shippingMethodTitle != null &&
                  widget.order.shippingMethodTitle!.isNotEmpty) ...[
                Text(
                  S.of(context).shippingMethod,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: fontSize),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.order.shippingMethodTitle!,
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(height: 10),
              ],
              Container(
                height: 0.5,
                width: size.width,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                    widget.order.lineItems.length,
                    (index) => OrderLineItem(
                          lineItem: widget.order.lineItems[index],
                          isEditing: _enableEdit,
                          status: widget.order.status!,
                          deliveryUsers: _deliveryUsers,
                          onCallBack: _onDeliveryUserAssigned,
                          orderId: widget.order.id!,
                        )),
              ),
              const SizedBox(height: 10),
              Container(
                height: 0.5,
                width: size.width,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(S.of(context).tax)),
                  Builder(builder: (_) {
                    if (ServerConfig().platform.isWcfm) {
                      return Text(
                        PriceTools.getCurrencyFormatted(
                            widget.order.lineItems.fold(
                                0,
                                (dynamic sum, e) =>
                                    sum + double.parse(e.totalTax!)),
                            currencyRate,
                            currency: currency)!,
                      );
                    }
                    return Text(
                      PriceTools.getCurrencyFormatted(
                          widget.order.totalTax, currencyRate,
                          currency: currency)!,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).orderTotal,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Builder(builder: (_) {
                    if (ServerConfig().platform.isWcfm) {
                      return Text(
                        PriceTools.getCurrencyFormatted(
                            widget.order.lineItems.fold(
                                0,
                                (dynamic sum, e) =>
                                    sum + double.parse(e.total!)),
                            currencyRate,
                            currency: currency)!,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return Text(
                      PriceTools.getCurrencyFormatted(
                          widget.order.total, currencyRate,
                          currency: currency)!,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).earnings,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Builder(builder: (_) {
                    if (ServerConfig().platform.isWcfm) {
                      return Text(
                        PriceTools.getCurrencyFormatted(
                            widget.order.lineItems.fold(0, (dynamic sum, e) {
                                  return sum + double.parse(e.total ?? '0.0');
                                }) -
                                widget.order.lineItems.fold(0,
                                    (dynamic sum, e) {
                                  if (e.commissionTotal != null) {
                                    return sum + e.commissionTotal ?? 0.0;
                                  }
                                  return sum;
                                }),
                            currencyRate,
                            currency: currency)!,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return Text(
                      PriceTools.getCurrencyFormatted('0.0', currencyRate,
                          currency: currency)!,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 0.5,
                width: size.width,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: TextField(
                  controller: _noteController,
                  maxLines: null,
                  enabled: _enableEdit,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: S.of(context).writeYourNote,
                    contentPadding: const EdgeInsets.all(1.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (widget.order.customerNote != null &&
                  widget.order.customerNote!.isNotEmpty)
                ExpansionInfo(
                    expand: true,
                    title: S.of(context).customerNote,
                    children: List.generate(
                      1,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CustomPaint(
                                painter: BoxComment(
                                    color: Theme.of(context).primaryColor),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                        bottom: 25),
                                    child: HtmlWidget(
                                      widget.order.customerNote!,
                                      textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          height: 1.2),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                formatTime(widget.order.createdAt!),
                                style: const TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        );
                      },
                    )),
              if (orderNotesLoading) kLoadingWidget(context),
              if (orderNotes.isNotEmpty)
                ExpansionInfo(
                    expand: true,
                    title: S.of(context).orderNotes,
                    children: List.generate(
                      orderNotes.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              CustomPaint(
                                painter: BoxComment(
                                    color: Theme.of(context).primaryColor),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                        bottom: 25),
                                    child: HtmlWidget(
                                      orderNotes[index].note!,
                                      textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          height: 1.2),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                formatTime(DateTime.parse(
                                    orderNotes[index].dateCreated!)),
                                style: const TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        );
                      },
                    )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderLineItem extends StatefulWidget {
  final ProductItem lineItem;
  final bool isEditing;
  final OrderStatus status;
  final List<DeliveryUser> deliveryUsers;
  final onCallBack;
  final String orderId;

  const OrderLineItem(
      {Key? key,
      required this.lineItem,
      required this.isEditing,
      required this.status,
      required this.onCallBack,
      required this.deliveryUsers,
      required this.orderId})
      : super(key: key);

  @override
  State<OrderLineItem> createState() => _OrderLineItemState();
}

class _OrderLineItemState extends State<OrderLineItem> {
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (subContext) => FindDeliveryUserWidget(
              deliveryUsers: widget.deliveryUsers,
              onCallBack: _onCallback,
              orderId: widget.orderId,
              productId: widget.lineItem.productId.toString(),
              lineItemId: widget.lineItem.id!,
            ));
  }

  void _onCallback(DeliveryUser user) {
    widget.lineItem.deliveryUser = user;
    widget.onCallBack(user);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const fontSize = 16.0;
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;

    final allowToAssignDelivery = widget.isEditing &&
        widget.status == OrderStatus.processing &&
        kEnableDeliveryFeature;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                color: Colors.grey,
                child: ImageResize(
                  url: widget.lineItem.featuredImage,
                  width: 80,
                  height: 80,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.lineItem.name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (allowToAssignDelivery) ...[
                        const SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: _showBottomSheet,
                          child: const Icon(
                            Icons.local_shipping_outlined,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${S.of(context).qty}: ${widget.lineItem.quantity.toString()}',
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    runSpacing: 5,
                    children: List.generate(
                        widget.lineItem.attributes.length,
                        (i) => Container(
                              margin: const EdgeInsets.only(right: 5.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  5.0,
                                ),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              child: Text(
                                widget.lineItem.attributes[i]!,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            )),
                  ),
                  if (widget.lineItem.addonsOptions?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 5),
                    Text(
                      '${S.of(context).options}: ${widget.lineItem.addonsOptions?.toString()}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 3.0,
            vertical: 3.0,
          ),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${S.of(context).itemTotal} ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  PriceTools.getCurrencyFormatted(
                    widget.lineItem.total,
                    currencyRate,
                    currency: currency,
                  )!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: fontSize,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        if (widget.lineItem.deliveryUser != null) ...[
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 3.0,
              vertical: 3.0,
            ),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${S.of(context).deliveryBoy} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.lineItem.deliveryUser!.name!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: fontSize,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
      ],
    );
  }
}

class FindDeliveryUserWidget extends StatefulWidget {
  final onCallBack;
  final List<DeliveryUser> deliveryUsers;
  final String orderId;
  final String lineItemId;
  final String productId;

  const FindDeliveryUserWidget(
      {Key? key,
      required this.onCallBack,
      required this.deliveryUsers,
      required this.orderId,
      required this.lineItemId,
      required this.productId})
      : super(key: key);

  @override
  State<FindDeliveryUserWidget> createState() => _FindDeliveryUserWidgetState();
}

class _FindDeliveryUserWidgetState extends State<FindDeliveryUserWidget> {
  final _services = injector<VendorAdminService>();

  final TextEditingController _controller = TextEditingController();
  List<DeliveryUser> _listUser = [];
  bool _isLoading = false;

  bool _isAssigning = false;

  void _updateState(bool state) {
    _isLoading = state;
    setState(() {});
  }

  void _updateAssignState(bool state) {
    _isAssigning = state;
    setState(() {});
  }

  void _searchUser(String cookie) {
    EasyDebounce.cancel('searchUser');

    if (_controller.text.trim().isEmpty) {
      _listUser = widget.deliveryUsers;
      _updateState(false);
      return;
    }
    if (_controller.text.trim().length < 3) {
      return;
    }
    EasyDebounce.debounce('searchUser', const Duration(milliseconds: 300),
        () async {
      _updateState(true);

      _listUser = await _services.getDeliveryUsers(cookie, _controller.text);

      _updateState(false);
    });
  }

  Future<void> _updateDelivery(DeliveryUser deliveryUser) async {
    final user =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user;
    final data = {
      'wcfm_tracking_order_id': widget.orderId,
      'wcfm_tracking_order_item_id': widget.lineItemId,
      'wcfm_delivery_boy': deliveryUser.id.toString(),
      'wcfm_tracking_product_id': widget.productId,
    };
    _updateAssignState(true);
    final isSuccess = await _services.assignDeliveryUser(user!.cookie!, data);
    _updateAssignState(false);
    if (isSuccess) {
      widget.onCallBack(deliveryUser);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).failToAssign),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildDeliveryUserItem(DeliveryUser user) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        _updateDelivery(user);
      },
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Center(
                child: CachedNetworkImage(
                    imageUrl: user.profilePicture!,
                    width: 30.0,
                    height: 30.0,
                    fit: BoxFit.cover),
              )),
          const SizedBox(
            width: 10.0,
          ),
          Expanded(
              flex: 10,
              child: Text(
                user.name.toString(),
                style: theme.textTheme.headline6,
              )),
        ],
      ),
    );
  }

  Widget _buildDeliveryLoadingUserItem() {
    return Row(
      children: const [
        Expanded(
            flex: 1,
            child: Center(
              child: Skeleton(
                width: 30.0,
                height: 30.0,
              ),
            )),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          flex: 10,
          child: Skeleton(
            height: 20,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    _listUser = widget.deliveryUsers;
    super.initState();
  }

  @override
  void dispose() {
    EasyDebounce.cancel('searchUser');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user;
    final showEmpty =
        !_isLoading && _controller.text.trim().length >= 3 && _listUser.isEmpty;
    final showSearchHinText =
        !_isLoading && _controller.text.trim().length < 3 && _listUser.isEmpty;
    return Stack(
      children: [
        Container(
          color: theme.backgroundColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 30.0,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 0.1,
                        color: theme.colorScheme.secondary,
                      ))),
                      child: TextField(
                        controller: _controller,
                        onChanged: (val) => _searchUser(user!.cookie!),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'At least 3 characters...'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              if (_isLoading)
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: _buildDeliveryLoadingUserItem(),
                    ),
                    itemCount: 5,
                  ),
                ),
              if (showEmpty)
                Expanded(
                  child: Center(
                    child: Text(S.of(context).noData),
                  ),
                ),
              if (showSearchHinText)
                Expanded(
                  child: Center(
                    child: Text(S.of(context).searchByName),
                  ),
                ),
              if (!showEmpty && !_isLoading)
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: _buildDeliveryUserItem(_listUser[index]),
                    ),
                    itemCount: _listUser.length,
                  ),
                ),
            ],
          ),
        ),
        if (_isAssigning)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: kLoadingWidget(context),
            ),
          ),
      ],
    );
  }
}
