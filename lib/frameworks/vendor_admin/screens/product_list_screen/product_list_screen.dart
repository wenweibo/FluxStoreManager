import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../../widgets/common/common_scaffold.dart';
import '../../config/theme.dart';
import '../../models/authentication_model.dart';
import '../../models/category_model.dart';
import '../../models/product_attribute_model.dart';
import '../../models/product_list_screen_model.dart';
import '../product_management/product_managent.dart';
import 'widgets/loading_widget.dart';
import 'widgets/product_list_card_widget.dart';

class VendorAdminProductListScreen extends StatefulWidget {
  @override
  State<VendorAdminProductListScreen> createState() =>
      _VendorAdminProductListScreenState();
}

class _VendorAdminProductListScreenState
    extends State<VendorAdminProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then((_) {
      if (mounted) {
        Provider.of<VendorAdminProductListScreenModel>(context, listen: false)
          .getVendorProductList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyText1!.copyWith(
          color: Theme.of(context).colorScheme.secondary,
        );
    final model = Provider.of<VendorAdminProductListScreenModel>(context);
    final attributeModel =
        Provider.of<VendorAdminProductAttributeModel>(context);
    final model2 =
        Provider.of<VendorAdminCategoryModel>(context, listen: false);
    final user =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user;
    return CommonScaffold(
      onRefresh: model.getVendorProductList,
      controller: model.controller,
      title: S.of(context).products,
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: model,
                ),
                ChangeNotifierProvider.value(
                  value: attributeModel,
                ),
                ChangeNotifierProvider.value(
                  value: model2,
                ),
              ],
              child: ProductManagementIndex(user: user!),
            ),
          ),
        ),
      ),
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 4,
                ),
                height: 40,
                margin: const EdgeInsets.only(bottom: 6, left: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Theme.of(context).primaryColorLight,
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.7),
                    ),
                    Expanded(
                      child: TextField(
                        controller: model.searchController,
                        focusNode: model.searchFocusNode,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (val) => model.searchProduct(),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: model.clearSearchResults,
                            icon: const Icon(
                              Icons.cancel,
                              size: 18,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(5.0),
                          isDense: true,
                          fillColor: ColorsConfig.searchBackgroundColor,
                          hintText: S.of(context).search,
                          hintStyle: textStyle.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.5),
                          ),
                        ),
                        style: textStyle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        if (model.state == VendorAdminProductListScreenModelState.loading)
          ...List.generate(
              5, (index) => VendorAdminProductListCardLoadingWidget()),
        if (model.state == VendorAdminProductListScreenModelState.empty)
          Center(
            child: Text(S.of(context).noProduct),
          ),
        if (model.state == VendorAdminProductListScreenModelState.loaded &&
            model.lstSearchedVendorProduct.isNotEmpty)
          ...List.generate(
            model.lstSearchedVendorProduct.length,
            (index) {
              return VendorAdminProductListCardWidget(
                product: model.lstSearchedVendorProduct[index],
              );
            },
          ),
        if ((model.state == VendorAdminProductListScreenModelState.loaded ||
                model.state ==
                    VendorAdminProductListScreenModelState.loadMore) &&
            model.lstSearchedVendorProduct.isEmpty &&
            model.searchController.text.isEmpty)
          ...List.generate(
            model.lstVendorProduct.length,
            (index) {
              return VendorAdminProductListCardWidget(
                product: model.lstVendorProduct[index],
              );
            },
          ),
        if (model.state == VendorAdminProductListScreenModelState.loaded &&
            model.lstSearchedVendorProduct.isEmpty &&
            model.searchController.text.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(S.of(context).noResultFound),
            ],
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
