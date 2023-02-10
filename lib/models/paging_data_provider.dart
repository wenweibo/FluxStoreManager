import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../common/constants.dart';
import '../services/paging/base_page_repository.dart';

abstract class PagingDataProvider<T> extends ChangeNotifier {
  UnmodifiableListView<T> get data => UnmodifiableListView(_data ?? <T>[]);

  bool get isLoading => _isLoading;

  bool get isFirstLoad => _data == null;

  bool get isLoadMore => _isLoading && (_data?.isNotEmpty ?? false);

  bool get hasNext => _dataRepo.hasNext;

  final BasePageRepository _dataRepo;

  late StreamSubscription _subscriptionChangeLanguage;

  PagingDataProvider({required BasePageRepository dataRepo})
      : _dataRepo = dataRepo {
    _subscriptionChangeLanguage =
        eventBus.on<EventChangeLanguage>().listen((event) {
      refresh();
    });
  }

  List<T>? _data;

  bool _isLoading = false;
  bool _isDisposed = false;

  Future<void> getData() async {
    try {
      if (_isLoading) return;
      if (!hasNext) {
        _isLoading = true;
        _updateState();
        await Future.delayed(const Duration(milliseconds: 500), () {
          _isLoading = false;
        });
        _updateState();
        return;
      }
      _isLoading = true;
      _updateState();

      final apiData = await _dataRepo.getData();
      _data = [..._data ?? [], ...apiData as Iterable<T>? ?? []];
      await Future.delayed(const Duration(milliseconds: 300), () {
        _isLoading = false;
      });
      _updateState();
    } catch (e) {
      _isLoading = false;
    }
  }

  Future<void> refresh({bool autoGetData = true}) async {
    _dataRepo.refresh();
    _data = null;
    _updateState();
    await _dataRepo.cancelCompleter();
    if (autoGetData) {
      Future.delayed(const Duration(milliseconds: 300), getData);
    }
  }

  void _updateState() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscriptionChangeLanguage.cancel();
    super.dispose();
  }
}
