import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../../widgets/common/flux_image.dart';
import '../../widgets/common/login_animation.dart';
import 'login_sms_viewmodel.dart';
import 'verify.dart';

class LoginSMSScreen extends StatefulWidget {
  const LoginSMSScreen();

  @override
  LoginSMSScreenState createState() => LoginSMSScreenState();
}

class LoginSMSScreenState<T extends LoginSMSScreen> extends State<T>
    with TickerProviderStateMixin {
  late AnimationController _loginButtonController;
  final TextEditingController _controller = TextEditingController(text: '');

  LoginSmsViewModel get viewModel => context.read<LoginSmsViewModel>();

  void loginSMS(context) {
    if (viewModel.phoneNumber.isEmpty) {
      Tools.showSnackBar(
          ScaffoldMessenger.of(context), S.of(context).pleaseInput);
    } else {
      Future autoRetrieve(String verId) {
        return stopAnimation();
      }

      Future smsCodeSent(String verId, [int? forceCodeResend]) {
        stopAnimation();
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCode(
              verId: verId,
              phoneNumber: viewModel.phoneFullText,
              verifySuccessStream: viewModel.getStreamSuccess,
              resendToken: forceCodeResend,
            ),
          ),
        );
      }

      void verifyFailed(exception) {
        stopAnimation();
        failMessage(exception.toString(), context);
      }

      viewModel.verify(
        autoRetrieve: autoRetrieve,
        smsCodeSent: smsCodeSent,
        verifyFailed: verifyFailed,
        startVerify: playAnimation,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.updateCountryCode(
        code: LoginSMSConstants.countryCodeDefault,
        dialCode: LoginSMSConstants.dialCodeDefault,
        name: LoginSMSConstants.nameDefault,
      );
    });

    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (_controller.text != '') {
      viewModel.updatePhone(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _loginButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: false);
    final themeConfig = appModel.themeConfig;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Consumer<LoginSmsViewModel>(
          builder: (context, viewmodel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 80.0),
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 40.0,
                            child: FluxImage(imageUrl: themeConfig.logo),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 120.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 17.0),
                        child: CountryCodePicker(
                          onChanged: (CountryCode? countryCode) =>
                              viewModel.updateCountryCode(
                            code: countryCode?.code,
                            dialCode: countryCode?.dialCode,
                            name: countryCode?.name,
                          ),
                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                          initialSelection: viewModel.countryCode,
                          onInit: (countryCode) => viewModel.loadConfig(
                            code: countryCode?.code,
                            dialCode: countryCode?.dialCode,
                            name: countryCode?.name,
                          ),
                          //Get the country information relevant to the initial selection
                          backgroundColor: Theme.of(context).backgroundColor,
                          dialogBackgroundColor:
                              Theme.of(context).dialogBackgroundColor,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          decoration:
                              InputDecoration(labelText: S.of(context).phone),
                          keyboardType: TextInputType.phone,
                          controller: _controller,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 60),
                  StaggerAnimation(
                    titleButton: S.of(context).sendSMSCode,
                    buttonController:
                        _loginButtonController.view as AnimationController,
                    onTap: () => loginSMS(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> playAnimation() async {
    try {
      viewModel.enableLoading();
      await _loginButtonController.forward();
      return true;
    } on TickerCanceled {
      printLog('[_playAnimation] error');
      return false;
    }
  }

  Future stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      viewModel.enableLoading(false);
    } on TickerCanceled {
      printLog('[_stopAnimation] error');
    }
  }

  void failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text('⚠️: $message'),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
