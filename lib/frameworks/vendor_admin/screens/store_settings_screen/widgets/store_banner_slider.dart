import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../common/tools.dart';
import '../../../../../generated/l10n.dart';

class StoreBannerSlider extends StatelessWidget {
  final onCallback;
  final onRemove;
  final storeListBanner;
  final title;

  const StoreBannerSlider(
      {Key? key,
      this.onCallback,
      this.storeListBanner,
      this.title,
      this.onRemove})
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onCallback,
                child: SizedBox(
                  width: 105,
                  height: 105,
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      storeListBanner.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 105,
                              height: 105,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: (storeListBanner[index]['image']
                                              is String)
                                          ? storeListBanner[index]['image']
                                                  .isEmpty
                                              ? Container(
                                                  color: Colors.red,
                                                  width: 50,
                                                  height: 50,
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10.0,
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        storeListBanner[index]
                                                            ['image'],
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10.0,
                                              ),
                                              child: ImagePicker.getThumbnail(
                                                  storeListBanner[index]
                                                      ['image'],
                                                  width: 300,
                                                  height: 300),
                                            ),
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () => onRemove(index),
                                        child: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              S.of(context).link,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 105,
                              height: 35,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Center(
                                child: TextField(
                                  enabled: onCallback != null,
                                  decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 18.0)),
                                  controller: storeListBanner[index]['link'],
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
