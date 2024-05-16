// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_forms/flutter_dynamic_forms.dart';
import 'package:flutter_dynamic_forms_components/flutter_dynamic_forms_components.dart'
    as cp;

class TextFieldWidget2 extends StatefulWidget {
  final String id;
  final String text;
  final String errorText;
  final String label;
  final cp.TextFieldInputType textInputType;
  final FormElementEventDispatcherFunction dispatcher;

  const TextFieldWidget2({
    Key key,
    this.id,
    this.text,
    this.label,
    this.dispatcher,
    this.errorText,
    this.textInputType,
  }) : super(key: key);

  @override
  _TextFieldWidgetState2 createState() => _TextFieldWidgetState2();
}

class _TextFieldWidgetState2 extends State<TextFieldWidget2> {
  TextEditingController _controller = TextEditingController();

  VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () => widget.dispatcher(
          ChangeValueEvent(value: _controller.text, elementId: widget.id),
        );
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    if (_listener != null) {
      _controller?.removeListener(_listener);
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.text != widget.text) {
      _controller.text = widget.text;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
            labelText: widget.label, errorText: widget.errorText),
        keyboardType: getTextInputType(widget.textInputType),
        maxLines:
            widget.textInputType == cp.TextFieldInputType.multiline ? 3 : null,
        controller: _controller,
      ),
    );
  }

  TextInputType getTextInputType(cp.TextFieldInputType textInputType) {
    TextInputType result;

    switch (textInputType) {
      case cp.TextFieldInputType.datetime:
        result = TextInputType.datetime;
        break;
      case cp.TextFieldInputType.emailAddress:
        result = TextInputType.emailAddress;
        break;
      case cp.TextFieldInputType.multiline:
        result = TextInputType.multiline;
        break;
      case cp.TextFieldInputType.number:
        result = TextInputType.number;
        break;
      case cp.TextFieldInputType.money:
        result = TextInputType.numberWithOptions(signed: false, decimal: true);
        break;
      case cp.TextFieldInputType.phone:
        result = TextInputType.phone;
        break;
      case cp.TextFieldInputType.text:
        result = TextInputType.text;
        break;
      case cp.TextFieldInputType.url:
        result = TextInputType.url;
        break;
      default:
        result = TextInputType.text;
        break;
    }
    return result;
  }
}
