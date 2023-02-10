import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/error_codes/error_codes.dart';
import '../../models/export.dart';
import 'login_widget.dart';
import 'registration_widget.dart';

class VendorAdminLoginScreen extends StatefulWidget {
  @override
  State<VendorAdminLoginScreen> createState() => _VendorAdminLoginScreenState();
}

class _VendorAdminLoginScreenState extends State<VendorAdminLoginScreen> {
  final _pageController = PageController();

  void _goToPage(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void _showMessage(ErrorType type) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(type.getMessage(context)),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<VendorAdminAuthenticationModel>(
      builder: (context, model, _) => Scaffold(
        body: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                LoginWidget(
                    callBack: () => _goToPage(1), onMessage: _showMessage),
                RegistrationWidget(
                    callBack: () => _goToPage(0), onMessage: _showMessage),
              ],
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
