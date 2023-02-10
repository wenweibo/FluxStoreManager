import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/app_model.dart';
import '../../../../modules/store_open_option/store_open_option.dart';
import '../../../../screens/common/delete_account_mixin.dart';
import '../../../../screens/settings/language_screen.dart';
import '../../../../screens/users/delete_account_screen.dart';
import '../../../../services/service_config.dart';
import '../../../../widgets/common/common_setting_item.dart';
import '../../models/authentication_model.dart';
import '../store_settings_screen/store_settings_screen.dart';

class VendorAdminSettingScreen extends StatelessWidget with DeleteAccountMixin {
  final isFromMV;

  const VendorAdminSettingScreen({Key? key, this.isFromMV = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authModel =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).settings,
          style: Theme.of(context).primaryTextTheme.headline5,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: Selector<AppModel, bool>(
          selector: (_, model) => model.darkTheme,
          builder: (context, darkTheme, _) => SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      NetworkImage(authModel.user!.picture ?? kDefaultImage),
                ),
                const SizedBox(height: 20),
                Text(
                  '${authModel.user!.firstName} ${authModel.user!.lastName}',
                  style: Theme.of(context).primaryTextTheme.headline6,
                ),
                const SizedBox(height: 30),

                /// It will support other platforms in future commits.
                /// For now, only support WCFM.
                if (authModel.state ==
                        VendorAdminAuthenticationModelState.loggedIn &&
                    ServerConfig().platform.isWcfm) ...[
                  CommonSettingItem(
                    leadingIcon: CupertinoIcons.person_crop_rectangle,
                    title: S.of(context).visitStore,
                    actionIcon: Icons.arrow_forward_ios_outlined,
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => StoreSettingScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CommonSettingItem(
                    leadingIcon: CupertinoIcons.house,
                    title: S.of(context).storeVacation,
                    actionIcon: Icons.arrow_forward_ios_outlined,
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => StoreOpenOptionIndex(
                              userId: authModel.user!.id!,
                              cookie: authModel.user!.cookie!)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                if (!isFromMV) ...[
                  CommonSettingItem(
                    leadingIcon: CupertinoIcons.globe,
                    title: S.of(context).language,
                    actionIcon: Icons.arrow_forward_ios_outlined,
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => LanguageScreen()),
                    ),
                  ),
                  CommonSettingItem(
                    leadingIcon: darkTheme
                        ? CupertinoIcons.moon_stars
                        : CupertinoIcons.sun_min,
                    title: S.of(context).darkTheme,
                    isSwitchedOn: darkTheme,
                    onTap: () => Provider.of<AppModel>(context, listen: false)
                        .updateTheme(!darkTheme),
                  ),
                  CommonSettingItem(
                      leadingIcon: CupertinoIcons.delete,
                      actionIcon: Icons.arrow_forward_ios_outlined,
                      isSensitive: true,
                      title: S.current.deleteAccount,
                      onTap: () async {
                        final acceptDelete =
                            await showConfirmDeleteAccountDialog(context);
                        final userToken = authModel.user?.cookie ?? '';
                        if (acceptDelete) {
                          final result = await Navigator.of(
                            context,
                            rootNavigator: true,
                          ).push(CupertinoPageRoute(
                            builder: (context) {
                              return DeleteAccountScreen(
                                confirmCaptcha:
                                    kAdvanceConfig.gdprConfig.confirmCaptcha,
                                userToken: userToken,
                              );
                            },
                          )) as bool?;
                          if (result ?? false) {
                            await authModel.deleteAccount();
                            await authModel.logout();
                          }
                        }
                      }),
                  CommonSettingItem(
                    leadingIcon: Icons.person,
                    title: S.of(context).logout,
                    onTap: authModel.logout,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
