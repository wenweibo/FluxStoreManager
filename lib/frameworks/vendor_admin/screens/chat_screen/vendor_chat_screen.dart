import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/services.dart';
import '../../models/authentication_model.dart';

class VendorChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user;
    return Services().firebase.renderVendorListChatScreen(user: user);
  }
}
