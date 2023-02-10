import 'package:flutter/material.dart';
import '../../../../../models/entities/index.dart';

class AddAttributeButton extends StatefulWidget {
  final Function(ProductAttribute attr) onCreate;
  const AddAttributeButton({Key? key, required this.onCreate})
      : super(key: key);

  @override
  State<AddAttributeButton> createState() => _AddAttributeButtonState();
}

class _AddAttributeButtonState extends State<AddAttributeButton> {
  bool isEnable = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: isEnable ? 10.0 : 0.0),
      child: Row(
        children: [
          if (!isEnable) ...[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    isEnable = true;
                    _controller.clear();
                    _focusNode.requestFocus();
                    setState(() {});
                  },
                  icon: const Icon(Icons.add)),
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
                    final attr = ProductAttribute(
                        id: '0',
                        isActive: true,
                        isDefault: false,
                        isVariation: false,
                        isVisible: false,
                        optionSlugs: [],
                        options: [],
                        name: _controller.text,
                        slug: _controller.text.replaceAll(' ', '-'));
                    widget.onCreate(attr);
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
