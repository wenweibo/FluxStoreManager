import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../common/tools.dart';

class StoreBanner extends StatelessWidget {
  final onCallback;
  final storeBanner;
  final title;

  const StoreBanner({Key? key, this.onCallback, this.storeBanner, this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onCallback,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: (storeBanner is String)
                  ? storeBanner.isEmpty
                      ? Container()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: storeBanner,
                            fit: BoxFit.cover,
                          ),
                        )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                      child: ImagePicker.getThumbnail(
                        storeBanner,
                        width: 300,
                        height: 300,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
