import 'package:html_unescape/html_unescape.dart';

class StoreSettings {
  String? storeName;
  String? storeSlug;
  String? storeEmail;
  String? phone;
  String? logo;
  String? bannerType;
  String? banner;
  String? bannerVideo;
  List<Map<dynamic, dynamic>> bannerSlider = [];
  String? mobileBanner;
  String? listBannerType;
  String? listBanner;
  String? listBannerVideo;
  String? storeDescription;
  String? street1;
  String? street2;
  String? city;
  String? zip;
  String? country;
  String? state;
  bool? storeHideEmail;
  bool? storeHidePhone;
  bool? storeHideAddress;
  bool? storeHideMap;
  bool? storeHideDescription;
  bool? storeHidePolicy;
  String? storeLocation;
  String? storeLat;
  String? storeLng;

  StoreSettings.fromJson(json) {
    storeName = json['store_name'];
    storeSlug = json['store_slug'];
    storeEmail = json['store_email'];
    phone = json['phone'];
    logo = json['logo'];
    bannerType = json['banner_type'];
    if (bannerType == 'single_img') {
      bannerType = 'static';
    }
    banner = json['banner'];
    bannerVideo = json['banner_video'];
    if (json['banner_slider'] != null && json['banner_slider'].isNotEmpty) {
      json['banner_slider'].forEach((element) => bannerSlider.add(element));
    }
    mobileBanner = json['mobile_banner'];
    listBannerType = json['list_banner_type'];
    if (listBannerType == 'single_img') {
      listBannerType = 'static';
    }
    listBannerVideo = json['list_banner_video'];
    listBanner = json['list_banner'];
    storeDescription = HtmlUnescape().convert(json['shop_description'] ?? '');
    street1 = json['address']?['street_1'];
    street2 = json['address']?['street_2'];
    city = json['address']?['city'];
    zip = json['address']?['zip'];
    country = json['address']?['country'];
    state = json['address']?['state'];
    storeHideEmail = json['store_hide_email'] != 'no';
    storeHidePhone = json['store_hide_phone'] != 'no';
    storeHideAddress = json['store_hide_address'] != 'no';
    storeHideMap = json['store_hide_map'] != 'no';
    storeHideDescription = json['store_hide_description'] != 'no';
    storeHidePolicy = json['store_hide_policy'] != 'no';
    storeLocation = json['store_location'];
    storeLat = json['store_lat'];
    storeLng = json['store_lng'];
  }
}
