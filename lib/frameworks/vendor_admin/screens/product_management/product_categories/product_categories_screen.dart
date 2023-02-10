import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/category.dart';
import '../../../models/category_model.dart';
import '../product_management_model.dart';
import 'product_categories_page.dart';

class ProductCategoriesScreen extends StatefulWidget {
  final List<Category> includedCats;
  const ProductCategoriesScreen({Key? key, required this.includedCats})
      : super(key: key);

  @override
  State<ProductCategoriesScreen> createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  int _currentPageView = 0;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _pageController = PageController();

  final _pages = <Widget>[];

  void _buildPages({String? parentId, bool isRemove = false}) {
    if (!isRemove) {
      _pages.add(Consumer<VendorAdminCategoryModel>(builder: (_, model, __) {
        return CategoriesPage(
            parentId: parentId,
            keyword: model.keyword,
            includedCategories: widget.includedCats,
            onUpdate: (cat) {
              final manageModel =
                  Provider.of<ProductManagmentModel>(context, listen: false);
              manageModel.setProductCat(cat);
            },
            onCallback: (cat) {
              _buildPages(parentId: cat!.id);
            });
      }));
      _currentPageView++;
      setState(() {});
      _pageController.animateToPage(_currentPageView,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _currentPageView--;
      _pageController.animateToPage(_currentPageView,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      setState(() {});
      _pages.removeLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyText1;
    final manageModel =
        Provider.of<ProductManagmentModel>(context, listen: false);
    final categoryModel =
        Provider.of<VendorAdminCategoryModel>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          S.of(context).categories,
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: InkWell(
          onTap: () =>
              _currentPageView == 0 ? _onBack() : _buildPages(isRemove: true),
          child: const Icon(
            Icons.arrow_back_ios_sharp,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 5.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              children: [
                Text(S.of(context).categories),
                const SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: InkWell(
                    // onTap: () => _buildPages(isRemove: true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              textAlign: TextAlign.end,
                              onChanged: categoryModel.setKeyword,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(5.0),
                                isDense: true,
                                hintText: S.of(context).search,
                                hintStyle: textStyle,
                              ),
                              style: textStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                Consumer<VendorAdminCategoryModel>(
                  builder: (_, model, __) {
                    return CategoriesPage(
                      parentId: '0',
                      keyword: model.keyword,
                      includedCategories: widget.includedCats,
                      onUpdate: (cat) {
                        manageModel.setProductCat(cat);
                      },
                      onCallback: (cat) {
                        _buildPages(
                          parentId: cat!.id,
                        );
                      },
                    );
                  },
                ),
                ..._pages
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onBack() {
    final categoryModel =
        Provider.of<VendorAdminCategoryModel>(context, listen: false);
    categoryModel.setKeyword(null);
    Navigator.pop(context);
  }
}
