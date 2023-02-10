import 'package:flutter/material.dart';
import '../../../../../models/entities/product_attribute.dart';

class AddCustomAttribute extends StatefulWidget {
  final Function(ProductAttribute) onAdded;
  const AddCustomAttribute({Key? key, required this.onAdded}) : super(key: key);

  @override
  State<AddCustomAttribute> createState() => _AddCustomAttributeState();
}

class _AddCustomAttributeState extends State<AddCustomAttribute> {
  bool isEnable = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: isEnable ? 10.0 : 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isEnable) ...[
            InkWell(
              onTap: () {
                isEnable = true;
                _controller.clear();
                _focusNode.requestFocus();
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    Text(
                      'Add new Attribute',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (isEnable) ...[
            Expanded(
                child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(24.0)),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 12.0),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(0.0),
                    isDense: true,
                    hintStyle: TextStyle(fontSize: 12.0),
                    border: InputBorder.none),
              ),
            )),
            IconButton(
                onPressed: () {
                  isEnable = false;
                  if (_controller.text.isNotEmpty) {
                    final p = ProductAttribute(
                      name: _controller.text,
                      label: _controller.text,
                      slug: _controller.text.replaceAll(' ', '-'),
                      isActive: true,
                      isDefault: false,
                      isVariation: false,
                      isVisible: true,
                      optionSlugs: [],
                      options: [],
                    );
                    widget.onAdded(p);
                  }
                },
                icon: const Icon(
                  Icons.check,
                  color: Colors.green,
                )),
            IconButton(
                onPressed: () {
                  isEnable = false;
                  setState(() {});
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                )),
          ],
        ],
      ),
    );
  }
}
