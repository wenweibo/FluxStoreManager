import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/enums/load_state.dart';
import '../../../models/entities/category.dart';
import '../../../services/dependency_injection.dart';
import '../services/vendor_admin.dart';

enum VendorAdminCategoryModelState { loading, loaded }

class VendorAdminCategoryModel extends ChangeNotifier {
  /// Service
  final _services = injector<VendorAdminService>();

  /// State
  var _state = FSLoadState.loaded;

  FSLoadState get state => _state;

  /// Your Other Variables Go Here
  Map<String?, Map<String, dynamic>> map = {};
  List<Category> categories = [];
  int _page = 1;
  final int perPage = 100;

  late SharedPreferences _sharedPreferences;

  final List<Category> _cats = [];
  List<Category> get cats => _cats;
  bool _isDisposed = false;
  String? _keyword;
  String? get keyword => _keyword;

  /// Constructor
  VendorAdminCategoryModel() {
    getAllRootCategories();
    initLocalStorage().then((value) => getAllCategories());
  }

  void _updateState(state) {
    _state = state;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void setKeyword(String? keyword) {
    _keyword = keyword;
    notifyListeners();
  }

  /// Your Defined Functions Go Here

  Future<void> initLocalStorage() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> getAllRootCategories() async {
    final list = await _services.getVendorAdminCategoriesByPage(
        perPage: perPage, offset: _cats.isEmpty ? 0 : _cats.length + 1);
    _cats.addAll(list);
    if (list.length < perPage) {
      return;
    }
    await getAllRootCategories();
  }

  Future<void> getAllLocalCategories() async {
    var tmp = _sharedPreferences.getString('vendorCategories');
    if (tmp != null) {
      var s = json.decode(tmp);

      s.forEach((key, catMap) {
        map[key] = {};
        catMap.forEach((catKeyName, value) {
          map[key]![catKeyName] = value;
        });
      });
    }
    getAllCategories();
  }

  void getAllCategories() {
    _services
        .getVendorAdminCategoriesByPage(page: _page, perPage: perPage)
        .then((list) {
      _page++;
      if (list.isNotEmpty) {
        categories.addAll(list);
        getAllCategories();
        getCategories('0', '');
      }
    });
  }

  void getCategories(String categoryId, String name) {
    if (map[categoryId] == null) {
      map[categoryId] = {};
      map[categoryId]!['name'] = '';
      map[categoryId]!['categories'] = [];
    }
    var tmpListCat = [];
    for (var cat in categories) {
      if (cat.parent == categoryId) {
        tmpListCat.add(cat);
      }
    }
    map[categoryId]!['name'] = name;
    map[categoryId]!['categories'] = tmpListCat;
    var s = json.encode(map);
    _sharedPreferences.setString('vendorCategories', s);
    if (tmpListCat.isNotEmpty) {
      for (var category in tmpListCat) {
        getCategories(category.id, category.name ?? '');
      }
    }
  }

  Future<List<Category>> getSubCategories(String parentId, int offset) async {
    try {
      if (_state == FSLoadState.loading) {
        return [];
      }
      _updateState(FSLoadState.loading);
      final list = await _services.getVendorAdminCategoriesByPage(
          offset: offset, parent: parentId, perPage: perPage);
      if (list.isNotEmpty) {
        _cats.addAll(list);
        _updateState(FSLoadState.loaded);
      } else {
        _updateState(FSLoadState.noData);
      }

      return list;
    } catch (_) {
      _updateState(FSLoadState.noData);
    }
    return [];
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
