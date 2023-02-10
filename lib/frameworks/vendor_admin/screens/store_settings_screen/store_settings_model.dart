import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../common/constants.dart';
import '../../../../common/tools.dart' show ImagePicker, ImageTools;
import '../../../../models/entities/prediction.dart';
import '../../../../services/dependency_injection.dart';
import '../../entities/store_settings.dart';
import '../../services/vendor_admin.dart';

enum StoreSettingState { loading, loaded, searching }

class StoreSettingModel extends ChangeNotifier {
  final nameController = TextEditingController();
  final slugController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final descriptionController = TextEditingController();

  final streetController = TextEditingController();
  final street2Controller = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();

  final locationController = TextEditingController();
  final bannerVideoController = TextEditingController();
  final listBannerVideoController = TextEditingController();

  final searchAddressController = TextEditingController();

  final _service = injector<VendorAdminService>();

  late GoogleMapController mapController;
  Set<Marker> markers = {};
  double? lat;
  double? long;
  var currentZoom = 13.0;
  var uuid;
  StoreSettings? storeSettings;
  StoreSettingState _state = StoreSettingState.loading;
  StoreSettingState get state => _state;
  List<Prediction> autocompletePlaces = [];
  final String? _userCookie;
  bool isUpdating = false;

  StoreSettingModel(this._userCookie) {
    uuid = const Uuid().v4();
    getStoreSettings();
  }

  final visibilityData = {
    'hideEmail': false,
    'hidePhone': false,
    'hideAddress': false,
    'hideMap': false,
    'hideAbout': false,
    'hidePolicy': false,
  };

  dynamic _storeLogo;
  dynamic get storeLogo => _storeLogo;

  final Map<String, dynamic> banner = {
    'bannerType': '', // static || slider || video
    'banner': '', // String || Asset
    'slider': [], // List String || List Asset || List String + Asset
    'video': '', // Youtube URL
    'mobileBanner': '', // String || Asset
    'storeListBannerType': '', // static || video
    'storeListBanner': '', // String || Asset
    'storeListVideo': '' // Youtube URL
  };

  void _updateState(state) {
    _state = state;
    notifyListeners();
  }

  void updateVisibility(String key, bool? value) {
    visibilityData[key] = value!;
    notifyListeners();
  }

  void setIsUpdating() {
    isUpdating = !isUpdating;
    _updateState(StoreSettingState.loaded);
  }

  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  void onCameraMove(CameraPosition pos) {
    currentZoom = pos.zoom;
  }

  void updatePosition(LatLng pos, {bool isTapOnMap = false}) async {
    lat = pos.latitude;
    long = pos.longitude;
    markers.clear();
    markers.add(
      Marker(markerId: MarkerId('$lat-$long'), position: LatLng(lat!, long!)),
    );
    _updateState(StoreSettingState.loaded);
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat!, long!),
          zoom: currentZoom,
        ),
      ),
    );
    if (isTapOnMap) {
      locationController.text =
          await (_service.getAddressFromLocation(lat, long));
    }
  }

  void getPlaces() {
    EasyDebounce.cancel('getAutocompletePlaces');
    if (searchAddressController.text.trim().isNotEmpty) {
      _updateState(StoreSettingState.searching);
      EasyDebounce.debounce(
          'getAutocompletePlaces', const Duration(milliseconds: 300), () async {
        autocompletePlaces = await _service.getAutoCompletePlaces(
            searchAddressController.text, uuid);
        _updateState(StoreSettingState.loaded);
      });
    } else {
      autocompletePlaces.clear();
      _updateState(StoreSettingState.loaded);
    }
  }

  Future<void> getLocationFromPlace(int index) async {
    if (autocompletePlaces.isNotEmpty) {
      locationController.text = autocompletePlaces[index].description!;
      searchAddressController.clear();
      final prediction =
          await _service.getPlaceDetail(autocompletePlaces[index], uuid);

      uuid = const Uuid().v4();

      updatePosition(LatLng(
          double.parse(prediction.lat!), double.parse(prediction.long!)));

      autocompletePlaces.clear();
    }
  }

  void _dataMockUp() {
    _storeLogo = storeSettings?.logo ?? '';
    banner['banner'] = storeSettings?.banner ?? '';
    banner['bannerType'] = storeSettings?.bannerType ?? '';

    banner['mobileBanner'] = storeSettings?.mobileBanner ?? '';
    banner['storeListBanner'] = storeSettings?.listBanner ?? '';
    banner['storeListBannerType'] = storeSettings?.listBannerType ?? '';

    var sliders = storeSettings?.bannerSlider ?? [];
    for (var element in sliders) {
      if (element['image'] != null) {
        banner['slider'].add({
          'image': element['image'],
          'link': TextEditingController()..text = element['link']
        });
      }
    }

    /// Setup visibility
    visibilityData['hideEmail'] = storeSettings!.storeHideEmail!;
    visibilityData['hidePhone'] = storeSettings!.storeHidePhone!;
    visibilityData['hideAddress'] = storeSettings!.storeHideAddress!;
    visibilityData['hideMap'] = storeSettings!.storeHideMap!;
    visibilityData['hideAbout'] = storeSettings!.storeHideDescription!;
    visibilityData['hidePolicy'] = storeSettings!.storeHidePolicy!;

    /// Setup general setting
    nameController.text = storeSettings!.storeName!;
    slugController.text = storeSettings!.storeSlug!;
    emailController.text = storeSettings!.storeEmail!;
    phoneController.text = storeSettings!.phone!;
    descriptionController.text = storeSettings!.storeDescription!;

    bannerVideoController.text = storeSettings!.bannerVideo ?? '';
    listBannerVideoController.text = storeSettings!.listBannerVideo ?? '';

    /// Setup address
    streetController.text = storeSettings!.street1!;
    street2Controller.text = storeSettings!.street2!;
    cityController.text = storeSettings!.city!;
    zipController.text = storeSettings!.zip!;
    countryController.text = storeSettings!.country!;
    stateController.text = storeSettings!.state!;

    ///Store geo-location
    locationController.text = storeSettings!.storeLocation!;
    if (storeSettings!.storeLat != null &&
        storeSettings!.storeLat!.isNotEmpty &&
        storeSettings!.storeLng != null &&
        storeSettings!.storeLng!.isNotEmpty) {
      lat = double.parse(storeSettings!.storeLat!);
      long = double.parse(storeSettings!.storeLng!);
      markers.add(
        Marker(markerId: MarkerId('$lat-$long'), position: LatLng(lat!, long!)),
      );
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat!, long!),
            zoom: currentZoom,
          ),
        ),
      );
    }
  }

  Future<void> getStoreSettings() async {
    storeSettings = await _service.getVendorStoreSetting(_userCookie);
    if (storeSettings != null) {
      try {
        _dataMockUp();
      } catch (e) {
        printLog(e);
      }
    }
    _updateState(StoreSettingState.loaded);
  }

  Future<Map<dynamic, dynamic>> prepareData() async {
    var data = {};
    data['store_name'] = nameController.text;
    data['store_slug'] = slugController.text;
    data['store_email'] = emailController.text;
    data['phone'] = phoneController.text;
    if (ImagePicker.isAsset(_storeLogo)) {
      data['logo'] = await ImageTools.compressImage(_storeLogo);
    }
    if (ImagePicker.isAsset(banner['mobileBanner'])) {
      data['mobile_banner'] =
          await ImageTools.compressImage(banner['mobileBanner']);
    }
    data['banner_type'] = banner['bannerType'];
    data['list_banner_type'] = banner['storeListBannerType'];

    if (ImagePicker.isAsset(banner['banner']) &&
        banner['bannerType'] == 'static') {
      data['banner'] = await ImageTools.compressImage(banner['banner']);
      data['banner_type'] = 'single_img';
    }
    if (banner['bannerType'] == 'video') {
      data['banner_video'] = bannerVideoController.text;
    }
    if (banner['bannerType'] == 'slider') {
      data['banner_slider'] = [];
      for (var item in banner['slider']) {
        var bannerSlider = {};
        if (ImagePicker.isAsset(item['image'])) {
          bannerSlider['type'] = 'asset';
          bannerSlider['image'] = await ImageTools.compressImage(item['image']);
        } else {
          bannerSlider['type'] = 'url';
          bannerSlider['image'] = item['image'];
        }
        bannerSlider['link'] = item['link'].text;
        data['banner_slider'].add(bannerSlider);
      }
    }
    if (banner['storeListBannerType'] == 'video') {
      data['list_banner_video'] = listBannerVideoController.text;
    }
    if (ImagePicker.isAsset(banner['storeListBanner']) &&
        banner['storeListBannerType'] == 'static') {
      data['list_banner'] =
          await ImageTools.compressImage(banner['storeListBanner']);
      data['list_banner_type'] = 'single_img';
    }

    data['shop_description'] = descriptionController.text;

    data['address'] = {};
    data['address']['street_1'] = streetController.text;
    data['address']['street_2'] = street2Controller.text;
    data['address']['city'] = cityController.text;
    data['address']['zip'] = zipController.text;
    data['address']['country'] = countryController.text;
    data['address']['state'] = stateController.text;

    data['store_location'] = locationController.text;
    data['store_lat'] = lat.toString();
    data['store_lng'] = long.toString();

    data['store_hide_email'] = visibilityData['hideEmail']! ? 'yes' : 'no';
    data['store_hide_phone'] = visibilityData['hidePhone']! ? 'yes' : 'no';
    data['store_hide_address'] = visibilityData['hideAddress']! ? 'yes' : 'no';
    data['store_hide_map'] = visibilityData['hideMap']! ? 'yes' : 'no';
    data['store_hide_description'] =
        visibilityData['hideAbout']! ? 'yes' : 'no';
    data['store_hide_policy'] = visibilityData['hidePolicy']! ? 'yes' : 'no';

    return data;
  }

  Future<void> updateStoreSettings(Function showMessage) async {
    _updateState(StoreSettingState.loading);
    final data = await prepareData();
    final error = await _service.updateVendorStoreSetting(_userCookie, data);
    showMessage(error);
    _updateState(StoreSettingState.loaded);
  }

  Future<void> takeGalleryImages(context) async {
    try {
      var count = 10 - banner['slider'].length;
      final list = await ImagePicker.select(
        context,
        maxFiles: count as int,
      );
      if (list.isNotEmpty) {
        for (var element in list) {
          banner['slider']
              .add({'image': element, 'link': TextEditingController()});
        }
        _updateState(StoreSettingState.loaded);
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> takeBannerImage(context) async {
    try {
      final list = await ImagePicker.select(
        context,
        maxFiles: 1,
      );
      if (list.isNotEmpty) {
        banner['banner'] = list.first;
        _updateState(StoreSettingState.loaded);
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> takeMobileBannerImage(context) async {
    try {
      final list = await ImagePicker.select(context);
      if (list.isNotEmpty) {
        banner['mobileBanner'] = list.first;
        _updateState(StoreSettingState.loaded);
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> takeListBannerImage(context) async {
    try {
      final list = await ImagePicker.select(context);
      if (list.isNotEmpty) {
        banner['storeListBanner'] = list.first;
        _updateState(StoreSettingState.loaded);
      }
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> takeLogoImage(context) async {
    try {
      final list = await ImagePicker.select(context);
      if (list.isNotEmpty) {
        _storeLogo = list.first;
        _updateState(StoreSettingState.loaded);
      }
    } catch (e) {
      printLog(e);
    }
  }

  void removeGalleryImage(int index) {
    banner['slider'].removeAt(index);
    _updateState(StoreSettingState.loaded);
  }

  void updateType(bannerType, value) {
    if (banner[bannerType] != value) {
      banner[bannerType] = value;
      _updateState(StoreSettingState.loaded);
    }
  }
}
