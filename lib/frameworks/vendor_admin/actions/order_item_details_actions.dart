part of '../screens/order_item_details_screen.dart';

extension OrderItemDetailsAction on VendorAdminOrderItemDetailsScreenState {
  Future<void> _getOrderNotes() async {
    orderNotes = await _services.getVendorAdminOrderNotes(
        page: page, perPage: _perPage, orderId: widget.order.id);

    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(() {
        orderNotesLoading = false;
      });
    }
  }

//  Future<void> _loadMoreOrderNotes() async {
//    page++;
//    await _services.getVendorAdminOrderNotes(
//        page: page, perPage: _perPage, orderId: widget.order.id);
//    // ignore: invalid_use_of_protected_member
//    setState(() {});
//  }

  String formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year}';
  }

  void _cancelEdit() {
    // ignore: invalid_use_of_protected_member
    setState(() {
      _dropdownStatusValue = widget.order.status;
      _noteController.text = widget.order.customerNote!;
    });
  }

  String getDisplayStatusOrder(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return S.of(context).orderStatusPending;
      case OrderStatus.processing:
        return S.of(context).orderStatusProcessing;
      case OrderStatus.cancelled:
        //case OrderStatus.canceled:
        return S.of(context).cancel;
      case OrderStatus.refunded:
        return S.of(context).orderStatusRefunded;
      case OrderStatus.completed:
        return S.of(context).orderStatusCompleted;
      case OrderStatus.onHold:
        return S.of(context).orderStatusOnHold;
      default:
        return S.of(context).orderStatusFailed;
    }
  }

  void _updateOrder() {
    widget.onCallBack!(
        _dropdownStatusValue!.content.toLowerCase(), _noteController.text);
    Navigator.of(context).pop();
  }

  /// For IOS
  void _showBottomSheetOptions() {
    final list = [];
    for (var sts in statuses) {
      if (sts != OrderStatus.failed && getDisplayStatusOrder(sts) == 'Failed') {
        continue;
      }
      list.add(sts);
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (subContext) => CupertinoActionSheet(
        actions: List.generate(
          list.length,
          (index) {
            final status = list[index];
            return CupertinoActionSheetAction(
                onPressed: () {
                  // ignore: invalid_use_of_protected_member
                  setState(() => _dropdownStatusValue = status);
                  Navigator.of(subContext).pop();
                },
                child: Text(getDisplayStatusOrder(list[index])));
          },
        ),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(subContext).pop(),
          isDefaultAction: true,
          child: Text(S.of(context).cancel),
        ),
      ),
    );
  }

  Widget _buildListStatuses() {
    if (!isIos) {
      return DropdownButton<OrderStatus>(
        value: _dropdownStatusValue,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (OrderStatus? newValue) {
          // ignore: invalid_use_of_protected_member
          setState(() => _dropdownStatusValue = newValue);
        },
        items: _list.map<DropdownMenuItem<OrderStatus>>((status) {
          return DropdownMenuItem<OrderStatus>(
            value: status,
            child: Text(status.getTranslation(context)),
          );
        }).toList(),
      );
    }

    return InkWell(
      onTap: _showBottomSheetOptions,
      child: Container(
        padding: const EdgeInsets.only(left: 15.0, top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Text(
              _dropdownStatusValue!.getTranslation(context),
              style: TextStyle(fontSize: fontSize),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
