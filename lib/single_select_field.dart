import 'package:flutter/material.dart';

class SingleSelectField<T> extends StatefulWidget {
  final SingleSelectController<T> controller;
  final List<T> items;
  final String Function(T)? stringify;

  final FormFieldValidator<T>? validator;

  const SingleSelectField({
    required this.controller,
    required this.items,
    this.stringify,
    this.validator,
  });

  @override
  _SingleSelectFieldState createState() => _SingleSelectFieldState<T>();
}

class _SingleSelectFieldState<T> extends State<SingleSelectField<T>> {
  @override
  void initState() {
    widget.controller.addListener(() {
      if (widget.controller.value == null) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      items: _buildItems(),
      onChanged: (value) => widget.controller.value = value,
      value: widget.controller.value,
      validator: widget.validator,
    );
  }

  List<DropdownMenuItem<T?>> _buildItems() {
    final List<T?> list = [null, ...widget.items];

    return list.map(
      (e) {
        final String sval =
            e == null ? '' : widget.stringify?.call(e) ?? e.toString();
        return DropdownMenuItem<T?>(
          value: e,
          child: Text(sval),
        );
      },
    ).toList();
  }
}

class SingleSelectController<T> extends ValueNotifier<T?> {
  SingleSelectController({T? value}) : super(value);
}
