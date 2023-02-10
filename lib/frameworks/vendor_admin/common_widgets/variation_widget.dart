import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../models/entities/vendor_admin_variation.dart';
import '../../../widgets/common/expansion_info.dart';
import 'variation_product.dart';

class VariationWidget extends StatefulWidget {
  final productAttributes;
  final List<VendorAdminVariation>? variations;
  const VariationWidget({Key? key, this.productAttributes, this.variations})
      : super(key: key);
  @override
  State<VariationWidget> createState() => _VariationWidgetState();
}

class _VariationWidgetState extends State<VariationWidget> {
  void _addNewVariation() {
    widget.variations!.add(VendorAdminVariation());
    widget.productAttributes.forEach((k, v) {
      final attrKey = v['slug'];
      widget.variations!.last.attributes![attrKey] = '';
      widget.variations!.last.slugs![attrKey] = '';
    });
    setState(() {});
  }

  void _delete(int index) {
    widget.variations!.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: ExpansionInfo(
        title: S.of(context).variation,
        children: [
          Column(
            children: List.generate(
              widget.variations!.length,
              (index) {
                return VariationProductWidget(
                  productAttributes: widget.productAttributes,
                  variation: widget.variations![index],
                  onDelete: () => _delete(index),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor, // foreground
            ),
            onPressed: _addNewVariation,
            child: Text(
              S.of(context).addNew,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
