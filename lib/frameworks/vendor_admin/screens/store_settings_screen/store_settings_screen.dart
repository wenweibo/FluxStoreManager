import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../common/error_codes/error_codes.dart';
import '../../../../generated/l10n.dart';
import '../../../../widgets/common/edit_product_info_widget.dart';
import '../../models/authentication_model.dart';
import 'store_settings_model.dart';
import 'widgets/store_banner.dart';
import 'widgets/store_banner_slider.dart';
import 'widgets/store_logo.dart';
import 'widgets/store_setting_map.dart';
import 'widgets/store_type_dropdown.dart';

class StoreSettingScreen extends StatefulWidget {
  @override
  State<StoreSettingScreen> createState() => _StoreSettingScreenState();
}

class _StoreSettingScreenState extends State<StoreSettingScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userCookie =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user!
            .cookie;
    final theme = Theme.of(context);
    return ChangeNotifierProvider<StoreSettingModel>(
      create: (_) => StoreSettingModel(userCookie),
      lazy: false,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              iconTheme: Theme.of(context).iconTheme,
              title: Text(
                S.of(context).storeSettings,
                style: Theme.of(context).primaryTextTheme.headline5,
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).backgroundColor,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              actions: [
                Consumer<StoreSettingModel>(
                    builder: (_, model, __) => Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                              right: 10.0,
                            ),
                            child: InkWell(
                              onTap: model.setIsUpdating,
                              child: model.isUpdating
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.red,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: Text(
                                        S.of(context).cancel,
                                        style:
                                            theme.textTheme.caption!.copyWith(
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: Text(
                                        S.of(context).editWithoutColon,
                                        style:
                                            theme.textTheme.caption!.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ))
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Consumer<StoreSettingModel>(
              builder: (_, model, __) => model.isUpdating
                  ? ElevatedButton(
                      onPressed: () {
                        void showMessage(ErrorType type) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(type.getMessage(context)),
                            duration: const Duration(seconds: 1),
                          ));
                          if (type == ErrorType.updateSuccess) {
                            Future.delayed(const Duration(seconds: 1))
                                .then((value) => Navigator.pop(context));
                          }
                        }

                        model.updateStoreSettings(showMessage);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: Text(S.of(context).apply),
                    )
                  : Container(),
            ),
            body: Consumer<StoreSettingModel>(
              builder: (_, model, __) => SizedBox(
                width: size.width,
                height: size.height,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      EditProductInfoWidget(
                        controller: model.nameController,
                        label: S.of(context).shopName,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.slugController,
                        label: S.of(context).shopSlug,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.emailController,
                        label: S.of(context).shopEmail,
                        keyboardType: TextInputType.emailAddress,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.phoneController,
                        label: S.of(context).shopPhone,
                        keyboardType: TextInputType.phone,
                        enable: model.isUpdating,
                      ),
                      StoreLogo(
                        onCallback: model.isUpdating
                            ? () => model.takeLogoImage(context)
                            : null,
                        storeLogo: model.storeLogo,
                      ),
                      StoreTypeDropdown(
                        title: S.of(context).bannerType,
                        currentType: model.banner['bannerType'],
                        types: const ['static', 'slider', 'video'],
                        onCallBack: (val) =>
                            model.updateType('bannerType', val),
                        enable: model.isUpdating,
                      ),
                      if (model.banner['slider'] != null) ...[
                        if (model.banner['bannerType'] == 'static')
                          StoreBanner(
                            title: S.of(context).storeStaticBanner,
                            onCallback: model.isUpdating
                                ? () => model.takeBannerImage(context)
                                : null,
                            storeBanner: model.banner['banner'],
                          ),
                        if (model.banner['bannerType'] == 'slider')
                          StoreBannerSlider(
                            title: S.of(context).storeSliderBanner,
                            storeListBanner: model.banner['slider'],
                            onCallback: model.isUpdating
                                ? () => model.takeGalleryImages(context)
                                : null,
                            onRemove: (i) => model.isUpdating
                                ? model.removeGalleryImage(i)
                                : null,
                          ),
                      ],
                      if (model.banner['bannerType'] == 'video')
                        EditProductInfoWidget(
                          controller: model.bannerVideoController,
                          label: S.of(context).bannerYoutubeURL,
                          enable: model.isUpdating,
                        ),
                      StoreBanner(
                        title: S.of(context).storeMobileBanner,
                        onCallback: model.isUpdating
                            ? () => model.takeMobileBannerImage(context)
                            : null,
                        storeBanner: model.banner['mobileBanner'],
                      ),
                      StoreTypeDropdown(
                        title: S.of(context).bannerListType,
                        currentType: model.banner['storeListBannerType'],
                        types: const ['static', 'video'],
                        onCallBack: (val) =>
                            model.updateType('storeListBannerType', val),
                        enable: model.isUpdating,
                      ),
                      if (model.banner['storeListBannerType'] == 'static')
                        StoreBanner(
                          title: S.of(context).storeListBanner,
                          onCallback: model.isUpdating
                              ? () => model.takeListBannerImage(context)
                              : null,
                          storeBanner: model.banner['storeListBanner'],
                        ),
                      if (model.banner['storeListBannerType'] == 'video')
                        EditProductInfoWidget(
                          controller: model.listBannerVideoController,
                          label: S.of(context).listBannerVideo,
                          enable: model.isUpdating,
                        ),
                      EditProductInfoWidget(
                        controller: model.descriptionController,
                        label: S.of(context).description,
                        isMultiline: true,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.streetController,
                        label: S.of(context).street,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.street2Controller,
                        label: S.of(context).street2,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.cityController,
                        label: S.of(context).city,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.zipController,
                        label: S.of(context).zipCode,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.countryController,
                        label: S.of(context).country,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.stateController,
                        label: S.of(context).stateProvince,
                        enable: model.isUpdating,
                      ),
                      EditProductInfoWidget(
                        controller: model.locationController,
                        label: S.of(context).location,
                        enable: model.isUpdating,
                      ),
                      StoreSettingMap(),
                      CheckboxListTile(
                        value: model.visibilityData['hideEmail'],
                        onChanged: !model.isUpdating
                            ? null
                            : (val) => model.updateVisibility('hideEmail', val),
                        title: Text(S.of(context).hideEmail),
                      ),
                      CheckboxListTile(
                        value: model.visibilityData['hidePhone'],
                        onChanged: !model.isUpdating
                            ? null
                            : (val) => model.updateVisibility('hidePhone', val),
                        title: Text(S.of(context).hidePhone),
                      ),
                      CheckboxListTile(
                        value: model.visibilityData['hideAddress'],
                        onChanged: !model.isUpdating
                            ? null
                            : (val) =>
                                model.updateVisibility('hideAddress', val),
                        title: Text(S.of(context).hideAddress),
                      ),
                      CheckboxListTile(
                        value: model.visibilityData['hideMap'],
                        onChanged: !model.isUpdating
                            ? null
                            : (val) => model.updateVisibility('hideMap', val),
                        title: Text(S.of(context).hideMap),
                      ),
                      CheckboxListTile(
                        value: model.visibilityData['hideAbout'],
                        onChanged: !model.isUpdating
                            ? null
                            : (val) => model.updateVisibility('hideAbout', val),
                        title: Text(S.of(context).hideAbout),
                      ),
                      CheckboxListTile(
                        value: model.visibilityData['hidePolicy'],
                        onChanged: !model.isUpdating
                            ? null
                            : (val) =>
                                model.updateVisibility('hidePolicy', val),
                        title: Text(S.of(context).hidePolicy),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Consumer<StoreSettingModel>(
            builder: (_, model, __) => model.state == StoreSettingState.loading
                ? Container(
                    width: size.width,
                    height: size.height,
                    color: Colors.black26,
                    child: Center(
                      child: kLoadingWidget(context),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
