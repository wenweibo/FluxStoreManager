import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class AddAttributeWidget extends StatefulWidget {
  final Function(String)? onCallBack;

  const AddAttributeWidget({Key? key, this.onCallBack}) : super(key: key);
  @override
  State<AddAttributeWidget> createState() => _AddAttributeWidgetState();
}

class _AddAttributeWidgetState extends State<AddAttributeWidget> {
  bool isAdding = false;
  final addController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return isAdding
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                onPressed: () {
                  addController.clear();
                  setState(() => isAdding = !isAdding);
                },
              ),
              Container(
                width: 150,
                height: 40,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: addController,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: S.of(context).addAName,
                        ),
                        onSubmitted: (val) {
                          isAdding = false;
                          var result = addController.text;
                          addController.clear();
                          widget.onCallBack!(result);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () => setState(() => isAdding = !isAdding),
            child: Text(
              S.of(context).addAnAttr,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white),
            ),
          );
  }
}
