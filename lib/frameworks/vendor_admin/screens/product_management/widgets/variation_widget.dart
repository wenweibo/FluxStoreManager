import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/variable_attributes.dart';
import '../../../../../models/index.dart';
import '../../../../../widgets/common/expansion_info.dart';
import 'variation_item.dart';

class VariationWidget extends StatelessWidget {
  final List<ProductAttribute> productAttributes;
  final List<ProductVariation>? variations;
  final Function(List<ProductVariation> list) onUpdate;

  const VariationWidget(
      {Key? key,
      required this.productAttributes,
      this.variations,
      required this.onUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var allvariations = _generateVariations();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: ExpansionInfo(
        title: S.of(context).variation,
        children: [
          _buildButton(
            context,
            icon: const Icon(Icons.add_box),
            color: Colors.green,
            onCallBack: () {
              var tmpAttr = [];
              for (var item in productAttributes) {
                if ((item.isActive ?? false) && (item.isVariation ?? false)) {
                  tmpAttr.add(item);
                }
              }

              var tmp = ProductVariation()
                ..attributeList = tmpAttr.map((e) {
                  return VariableAttribute(
                      name: e.slug ?? e.label ?? e.name ?? '',
                      attributeSlug: '',
                      attributeName: '',
                      isAny: true);
                }).toList()
                ..isActive = true
                ..regularPrice = ''
                ..salePrice = ''
                ..manageStock = false;
              variations!.insert(0, tmp);
              onUpdate(variations!);
            },
            title: S.of(context).newVariation,
          ),
          _buildButton(
            context,
            color: Colors.green,
            icon: const Icon(Icons.library_add_sharp),
            onCallBack: () {
              if (allvariations.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(S.of(context).pleaseSelectAttr),
                  duration: const Duration(seconds: 2),
                ));
                return;
              }
              onUpdate(List.from(allvariations));
            },
            title: S.of(context).createVariants,
          ),
          _buildButton(
            context,
            color: Colors.red,
            icon: const Icon(CupertinoIcons.delete),
            onCallBack: () {
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
                            onUpdate(<ProductVariation>[]);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text(
                            S.of(context).yes.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            },
            title: S.of(context).deleteAll,
          ),
          const Divider(
            thickness: 1.0,
          ),
          Column(
            children: List.generate(
              variations!.length,
              (index) {
                return VariationItem(
                  attributes: productAttributes,
                  key: Key(variations![index].id ?? UniqueKey().toString()),
                  variation: variations![index],
                  onUpdate: (variation) {
                    variations![index] = variation.copyWith();

                    var tmp = List<ProductVariation>.from(variations!);
                    onUpdate(tmp);
                  },
                  onDelete: () {
                    var tmp = List<ProductVariation>.from(variations!);
                    tmp.removeAt(index);
                    onUpdate(tmp);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // void _showDialog(BuildContext context, List<ProductVariation> allVariations,
  //     Function(List<ProductVariation>) onCallback) {
  //   if (allVariations.isEmpty) {
  //     return;
  //   }
  //   showDialog(
  //       context: (context),
  //       builder: (ctx) {
  //         final selectedVariation =
  //             List<ProductVariation>.from(variations ?? []);
  //         return Dialog(
  //           child: StatefulBuilder(
  //             builder: (ctx, StateSetter setState) => Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Expanded(
  //                   child: SingleChildScrollView(
  //                     child: Column(
  //                       children: List.generate(allVariations.length, (index) {
  //                         var name = '';
  //                         for (var item
  //                             in allVariations[index].attributeList!) {
  //                           name +=
  //                               '${item.attributeName.toString().capitalize()} - ';
  //                         }
  //                         if (name.isNotEmpty) {
  //                           name = name.substring(0, name.length - 3);
  //                         }

  //                         var isSelected = false;
  //                         var i = selectedVariation.indexWhere(
  //                             (element) => element == allVariations[index]);
  //                         if (i != -1) {
  //                           isSelected = true;
  //                         }

  //                         return Row(
  //                           children: [
  //                             const SizedBox(
  //                               width: 10.0,
  //                             ),
  //                             Expanded(
  //                               child: Text(
  //                                 name,
  //                               ),
  //                             ),
  //                             Checkbox(
  //                                 value: isSelected,
  //                                 onChanged: (val) {
  //                                   if (i != -1) {
  //                                     selectedVariation.removeAt(i);
  //                                   } else {
  //                                     selectedVariation
  //                                         .add(allVariations[index].copyWith());
  //                                   }
  //                                   setState(() {});
  //                                 }),
  //                           ],
  //                         );
  //                       }),
  //                     ),
  //                   ),
  //                 ),
  //                 InkWell(
  //                   onTap: () {
  //                     onCallback(selectedVariation);
  //                     Navigator.of(ctx).pop();
  //                   },
  //                   child: Container(
  //                     margin: const EdgeInsets.only(bottom: 10.0),
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 10, vertical: 5),
  //                     decoration: BoxDecoration(
  //                         border: Border.all(width: 0.5),
  //                         borderRadius: BorderRadius.circular(16.0)),
  //                     child: Text(S.of(context).apply),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  Widget _buildButton(
    BuildContext context, {
    VoidCallback? onCallBack,
    Color? color,
    String title = '',
    required Widget icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onCallBack,
        icon: icon,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        label: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Theme.of(context).colorScheme.onSecondary),
        ),
      ),
    );
  }

  List<ProductVariation> _generateVariations() {
    var variations = <ProductVariation>[];
    var options = <List<String>>[];
    var slugs = <List<String>>[];
    var attrNames = <String>[];
    for (var attr in productAttributes) {
      if (!(attr.isActive ?? false)) {
        continue;
      }
      if (!(attr.isVariation ?? false)) {
        continue;
      }
      var opts = <String>[];
      var sls = <String>[];

      for (var i = 0; i < attr.options!.length; i++) {
        opts.add(attr.options![i]);
        sls.add(attr.optionSlugs[i]);
      }
      options.add(opts);
      slugs.add(sls);

      attrNames.add(attr.slug ?? '');
    }
    final list =
        combinations(options, slugs, attrNames).map((e) => e.toList()).toList();

    for (var item in list) {
      if (item.isNotEmpty) {
        var variation = ProductVariation()..attributeList = item;
        variations.add(variation);
      }
    }

    return variations;
  }

  Iterable<List<VariableAttribute>> combinations<T>(
    List<List<String>> options,
    List<List<String>> slugs,
    List<String> names, [
    int index = 0,
    List<VariableAttribute>? prefix,
  ]) sync* {
    prefix ??= <VariableAttribute>[];

    if (options.length == index) {
      yield prefix;
    } else {
      for (var i = 0; i < options[index].length; i++) {
        final attribute = VariableAttribute(
            name: names[index],
            attributeSlug: slugs[index][i],
            attributeName: options[index][i],
            isAny: false);

        /// yield* means returning the data with recursive/iterable/stream
        yield* combinations(
            options, slugs, names, index + 1, prefix..add(attribute));

        prefix.removeLast();
      }
    }
  }
}
