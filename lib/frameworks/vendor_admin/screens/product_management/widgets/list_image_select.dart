import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../../../common/tools.dart';
import '../../../../../generated/l10n.dart';

class ListImageSelect extends StatefulWidget {
  final List? images;
  final Function(List? images) onSelect;
  const ListImageSelect({Key? key, this.images, required this.onSelect})
      : super(key: key);

  @override
  State<ListImageSelect> createState() => _ListImageSelectState();
}

class _ListImageSelectState extends State<ListImageSelect> {
  var _images;
  List<File?>? _tmpFiles;

  Future<void> _addImage() async {
    try {
      final images = await ImagePicker.select(
        context,
        maxFiles: 5,
      );

      for (var img in images) {
        _images.insert(0, img);
        _tmpFiles!.insert(0, (await _getFile(img)));
      }

      widget.onSelect(_images);

      setState(() {});
    } catch (_) {}
  }

  Future<File> _getFile(AssetEntity image) async {
    final byte = await image.originBytes;

    return await ImageTools.writeToFile(byte, fileName: UniqueKey().toString());
  }

  void _deleteImage({int? index, bool clearAll = false}) {
    if (clearAll) {
      _images.clear();
      _tmpFiles!.clear();
    } else {
      _images.removeAt(index!);
      _tmpFiles!.removeAt(index);
    }
    widget.onSelect(_images);
    setState(() {});
  }

  Widget _buildImage({int? index, bool isAdd = false}) {
    if (isAdd) {
      return InkWell(
        onTap: _addImage,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt_outlined),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.all(5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: _images[index] is String
                  ? ImageResize(url: _images[index], fit: BoxFit.cover)
                  : Image.file(
                      _tmpFiles![index!]!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
            onPressed: () {
              _deleteImage(index: index);
            },
          ),
        )
      ],
    );
  }

  Widget _buildImages() {
    return SizedBox(
      height: 100,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildImage(isAdd: true),
              ...List.generate(
                  _images.length, (index) => _buildImage(index: index))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _images = List.from(widget.images ?? []);
    _tmpFiles = List.generate(_images.length, (index) => null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            S.of(context).gallery,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: _buildImages(),
        ),
      ],
    );
  }
}
