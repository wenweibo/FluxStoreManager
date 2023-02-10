import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../common/enums/load_state.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/index.dart';
import '../../../../widgets/common/edit_product_info_widget.dart';
import '../../../../widgets/common/expansion_info.dart';
import '../../common_widgets/status_dropdown.dart';
import '../../common_widgets/variable_types_dropdown.dart';
import '../../models/product_list_screen_model.dart';
import 'product_management_model.dart';
import 'widgets/attribute_widget.dart';
import 'widgets/categories_widget.dart';
import 'widgets/current_status.dart';
import 'widgets/image_select.dart';
import 'widgets/list_image_select.dart';
import 'widgets/variation_widget.dart';

class ProductManagementIndex extends StatelessWidget {
  final Product? product;
  final User user;

  const ProductManagementIndex({Key? key, this.product, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductManagmentModel>(
        create: (_) => ProductManagmentModel(user, p: product),
        lazy: false,
        child: const ProductManagementScreen());
  }
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final productNameController = TextEditingController();
  final regularPriceController = TextEditingController();
  final salePriceController = TextEditingController();
  final sKUController = TextEditingController();
  final stockQuantity = TextEditingController();
  final shortDescription = TextEditingController();
  final description = TextEditingController();
  final tagsController = TextEditingController();

  void _initController() {
    final product =
        Provider.of<ProductManagmentModel>(context, listen: false).product;
    productNameController.text = product?.name ?? '';
    regularPriceController.text = product?.regularPrice ?? '';
    salePriceController.text = product?.salePrice ?? '';
    sKUController.text = product?.sku ?? '';
    stockQuantity.text = product?.stockQuantity.toString() ?? '0';
    shortDescription.text = product?.shortDescription ?? '';
    description.text = product?.description ?? '';
    tagsController.text =
        product?.tags.map((e) => e.name).toList().join(',') ?? '';
  }

  @override
  void initState() {
    _initController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ProductManagmentModel>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        return model.state != FSLoadState.loading;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColorLight,
              title: Text(
                model.isEdit
                    ? model.product?.name ?? S.of(context).edit
                    : S.of(context).createProduct,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              centerTitle: true,
              iconTheme: Theme.of(context).iconTheme,
              actions: [
                if (model.isEdit)
                  Center(
                    child: GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return AlertDialog(
                                  content: Text(S.of(context).areYouSure),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Text(S.of(context).cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(ctx).pop();
                                        await model.deleteProduct();
                                        unawaited(Provider.of<
                                                    VendorAdminProductListScreenModel>(
                                                context,
                                                listen: false)
                                            .getVendorProductList());

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
                        child: Text(
                          S.of(context).delete,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Colors.red),
                        )),
                  ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),
            floatingActionButton: InkWell(
              onTap: () async {
                if (model.product?.isVariableProduct ?? false) {
                  if (!model.isValidVariableProduct()) {
                    await showCupertinoDialog(
                        context: context,
                        builder: (BuildContext innerContext) {
                          return CupertinoAlertDialog(
                            title: Text(S.of(context).notifications),
                            content: Text(
                                S.of(context).productNeedAtLeastOneVariation),
                            actions: [
                              CupertinoDialogAction(
                                child: Text(S.of(context).ok),
                                onPressed: () {
                                  Navigator.of(innerContext).pop();
                                },
                              ),
                            ],
                          );
                        });
                    return;
                  }
                } else if (!model.isValidSimpleProduct()) {
                  await showCupertinoDialog(
                      context: context,
                      builder: (BuildContext innerContext) {
                        return CupertinoAlertDialog(
                          title: Text(S.of(context).notifications),
                          content: Text(S.of(context).productNeedNameAndPrice),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(S.of(context).ok),
                              onPressed: () {
                                Navigator.of(innerContext).pop();
                              },
                            ),
                          ],
                        );
                      });
                  return;
                }
                try {
                  await model.createOrUpdateProduct();

                  unawaited(Provider.of<VendorAdminProductListScreenModel>(
                          context,
                          listen: false)
                      .getVendorProductList());
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      e.toString(),
                    ),
                    duration: const Duration(seconds: 1),
                  ));
                }
              },
              child: Container(
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context)
                      .floatingActionButtonTheme
                      .backgroundColor,
                ),
                child: Center(
                  child: Text(
                    S.of(context).uploadProduct,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CurrentStatus(status: model.product!.status ?? ''),
                  Row(
                    children: [
                      const SizedBox(width: 15.0),
                      Text(
                        S.of(context).status,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      const SizedBox(width: 15.0),
                      Selector<ProductManagmentModel, String>(
                        builder: (_, status, __) {
                          return StatusDropdown(
                            onCallBack: (status) =>
                                model.setProductStatus(status!),
                            status: status,
                          );
                        },
                        selector: (_, provider) => provider.status,
                      ),
                      const Expanded(child: SizedBox(width: 10.0)),
                      Text(
                        S.of(context).productType,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      const SizedBox(width: 15.0),
                      Selector<ProductManagmentModel, String>(
                          builder: (_, type, __) {
                            return VariableTypesDropdown(
                              onCallBack: (type) => model.setProductType(type!),
                              type: type,
                            );
                          },
                          selector: (_, provider) => provider.product!.type!),
                      const SizedBox(width: 15.0),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  ProductCategoriesWidget(
                    product: model.product,
                  ),
                  EditProductInfoWidget(
                    controller: productNameController,
                    label: S.of(context).name,
                    onChanged: (val) {
                      model.product?.name = productNameController.text;
                    },
                  ),
                  Selector<ProductManagmentModel, String>(
                      builder: (_, type, __) {
                        if (type == 'variable') {
                          return const SizedBox();
                        }
                        final defaultCurrency = kAdvanceConfig.defaultCurrency;
                        return Column(
                          children: [
                            EditProductInfoWidget(
                              controller: regularPriceController,
                              label: S.of(context).regularPrice,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                model.product?.regularPrice =
                                    regularPriceController.text;
                              },
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 4.0, right: 5.0),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              color: Colors.grey, width: 0.5)),
                                    ),
                                    child: Text(
                                      defaultCurrency?.symbol ?? '',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            EditProductInfoWidget(
                              controller: salePriceController,
                              label: S.of(context).salePrice,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                model.product?.salePrice =
                                    salePriceController.text;
                              },
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 4.0, right: 5.0),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              color: Colors.grey, width: 0.5)),
                                    ),
                                    child: Text(
                                      defaultCurrency?.symbol ?? '',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      selector: (_, provider) => provider.product!.type!),
                  EditProductInfoWidget(
                    controller: sKUController,
                    label: S.of(context).sku,
                    onChanged: (val) {
                      model.product?.sku = sKUController.text;
                    },
                  ),
                  EditProductInfoWidget(
                    controller: tagsController,
                    label: S.of(context).tags,
                    onChanged: (val) {
                      model.product?.tags = tagsController.text
                          .split(',')
                          .map((e) => Tag(name: e))
                          .toList();
                    },
                  ),
                  Selector<ProductManagmentModel, bool>(
                      builder: (_, manageStock, __) {
                        return Column(
                          children: [
                            if (manageStock)
                              EditProductInfoWidget(
                                controller: stockQuantity,
                                label: S.of(context).stockQuantity,
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  model.product?.stockQuantity =
                                      int.tryParse(val);
                                },
                              ),
                            Row(
                              children: [
                                Checkbox(
                                  value: manageStock,
                                  onChanged: (val) {
                                    model.updateManageStock();
                                  },
                                ),
                                Text(S.of(context).manageStock),
                              ],
                            ),
                          ],
                        );
                      },
                      selector: (_, provider) => provider.product!.manageStock),
                  Selector<ProductManagmentModel, bool>(
                      builder: (_, inStock, __) {
                        return Row(
                          children: [
                            Checkbox(
                                value: inStock,
                                onChanged: (val) {
                                  model.updateInStock();
                                }),
                            Text(S.of(context).inStock),
                          ],
                        );
                      },
                      selector: (_, provider) =>
                          provider.product!.inStock ?? false),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    child: ExpansionInfo(
                      title: S.of(context).attributes,
                      children: [
                        Selector<ProductManagmentModel, List<ProductAttribute>>(
                            builder: (_, attrs, __) {
                              return AttributeWidget(
                                attrs: attrs,
                                onUpdate: (list) {
                                  model.updateAttrs(list);
                                },
                              );
                            },
                            selector: (_, provider) =>
                                provider.product!.vendorAdminProductAttributes),
                      ],
                    ),
                  ),
                  Consumer<ProductManagmentModel>(
                    builder: (_, model, __) {
                      if (model.product!.type != 'variable') {
                        return const SizedBox();
                      }
                      return VariationWidget(
                        variations: model.product!.variationProducts ?? [],
                        productAttributes:
                            model.product!.vendorAdminProductAttributes,
                        onUpdate: (list) {
                          model.updateVariations(list);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ImageSelect(
                    image: model.featuredImage,
                    onSelect: (image) {
                      model.updateFeatureImage(image);
                    },
                  ),
                  ListImageSelect(
                    images: model.galleryImages,
                    onSelect: (images) {
                      model.updateImages(images ?? []);
                    },
                  ),
                  EditProductInfoWidget(
                    controller: shortDescription,
                    onChanged: (val) {
                      model.product?.shortDescription = shortDescription.text;
                    },
                    label: S.of(context).shortDescription,
                  ),
                  EditProductInfoWidget(
                    controller: description,
                    label: S.of(context).description,
                    onChanged: (val) {
                      model.product?.description = description.text;
                    },
                    isMultiline: true,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Selector<ProductManagmentModel, FSLoadState>(
              builder: (_, state, __) {
                if (state == FSLoadState.loading) {
                  return Container(
                    color: Colors.black38,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox();
              },
              selector: (_, provider) => provider.state),
        ],
      ),
    );
  }
}
