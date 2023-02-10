import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/category.dart';
import '../../../../../models/entities/product.dart';
import '../../product_management/product_categories/product_categories_screen.dart';
import '../product_management_model.dart';

class ProductCategoriesWidget extends StatelessWidget {
  final Product? product;
  const ProductCategoriesWidget({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).categories,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 10),
          InkWell(
              onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: Provider.of<ProductManagmentModel>(context,
                            listen: false),
                        child: Selector<ProductManagmentModel, List<Category>>(
                            builder: (_, cats, __) {
                              return ProductCategoriesScreen(
                                includedCats: cats,
                              );
                            },
                            selector: (_, provider) =>
                                provider.product!.categories),
                      ),
                    ),
                  ),
              child: Consumer<ProductManagmentModel>(
                builder: (_, model, __) {
                  final p = model.product;

                  return Center(
                    child: Wrap(
                      children: List.generate(
                        p!.categories.length > 5 ? 6 : p.categories.length + 1,
                        (index) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 5.0),
                          margin:
                              const EdgeInsets.only(right: 10.0, bottom: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: (index == 5 || index == p.categories.length)
                              ? Text(
                                  S.of(context).more,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12.0,
                                  ),
                                )
                              : Text(
                                  p.categories[index].name!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
}
