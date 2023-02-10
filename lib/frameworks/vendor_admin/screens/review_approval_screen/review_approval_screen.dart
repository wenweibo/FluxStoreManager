import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../generated/l10n.dart';
import 'sub_screens/approved_review_screen.dart';
import 'sub_screens/pending_review_screen.dart';

class VendorAdminReviewApprovalScreen extends StatefulWidget {
  @override
  State<VendorAdminReviewApprovalScreen> createState() =>
      _VendorAdminReviewApprovalScreenState();
}

class _VendorAdminReviewApprovalScreenState
    extends State<VendorAdminReviewApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.backgroundColor,
          title: Text(
            S.of(context).reviewApproval,
            style: theme.primaryTextTheme.headline5,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: true,
//          actions: [
//            const Icon(Icons.menu),
//            const SizedBox(width: 20),
//          ],
          bottom: TabBar(
            labelStyle: theme.primaryTextTheme.bodyText1,
            unselectedLabelStyle: theme.primaryTextTheme.bodyText1,
            tabs: [
              Tab(
                text: S.of(context).approved,
              ),
              Tab(
                text: S.of(context).pending,
              ),
            ],
          ),
        ),
        body: Container(
          width: size.width,
          height: size.height,
          color: theme.backgroundColor,
          child: TabBarView(
            children: [
              ApprovedReviewScreen(),
              PendingReviewScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
