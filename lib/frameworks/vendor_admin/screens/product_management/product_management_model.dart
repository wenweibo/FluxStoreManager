import 'package:flutter/cupertino.dart';
import 'package:inspireui/extensions.dart';

import '../../../../common/config.dart';
import '../../../../common/enums/load_state.dart';
import '../../../../models/entities/index.dart';
import '../../../../services/dependency_injection.dart';
import '../../services/vendor_admin.dart';

class ProductManagmentModel extends ChangeNotifier {
  /// Service
  final _services = injector<VendorAdminService>();

  /// State
  var _state = FSLoadState.loaded;

  FSLoadState get state => _state;

  /// Your Other Variables Go Here
  Product? _product;

  Product? get product => _product;
  final User _user;
  String status = kVendorConfig.disablePendingProduct ? 'publish' : 'pending';

  var featuredImage;
  List<dynamic> galleryImages = [];

  bool _isEdit = false;

  bool get isEdit => _isEdit;

  ProductManagmentModel(this._user, {Product? p}) {
    if (p != null) {
      _isEdit = true;
      _product = Product.cloneFrom(p);
      if (_product?.status?.isNotEmpty ?? false) {
        status = _product!.status!;
      }
      galleryImages = List<dynamic>.from(_product?.images ?? []);
      featuredImage = _product?.vendorAdminImageFeature;
    } else {
      _product = Product()
        ..name = ''
        ..categoryIds = <String>[]
        ..type = 'simple'
        ..manageStock = true
        ..variationProducts = <ProductVariation>[]
        ..description = ''
        ..shortDescription = ''
        ..sku = ''
        ..categories = <Category>[]
        ..vendorAdminProductAttributes = <ProductAttribute>[]
        ..regularPrice = ''
        ..salePrice = ''
        ..stockQuantity = 0
        ..inStock = false;
    }
  }

  void setProductStatus(String status) {
    this.status = status;
    notifyListeners();
  }

  void setProductType(String type) {
    _product?.type = type;
    notifyListeners();
  }

  void setProductCat(Category cat) {
    final i =
        _product?.categories.indexWhere((element) => element.id == cat.id);
    if (i != null) {
      if (i != -1) {
        _product?.categories.removeAt(i);
        notifyListeners();
        return;
      }
      _product?.categories.add(cat);
      notifyListeners();
    }
  }

  void updateManageStock() {
    _product!.manageStock = !_product!.manageStock;

    notifyListeners();
  }

  void updateInStock() {
    _product!.inStock = !(_product?.inStock ?? true);

    notifyListeners();
  }

  void updateAttrs(List<ProductAttribute> list) {
    _product!.vendorAdminProductAttributes = List.from(list);
    notifyListeners();
  }

  void updateVariations(List<ProductVariation> list) {
    product!.variationProducts = List.from(list);
    notifyListeners();
  }

  Future<void> createOrUpdateProduct() async {
    _updateState(FSLoadState.loading);

    await _services.createVendorAdminProduct(
      cookie: _user.cookie!,
      product: _product!..status = status,
      images: galleryImages,
      featuredImage: featuredImage,
      isUpdate: _isEdit,
    );

    _updateState(FSLoadState.loaded);
  }

  Future<void> deleteProduct() async {
    _updateState(FSLoadState.loading);

    await _services.deleteProduct(
      cookie: _user.cookie!,
      productId: _product!.id,
    );

    _updateState(FSLoadState.loaded);
  }

  bool isValidSimpleProduct() {
    if (_product!.name.toString().isEmptyOrNull &&
        _product!.regularPrice.toString().isEmptyOrNull) {
      return false;
    }
    return true;
  }

  bool isValidVariableProduct() {
    if (_product!.variationProducts?.isEmpty ?? true) {
      return false;
    }

    return true;
  }

  void updateFeatureImage(image) {
    featuredImage = image;
    notifyListeners();
  }

  void updateImages(List<dynamic> images) {
    galleryImages = List.from(images);
    notifyListeners();
  }

  /// Update state
  void _updateState(state) {
    _state = state;
    notifyListeners();
  }
}
