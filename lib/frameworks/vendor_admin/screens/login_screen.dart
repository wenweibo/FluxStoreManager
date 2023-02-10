import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/error_codes/error_codes.dart';
import '../../../generated/l10n.dart';
import '../../../widgets/common/edit_product_info_widget.dart';
import '../config/app_config.dart';
import '../models/authentication_model.dart';

class VendorAdminLoginScreen extends StatelessWidget {
  List<Widget> _buildLoginButtons(VendorAdminAuthenticationModel model,
      Function(ErrorType type) showMessage) {
    return [
      if (kLoginSetting.showAppleLogin && isIos) ...[
        InkWell(
          onTap: () => model.appleLogin(showMessage),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.black87,
            ),
            child: Image.asset(
              'assets/icons/logins/apple.png',
              width: 26,
              height: 26,
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
      if (kLoginSetting.showGoogleLogin) ...[
        InkWell(
          onTap: () => model.googleLogin(showMessage),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.grey.shade300,
            ),
            child: Image.asset(
              'assets/icons/logins/google.png',
              width: 28,
              height: 28,
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
      if (kLoginSetting.showFacebook) ...[
        InkWell(
          onTap: () => model.facebookLogin(showMessage),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: const Color(0xFF4267B2),
            ),
            child: const Icon(
              Icons.facebook_rounded,
              color: Colors.white,
              size: 34.0,
            ),
          ),
        ),
      ]
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    void utf8decode(ErrorType type) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(type.getMessage(context)),
        duration: const Duration(seconds: 1),
      ));
    }

    return Consumer<VendorAdminAuthenticationModel>(
      builder: (context, model, _) => Scaffold(
        body: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              color: Theme.of(context).backgroundColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Image.asset(
                      kAppLogo,
                      fit: BoxFit.fill,
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      kAppName,
                      style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),
                    EditProductInfoWidget(
                      key: const Key('vendorAdminLoginUsername'),
                      label: S.of(context).username,
                      fontSize: 12.0,
                      controller: model.usernameController,
                    ),
                    const SizedBox(height: 25),
                    EditProductInfoWidget(
                      key: const Key('vendorAdminLoginPassword'),
                      label: S.of(context).password,
                      fontSize: 12.0,
                      controller: model.passwordController,
                      isObscure: true,
                    ),
                    const SizedBox(height: 50.0),
                    InkWell(
                      onTap: () => model.login(utf8decode),
                      key: const Key('vendorAdminLoginButton'),
                      child: Container(
                        height: 44,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.blueAccent,
                        ),
                        child: model.state ==
                                VendorAdminAuthenticationModelState.loading
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  S.of(context).login.toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                    if (isIos || isAndroid) ...[
                      const SizedBox(height: 20),
                      Text(S.of(context).orLoginWith),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildLoginButtons(model, utf8decode),
                      ),
                    ],
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            if (model.state == VendorAdminAuthenticationModelState.loading)
              Container(
                width: size.width,
                height: size.height,
                color: Colors.black87.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }
}
