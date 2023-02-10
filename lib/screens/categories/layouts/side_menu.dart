import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show AppModel, Category, CategoryModel, Product;
import '../../../modules/dynamic_layout/index.dart';
import '../../../services/index.dart';
import '../../../widgets/common/paging_list.dart';
import '../../../widgets/product/product_list.dart';
import '../../base_screen.dart';

class SideMenuCategories extends StatefulWidget {
  static const String type = 'sideMenu';

  const SideMenuCategories();

  @override
  State<StatefulWidget> createState() => SideMenuCategoriesState();
}

class SideMenuCategoriesState extends State<SideMenuCategories> {
  ValueNotifier<int> selectedIndex = ValueNotifier(0);

  CategoryModel get categoryModel =>
      Provider.of<CategoryModel>(context, listen: false);

  List<Category> getSubCategories(id) {
    return categoryModel.getCategory(parentId: id) ?? <Category>[];
  }

  @override
  void dispose() {
    selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryModel>(
      builder: (context, provider, child) {
        if (provider.isFirstLoad) {
          return Center(
            child: kLoadingWidget(context),
          );
        }

        final categories =
            provider.rootCategories ?? provider.categories ?? <Category>[];

        if (categories.isEmpty) {
          return Center(
            child: Text(S.of(context).noData),
          );
        }

        return Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: ValueListenableBuilder<int>(
                valueListenable: selectedIndex,
                builder: (context, currentIndex, child) {
                  return PagingList<CategoryModel, Category>(
                    selectorData: (model) =>
                        model.rootCategories ?? <Category>[],
                    itemBuilder: (context, category, index) {
                      return _CategoryName(
                        onTap: () => selectedIndex.value = index,
                        isSelected: selectedIndex.value == index,
                        category: category,
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              flex: 6,
              child: ValueListenableBuilder<int>(
                valueListenable: selectedIndex,
                builder: (context, index, child) {
                  return _FetchProductLayout(
                    key: ValueKey(index),
                    category: categories[index],
                    subCategories: getSubCategories(categories[index].id),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}

class _CategoryName extends StatelessWidget {
  const _CategoryName({
    Key? key,
    this.onTap,
    required this.isSelected,
    required this.category,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Category category;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 15,
          left: 4,
          right: 4,
        ),
        child: Center(
          child: Text(
            category.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color:
                  isSelected ? theme.primaryColor : theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _FetchProductLayout extends StatefulWidget {
  final Category? category;
  final List<Category>? subCategories;

  const _FetchProductLayout({this.category, this.subCategories, Key? key})
      : super(key: key);

  @override
  BaseScreen<_FetchProductLayout> createState() => _StateFetchProductLayout();
}

class _StateFetchProductLayout extends BaseScreen<_FetchProductLayout> {
  int selectedIndex = 0;
  int page = 1;
  bool isEnd = false;
  bool isFetching = true;
  late CancelableCompleter completer;
  final Services _service = Services();
  List<Product> products = [];

  void onLoadMore() async {
    setState(() {
      isFetching = true;
    });
    if (widget.subCategories != null && widget.subCategories!.isNotEmpty) {
      for (var item in widget.subCategories!) {
        setState(() {
          completer = CancelableCompleter();
        });
        completer.complete(_service.api.fetchProductsByCategory(
            lang: Provider.of<AppModel>(context, listen: false).langCode,
            categoryId: item.id,
            page: page + 1));
        completer.operation.then((value) {
          setState(() {
            products = [...products, ...value];
            isFetching = false;
            page = page + 1;
          });
        });
      }
    } else {
      setState(() {
        completer = CancelableCompleter();
      });
      completer.complete(_service.api.fetchProductsByCategory(
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          categoryId: widget.category!.id,
          page: page + 1));
      completer.operation.then((value) {
        if (value.length < 2) {
          setState(() {
            isEnd = true;
          });
        }
        setState(() {
          products = [...products, ...value];
          isFetching = false;
          page = page + 1;
        });
      });
    }
  }

  void onRefresh() async {
    setState(() {
      isFetching = true;
      products = [];
    });
    if (widget.subCategories!.isNotEmpty) {
      for (var item in widget.subCategories!) {
        setState(() {
          completer = CancelableCompleter();
        });
        completer.complete(_service.api.fetchProductsByCategory(
            lang: Provider.of<AppModel>(context, listen: false).langCode,
            categoryId: item.id,
            page: 1));
        completer.operation.then((value) {
          setState(() {
            products = [...products, ...value];
            isFetching = false;
            isEnd = false;
            page = 1;
          });
        });
      }
    } else {
      setState(() {
        completer = CancelableCompleter();
      });
      completer.complete(_service.api.fetchProductsByCategory(
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          categoryId: widget.category!.id,
          page: 1));
      completer.operation.then((value) {
        setState(() {
          products = [...products, ...value];
          isFetching = false;
          isEnd = false;
          page = 1;
        });
      });
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    onRefresh();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return ProductList(
          isFetching: isFetching,
          onRefresh: onRefresh,
          onLoadMore: onLoadMore,
          isEnd: isEnd,
          products: products,
          width: constraints.maxWidth,
          padding: 4.0,
          layout: 'list',
          ratioProductImage: ProductConfig.empty().imageRatio,
          productListItemHeight: kProductDetail.productListItemHeight,
        );
      },
    );
  }
}
