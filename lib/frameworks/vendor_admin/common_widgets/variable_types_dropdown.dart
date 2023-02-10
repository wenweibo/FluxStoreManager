import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class VariableTypesDropdown extends StatefulWidget {
  final Function(String?)? onCallBack;
  final String? type;
  const VariableTypesDropdown({Key? key, this.onCallBack, this.type})
      : super(key: key);
  @override
  State<VariableTypesDropdown> createState() => _VariableTypesDropdownState();
}

class _VariableTypesDropdownState extends State<VariableTypesDropdown> {
  final List<String> statuses = ['simple', 'variable'];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: widget.type,
        elevation: 16,
        style: Theme.of(context).textTheme.subtitle1,
        onChanged: (String? newValue) {
          widget.onCallBack!(newValue);
        },
        items: List.generate(statuses.length, (index) {
          late String text;
          switch (statuses[index]) {
            case 'simple':
              text = S.of(context).simple;
              break;
            case 'variable':
              text = S.of(context).variable;
              break;
            case 'grouped':
              text = S.of(context).grouped;
              break;
          }
          return DropdownMenuItem<String>(
            value: statuses[index],
            child: Text(
              text,
              style: Theme.of(context).textTheme.caption,
            ),
          );
        }));
  }
}
