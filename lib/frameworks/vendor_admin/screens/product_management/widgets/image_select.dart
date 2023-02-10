import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../common/tools.dart';
import '../../../../../generated/l10n.dart';

class ImageSelect extends StatefulWidget {
  final image;
  final Function(dynamic image) onSelect;
  const ImageSelect({Key? key, this.image, required this.onSelect})
      : super(key: key);

  @override
  State<ImageSelect> createState() => _ImageSelectState();
}

class _ImageSelectState extends State<ImageSelect> {
  var _image;
  File? _tmpFile;

  Future<void> _selectImage() async {
    try {
      final list = await ImagePicker.select(
        context,
        maxFiles: 1,
      );
      _image = list.first;
      widget.onSelect(_image);

      if (_tmpFile != null) {
        await _tmpFile!.delete();
      }
      _tmpFile = await ImageTools.writeToFile(
        await ImagePicker.getByteData(_image),
        fileName: UniqueKey().toString(),
      );
      setState(() {});
    } catch (_) {}
  }

  void _clearImage() {
    _image = null;
    _tmpFile = null;
    widget.onSelect(null);
    setState(() {});
  }

  Widget _buildImage() {
    if (_image == null) {
      return const Center(
        child: Icon(
          Icons.camera_alt_outlined,
          size: 36.0,
        ),
      );
    }
    if (_image is String) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: ImageResize(
                url: _image,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: _clearImage,
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.file(
              _tmpFile!,
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: _clearImage,
              icon: const Icon(
                Icons.close,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _image = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            S.of(context).imageFeature,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        InkWell(
          onTap: _selectImage,
          child: AspectRatio(
            aspectRatio: 6 / 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: _image != null ? null : Colors.grey.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16.0),
              ),
              width: MediaQuery.of(context).size.width,
              child: _buildImage(),
            ),
          ),
        ),
      ],
    );
  }
}
