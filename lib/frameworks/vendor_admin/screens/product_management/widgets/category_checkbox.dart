import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';

import '../../../../../models/entities/category.dart';

class CategoryCheckBox extends StatefulWidget {
  final Category category;
  final bool isChecked;
  final VoidCallback onCallBack;
  const CategoryCheckBox(
      {Key? key,
      required this.category,
      required this.isChecked,
      required this.onCallBack})
      : super(key: key);

  @override
  State<CategoryCheckBox> createState() => _CategoryCheckBoxState();
}

class _CategoryCheckBoxState extends State<CategoryCheckBox> {
  bool isChecked = false;
  @override
  void initState() {
    isChecked = widget.isChecked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: isChecked,
              onChanged: (val) {
                widget.onCallBack();
                isChecked = !isChecked;
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 5),
                Expanded(child: Text(widget.category.name ?? '')),
                if (widget.category.hasChildren ?? false)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16.0,
                  ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryLoadingCheckbox extends StatelessWidget {
  const CategoryLoadingCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: true,
              onChanged: (val) {},
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Row(
              children: const [
                SizedBox(width: 5),
                Expanded(child: Skeleton()),
                SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
