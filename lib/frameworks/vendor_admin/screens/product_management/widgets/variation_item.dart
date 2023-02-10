import 'package:flutter/material.dart';
import 'package:inspireui/extensions.dart';

import '../../../../../common/config.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/product_attribute.dart';
import '../../../../../models/entities/product_variation.dart';
import '../../../../../models/entities/variable_attributes.dart';
import '../../../../../widgets/common/edit_product_info_widget.dart';

class VariationItem extends StatefulWidget {
  final ProductVariation variation;
  final List<ProductAttribute> attributes;
  final Function(ProductVariation) onUpdate;
  final VoidCallback onDelete;

  const VariationItem(
      {Key? key,
      required this.variation,
      required this.onDelete,
      required this.attributes,
      required this.onUpdate})
      : super(key: key);

  @override
  State<VariationItem> createState() => _VariationItemState();
}

class _VariationItemState extends State<VariationItem> {
  final priceController = TextEditingController();
  final saleController = TextEditingController();
  final stockController = TextEditingController();

  @override
  void initState() {
    priceController.text = widget.variation.regularPrice ?? '';
    saleController.text = widget.variation.salePrice ?? '';
    stockController.text = widget.variation.stockQuantity.toString();

    super.initState();
  }

  void _showDialog(
      VariableAttribute attr, Function(VariableAttribute) onApply) {
    final index = widget.attributes.indexWhere(
        (element) => element.slug?.toLowerCase() == attr.name.toLowerCase());

    var options = [];
    var optionSlugs = [];
    options.add('');
    optionSlugs.add('');
    if (index != -1) {
      options.addAll(widget.attributes[index].options!);
      optionSlugs.addAll(widget.attributes[index].optionSlugs);
    }

    showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            child: StatefulBuilder(builder:
                (BuildContext ctx, void Function(void Function()) setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        options.length,
                        (i) => InkWell(
                              onTap: () {
                                attr = attr.copyWith(
                                    attributeName: options[i],
                                    attributeSlug: optionSlugs[i]);

                                setState(() {});
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(options[i].isEmpty
                                        ? S
                                            .of(context)
                                            .anyAttr(index == -1
                                                ? attr.name
                                                    .replaceAll('-', ' ')
                                                    .capitalize()
                                                : widget.attributes[index].name
                                                        ?.toString()
                                                        .replaceAll('-', ' ')
                                                        .capitalize() ??
                                                    widget
                                                        .attributes[index].label
                                                        ?.toString()
                                                        .replaceAll('-', ' ')
                                                        .capitalize() ??
                                                    '')
                                            .capitalize()
                                        : options[i].toString().capitalize()),
                                  ),
                                  Icon(options[i] == attr.attributeName ||
                                          index == -1
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked),
                                ],
                              ),
                            )),
                  ),
                  InkWell(
                      onTap: () {
                        onApply(attr);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(S.of(context).apply))
                ],
              );
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final defaultCurrency = kAdvanceConfig.defaultCurrency;

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: 16.0,
            ),
            Expanded(
                child: Text(
              S.of(context).active,
              style: Theme.of(context).textTheme.subtitle1,
            )),
            Checkbox(
                value: widget.variation.isActive,
                onChanged: (val) {
                  widget.variation.isActive = !widget.variation.isActive;
                  setState(() {});
                })
          ],
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: [
                  Text(
                    S.of(context).attributes,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          widget.variation.attributeList?.length ?? 0,
                          (index) {
                            var attrName;

                            if (widget.variation.attributeList![index]
                                    .attributeName?.isNotEmpty ??
                                false) {
                              attrName = widget
                                  .variation.attributeList![index].attributeName
                                  ?.capitalize();
                            }
                            if (widget.variation.attributeList![index]
                                    .attributeSlug.isEmpty ||
                                (widget.variation.attributeList![index]
                                        .attributeName?.isEmpty ??
                                    false)) {
                              attrName = widget
                                  .variation.attributeList![index].name
                                  .replaceAll('pa_', '')
                                  .replaceAll('-', ' ')
                                  .capitalize();
                              attrName = S.of(context).anyAttr(attrName);
                            }

                            return InkWell(
                              onTap: () {
                                _showDialog(
                                    widget.variation.attributeList![index],
                                    (attr) {
                                  widget.variation.attributeList![index] =
                                      attr.copyWith();

                                  widget.onUpdate(widget.variation);
                                  setState(() {});
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(16.0)),
                                child: Row(
                                  children: [
                                    Text(
                                      attrName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary),
                                    ),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    Center(
                                        child: Icon(Icons.arrow_drop_down,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        EditProductInfoWidget(
          controller: priceController,
          label: S.of(context).regularPrice,
          keyboardType: TextInputType.number,
          onChanged: (val) {
            widget.variation.regularPrice = double.parse(val).toString();
          },
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 4.0, right: 5.0),
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                decoration: const BoxDecoration(
                  border:
                      Border(right: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Text(
                  defaultCurrency?.symbol ?? '',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
        ),
        EditProductInfoWidget(
          controller: saleController,
          label: S.of(context).salePrice,
          keyboardType: TextInputType.number,
          onChanged: (val) {
            widget.variation.salePrice = double.parse(val).toString();
          },
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 4.0, right: 5.0),
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                decoration: const BoxDecoration(
                  border:
                      Border(right: BorderSide(color: Colors.grey, width: 0.5)),
                ),
                child: Text(
                  defaultCurrency?.symbol ?? '',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
        ),
        if (widget.variation.manageStock)
          EditProductInfoWidget(
            controller: stockController,
            label: S.of(context).stockQuantity,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              widget.variation.stockQuantity = int.parse(val);
            },
          ),
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
          ),
          child: Row(
            children: [
              Expanded(child: Text(S.of(context).manageStock)),
              Checkbox(
                value: widget.variation.manageStock,
                onChanged: (val) {
                  widget.variation.manageStock = !widget.variation.manageStock;
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(S.of(context).areYouSure),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(S.of(context).cancel),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onDelete();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: Text(
                          S.of(context).ok.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                });
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(
                  color: Colors.grey, blurRadius: 2.0, offset: Offset(0, 2))
            ], color: Colors.red, borderRadius: BorderRadius.circular(16.0)),
            child: Text(
              S.of(context).delete,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
        const Divider(
          thickness: 1.0,
        ),
      ],
    );
  }
}
