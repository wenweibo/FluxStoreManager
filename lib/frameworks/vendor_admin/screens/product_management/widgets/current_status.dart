import 'package:flutter/material.dart';
import '../../../../../common/config.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../services/service_config.dart';

class CurrentStatus extends StatelessWidget {
  final String status;

  const CurrentStatus({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!ServerConfig().platform.isWcfm ||
        status == 'publish' ||
        status.isEmpty ||
        kVendorConfig.disablePendingProduct) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        S.of(context).yourProductIsUnderReview,
        style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.red),
      ),
    );
  }
}
