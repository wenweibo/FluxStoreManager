import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../generated/l10n.dart';
import '../../models/notification_screen_model.dart';
import 'widgets/loading_widget.dart';
import 'widgets/notification_widget.dart';

class VendorAdminNotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).notifications,
          style: Theme.of(context).primaryTextTheme.headline5,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Consumer<VendorAdminNotificationScreenModel>(
        builder: (context, model, _) => Stack(
          children: [
            Stack(
              children: [
                Container(
                    width: size.width,
                    height: size.height + 100,
                    color: Theme.of(context).backgroundColor,
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (model.state ==
                          VendorAdminNotificationScreenModelState.loading) {
                        return ListView.builder(
                          itemBuilder: (context, index) =>
                              VendorAdminNotificationLoadingWidget(),
                          itemCount: 10,
                        );
                      }
                      if (model.state ==
                          VendorAdminNotificationScreenModelState.empty) {
                        return Center(
                          child: Text(S.of(context).noData),
                        );
                      }
                      return SmartRefresher(
                        controller: model.refreshController,
                        onLoading: model.loadMoreNotification,
                        onRefresh: model.getNotification,
                        enablePullUp: true,
                        footer: CustomFooter(
                          builder: (_, LoadStatus? status) {
                            return const SizedBox();
                          },
                        ),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            if (index >= model.notifications.length &&
                                model.state ==
                                    VendorAdminNotificationScreenModelState
                                        .loadMore) {
                              return VendorAdminNotificationLoadingWidget();
                            }
                            return VendorAdminNotificationWidget(
                              notificationVendorAdmin:
                                  model.notifications[index],
                            );
                          },
                          itemCount: model.state ==
                                  VendorAdminNotificationScreenModelState
                                      .loadMore
                              ? model.notifications.length + 2
                              : model.notifications.length,
                          cacheExtent: 1000,
                        ),
                      );
                    })),
                if (model.state ==
                    VendorAdminNotificationScreenModelState.loadItem)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
