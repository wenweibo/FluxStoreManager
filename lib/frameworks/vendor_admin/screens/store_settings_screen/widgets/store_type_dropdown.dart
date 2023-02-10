import 'package:flutter/material.dart';

class StoreTypeDropdown extends StatefulWidget {
  final bool enable;
  final currentType;
  final List<dynamic>? types;
  final onCallBack;
  final double width;
  final String title;
  const StoreTypeDropdown({
    Key? key,
    this.currentType,
    this.types,
    this.onCallBack,
    this.width = 100.0,
    this.title = '',
    this.enable = false,
  }) : super(key: key);
  @override
  State<StoreTypeDropdown> createState() => _StoreTypeDropdownState();
}

class _StoreTypeDropdownState extends State<StoreTypeDropdown>
    with TickerProviderStateMixin {
  bool isOpen = false;
  String? _currentType;

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) {
      isOpen = false;
    }
    _currentType = widget.currentType;
    return Container(
      margin: const EdgeInsets.only(left: 15.0, top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: widget.enable
                    ? () => setState(() => isOpen = !isOpen)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.enable
                          ? isOpen
                              ? Colors.red
                              : Colors.blue
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  width: widget.width,
                  height: 30.0,
                  child: Center(
                    child: Text(
                      _currentType!,
                      style:
                          TextStyle(color: widget.enable ? null : Colors.grey),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      widget.types!.length,
                      (index) => InkWell(
                        onTap: widget.enable
                            ? () {
                                _currentType = widget.types![index];
                                setState(() {});
                                widget.onCallBack(_currentType);
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isOpen ? widget.width : 0.0,
                          padding: isOpen
                              ? const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0)
                              : const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 5.0),
                          margin: isOpen
                              ? const EdgeInsets.only(left: 10.0)
                              : const EdgeInsets.only(left: 0.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          height: 30.0,
                          child: Center(
                            child: Text(
                              widget.types![index],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
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

//    return DropdownButton(
//      onChanged: widget.onCallBack,
//      items: List.generate(
//          widget.types.length,
//          (index) => DropdownMenuItem(
//                value: widget.types[index],
//                child: Text(widget.types[index]),
//              )),
//      isDense: true,
//      isExpanded: true,
//      value: widget.currentType,
//    );
  }
}
