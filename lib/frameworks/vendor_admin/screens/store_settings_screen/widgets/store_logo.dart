import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../common/tools/image_tools.dart';
import '../../../../../generated/l10n.dart';

class StoreLogo extends StatelessWidget {
  final onCallback;
  final storeLogo;

  const StoreLogo({Key? key, this.onCallback, this.storeLogo})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).storeLogo,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const Expanded(child: SizedBox(width: 1)),
          InkWell(
            onTap: onCallback,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: storeLogo == null ||
                      (storeLogo is String && storeLogo.isEmpty)
                  ? Container()
                  : (storeLogo is String)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: storeLogo,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          child: ImagePicker.getThumbnail(storeLogo,
                              width: 300, height: 300),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
