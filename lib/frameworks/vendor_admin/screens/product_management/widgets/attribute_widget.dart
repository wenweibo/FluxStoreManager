import 'package:flutter/material.dart';
import 'package:inspireui/extensions.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/product_attribute.dart';
import '../../../models/product_attribute_model.dart';
import 'add_attribute_custom.dart';
import 'add_attribute_option.dart';

class AttributeWidget extends StatefulWidget {
  final List<ProductAttribute> attrs;
  final Function(List<ProductAttribute> list) onUpdate;
  const AttributeWidget({Key? key, required this.attrs, required this.onUpdate})
      : super(key: key);

  @override
  State<AttributeWidget> createState() => _AttributeWidgetState();
}

class _AttributeWidgetState extends State<AttributeWidget> {
  /// Use this to compare options
  List<ProductAttribute> currentAttrs = [];

  /// Main Attributes - Not the custom attribute that created by user
  List<ProductAttribute> availableAttrs = [];

  Widget _buildItem(ProductAttribute attr) {
    final isActive = (attr.isActive ?? false);
    var isAllOptionSelected = false;
    final currentAttrIndex =
        currentAttrs.indexWhere((element) => element.slug == attr.slug);
    if (currentAttrIndex != -1 &&
        currentAttrs[currentAttrIndex].optionSlugs.length ==
            attr.optionSlugs.length) {
      isAllOptionSelected = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              S.of(context).active,
            ),
            const Spacer(),
            Checkbox(
              value: attr.isActive,
              onChanged: (val) {
                attr.isActive = !attr.isActive!;
                currentAttrs[currentAttrIndex].isActive = val;
                widget.onUpdate(currentAttrs);
                setState(() {});
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(
              S.of(context).visible,
            ),
            const Spacer(),
            Checkbox(
              value: attr.isVisible,
              onChanged: (val) {
                attr.isVisible = !attr.isVisible!;
                currentAttrs[currentAttrIndex].isVisible = val;
                widget.onUpdate(currentAttrs);
                setState(() {});
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(
              S.of(context).variation,
            ),
            const Spacer(),
            Checkbox(
              value: attr.isVariation,
              onChanged: (val) {
                attr.isVariation = !attr.isVariation!;
                currentAttrs[currentAttrIndex].isVariation = val;
                widget.onUpdate(currentAttrs);
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(
          height: 5.0,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                attr.name?.replaceAll('-', ' ').capitalize() ??
                    attr.label?.replaceAll('-', ' ').capitalize() ??
                    '',
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: isActive ? null : Theme.of(context).dividerColor),
              ),
            ),
            InkWell(
              onTap: () {
                if (isAllOptionSelected) {
                  currentAttrs[currentAttrIndex].optionSlugs.clear();
                  currentAttrs[currentAttrIndex].options?.clear();
                } else {
                  currentAttrs[currentAttrIndex].optionSlugs =
                      List.from(attr.optionSlugs);
                  currentAttrs[currentAttrIndex].options =
                      List.from(attr.options ?? []);
                }
                widget.onUpdate(currentAttrs);
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                margin: const EdgeInsets.only(right: 15.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(width: 0.5),
                    color: !isActive
                        ? Colors.transparent
                        : isAllOptionSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent),
                child: Text(
                  S.of(context).all,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: !isActive
                          ? Theme.of(context).dividerColor
                          : isAllOptionSelected
                              ? Theme.of(context).colorScheme.onSecondary
                              : null),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Wrap(
          runSpacing: 5.0,
          children: [
            if (isActive)
              AddAttributeOption(onCreate: (option) {
                if (attr.options!.contains(option)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S.of(context).attributeAlreadyExists),
                    duration: const Duration(seconds: 2),
                  ));
                  return;
                }
                attr.optionSlugs.insert(0, option.replaceAll(' ', '-'));
                attr.options!.insert(0, option);
                setState(() {});
              }),
            ...List.generate(
              attr.options?.length ?? 0,
              (index) {
                var isSelected = false;
                if (currentAttrIndex != -1 &&
                    currentAttrs[currentAttrIndex]
                        .optionSlugs
                        .contains(attr.optionSlugs[index])) {
                  isSelected = true;
                }

                return InkWell(
                  onTap: () {
                    if (!isActive) {
                      return;
                    }
                    if (isSelected) {
                      currentAttrs[currentAttrIndex]
                          .optionSlugs
                          .remove(attr.optionSlugs[index]);
                      currentAttrs[currentAttrIndex]
                          .options!
                          .remove(attr.options![index]);
                    } else {
                      currentAttrs[currentAttrIndex]
                          .optionSlugs
                          .add(attr.optionSlugs[index]);
                      currentAttrs[currentAttrIndex]
                          .options!
                          .add(attr.options![index]);
                    }

                    widget.onUpdate(currentAttrs);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(16.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(16.0),
                      color: !isActive
                          ? Colors.transparent
                          : isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                    ),
                    child: Text(
                      attr.options![index],
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          color: !isActive
                              ? Theme.of(context).dividerColor
                              : isSelected
                                  ? Theme.of(context).colorScheme.onSecondary
                                  : null),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const Divider(
          thickness: 1.0,
        ),
      ],
    );
  }

  @override
  void initState() {
    availableAttrs = List.from(
        Provider.of<VendorAdminProductAttributeModel>(context, listen: false)
            .defaultAttributes);
    for (var attr in availableAttrs) {
      currentAttrs.add(attr.copyWith(optionSlugs: [], options: []));
    }

    for (var attr in widget.attrs) {
      /// Custom attribute - The ID always 0
      if (!(attr.isDefault ?? true)) {
        availableAttrs.insert(0, attr.copyWith());
        availableAttrs.first.isActive = true;
        currentAttrs.insert(0, availableAttrs.first.copyWith());
      } else {
        /// Main attribute
        final index =
            availableAttrs.indexWhere((element) => element.id == attr.id);

        if (index != -1) {
          availableAttrs[index].isActive = true;
          availableAttrs[index].isVisible = attr.isVisible;
          availableAttrs[index].isVariation = attr.isVariation;

          currentAttrs[index].isActive = true;
          currentAttrs[index].isVisible = attr.isVisible;
          currentAttrs[index].isVariation = attr.isVariation;

          currentAttrs[index].optionSlugs = List.from(attr.optionSlugs);
          currentAttrs[index].options = List.from(attr.options ?? <String>[]);
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddCustomAttribute(
          onAdded: (attr) {
            availableAttrs.insert(0, attr);
            currentAttrs.insert(0, attr);
            setState(() {});
          },
        ),
        ...List.generate(availableAttrs.length,
            (index) => _buildItem(availableAttrs[index])),
      ],
    );
  }
}
