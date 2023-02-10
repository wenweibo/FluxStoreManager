import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../common/error_codes/error_codes.dart';
import '../../../../common/extensions/extensions.dart';
import '../../../../common/tools/tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/app_model.dart';
import '../../../../screens/home/privacy_term_screen.dart';
import '../../../../widgets/common/index.dart' show CustomTextField, FluxImage;
import '../../models/authentication_model.dart';

class RegistrationWidget extends StatefulWidget {
  final Function callBack;
  final Function(ErrorType type) onMessage;

  const RegistrationWidget(
      {Key? key, required this.callBack, required this.onMessage})
      : super(key: key);

  @override
  State<RegistrationWidget> createState() => _RegistrationWidgetState();
}

class _RegistrationWidgetState extends State<RegistrationWidget> {
  final TextEditingController _emailController = TextEditingController();
  String firstName = '',
      lastName = '',
      emailAddress = '',
      phoneNumber = '',
      password = '';
  bool isChecked = false;

  final bool showPhoneNumberWhenRegister =
      kLoginSetting.showPhoneNumberWhenRegister;
  final bool requirePhoneNumberWhenRegister =
      kLoginSetting.requirePhoneNumberWhenRegister;

  final firstNameNode = FocusNode();
  final lastNameNode = FocusNode();
  final phoneNumberNode = FocusNode();
  final emailNode = FocusNode();
  final passwordNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    firstNameNode.dispose();
    lastNameNode.dispose();
    emailNode.dispose();
    passwordNode.dispose();
    phoneNumberNode.dispose();
    super.dispose();
  }

  void _snackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 1),
    ));
  }

  Future<void> _submitRegister() async {
    if (firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        emailAddress.trim().isEmpty ||
        password.trim().isEmpty) {
      _snackBar(S.of(context).pleaseInputFillAllFields);
      return;
    }

    if (isChecked == false) {
      _snackBar(S.of(context).pleaseAgreeTerms);
      return;
    }

    if (!_emailController.text.trim().isEmail) {
      _snackBar(S.of(context).errorEmailFormat);
      return;
    }

    if (password.length < 8) {
      _snackBar(S.of(context).errorPasswordFormat);
      return;
    }

    await Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
        .register(
      widget.onMessage,
      username: emailAddress,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context, listen: true);
    final themeConfig = appModel.themeConfig;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Tools.hideKeyboard(context),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: AutofillGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 10.0),
                    Center(
                      child: FluxImage(
                        imageUrl: themeConfig.logo,
                        width: MediaQuery.of(context).size.width / 2,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    CustomTextField(
                      key: const Key('registerFirstNameField'),
                      autofillHints: const [AutofillHints.givenName],
                      onChanged: (value) => firstName = value,
                      textCapitalization: TextCapitalization.words,
                      nextNode: lastNameNode,
                      showCancelIcon: true,
                      decoration: InputDecoration(
                        labelText: S.of(context).firstName,
                        hintText: S.of(context).enterYourFirstName,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    CustomTextField(
                      key: const Key('registerLastNameField'),
                      autofillHints: const [AutofillHints.familyName],
                      focusNode: lastNameNode,
                      nextNode: showPhoneNumberWhenRegister
                          ? phoneNumberNode
                          : emailNode,
                      showCancelIcon: true,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) => lastName = value,
                      decoration: InputDecoration(
                        labelText: S.of(context).lastName,
                        hintText: S.of(context).enterYourLastName,
                      ),
                    ),
                    if (showPhoneNumberWhenRegister)
                      const SizedBox(height: 20.0),
                    if (showPhoneNumberWhenRegister)
                      CustomTextField(
                        key: const Key('registerPhoneField'),
                        focusNode: phoneNumberNode,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        nextNode: emailNode,
                        showCancelIcon: true,
                        onChanged: (value) => phoneNumber = value,
                        decoration: InputDecoration(
                          labelText: S.of(context).phone,
                          hintText: S.of(context).enterYourPhoneNumber,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    const SizedBox(height: 20.0),
                    CustomTextField(
                      key: const Key('registerEmailField'),
                      focusNode: emailNode,
                      autofillHints: const [AutofillHints.email],
                      nextNode: passwordNode,
                      controller: _emailController,
                      onChanged: (value) => emailAddress = value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: S.of(context).enterYourEmail),
                      hintText: S.of(context).enterYourEmail,
                    ),
                    const SizedBox(height: 20.0),
                    CustomTextField(
                      key: const Key('registerPasswordField'),
                      focusNode: passwordNode,
                      autofillHints: const [AutofillHints.password],
                      showEyeIcon: true,
                      obscureText: true,
                      onChanged: (value) => password = value,
                      decoration: InputDecoration(
                        labelText: S.of(context).enterYourPassword,
                        hintText: S.of(context).enterYourPassword,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    InkWell(
                      onTap: () {
                        isChecked = !isChecked;
                        setState(() {});
                      },
                      child: Row(
                        children: <Widget>[
                          Checkbox(
                            value: isChecked,
                            activeColor: Theme.of(context).primaryColor,
                            checkColor: Colors.white,
                            onChanged: (value) {
                              isChecked = !isChecked;
                              setState(() {});
                            },
                          ),
                          Expanded(
                            child: RichText(
                              maxLines: 2,
                              text: TextSpan(
                                text: S.of(context).iAgree,
                                style: Theme.of(context).textTheme.bodyText1,
                                children: <TextSpan>[
                                  const TextSpan(text: ' '),
                                  TextSpan(
                                    text: S.of(context).agreeWithPrivacy,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PrivacyTermScreen(),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Material(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        elevation: 0,
                        child: MaterialButton(
                          key: const Key('registerSubmitButton'),
                          onPressed: _submitRegister,
                          minWidth: 200.0,
                          elevation: 0.0,
                          height: 42.0,
                          child: Consumer<VendorAdminAuthenticationModel>(
                            builder: (_, model, __) => model.state ==
                                    VendorAdminAuthenticationModelState.loading
                                ? const Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  )
                                : Text(
                                    S.of(context).createAnAccount,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${S.of(context).or.toLowerCase()} ',
                          ),
                          InkWell(
                            onTap: () {
                              widget.callBack();
                            },
                            child: Text(
                              S.of(context).loginToYourAccount,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                decoration: TextDecoration.underline,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
