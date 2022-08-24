library ios_search_bar;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Creates the Cupertino-style search bar. See the README for an example on how to use.
class IOSSearchBar extends AnimatedWidget {
  IOSSearchBar({
    Key key,
    @required Animation<double> animation,
    @required this.controller,
    @required this.focusNode,
    this.onCancel,
    this.onClear,
    this.onSubmit,
    this.onUpdate,
  })  : assert(controller != null),
        assert(focusNode != null),
        super(key: key, listenable: animation);

  /// The text editing controller to control the search field
  final TextEditingController controller;

  /// The focus node needed to manually unfocus on clear/cancel
  final FocusNode focusNode;

  /// The function to call when the "Cancel" button is pressed
  final Function onCancel;

  /// The function to call when the "Clear" button is pressed
  final Function onClear;

  /// The function to call when the text is updated
  final Function(String) onUpdate;

  /// The function to call when the text field is submitted
  final Function(String) onSubmit;

  static final _opacityTween = Tween(begin: 1.0, end: 0.0);
  static final _paddingTween = Tween(begin: 0.0, end: 40.0);
  static final _kFontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                border: Border.all(width: 0.0, color: CupertinoColors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 1.0),
                        child: Icon(
                          CupertinoIcons.search,
                          color: CupertinoColors.inactiveGray,
                          size: _kFontSize + 2.0,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).search,
                        style: TextStyle(
                          inherit: false,
                          color: CupertinoColors.inactiveGray
                              .withOpacity(_opacityTween.evaluate(animation)),
                          fontSize: _kFontSize,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: EditableText(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: onUpdate,
                            onSubmitted: onSubmit,
                            style: TextStyle(
                              color: CupertinoColors.black,
                              backgroundColor: Colors.white,
                              inherit: false,
                              fontSize: _kFontSize,
                            ),
                            cursorColor: CupertinoColors.black,
                            backgroundCursorColor: CupertinoColors.black,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        minSize: 10.0,
                        padding: const EdgeInsets.all(1.0),
                        borderRadius: BorderRadius.circular(30.0),
                        color: CupertinoColors.white,
                        child: Icon(
                          Icons.photo_camera,
                          size: 24.0,
                          color: CupertinoColors.inactiveGray.withOpacity(
                              1.0 - _opacityTween.evaluate(animation)),
                        ),
                        onPressed: () {
                          if (animation.isDismissed)
                            return;
                          else
                            onClear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _paddingTween.evaluate(animation),
            child: IconButton(
              padding: const EdgeInsets.only(left: 8.0),
              onPressed: onCancel,
              icon: _paddingTween.evaluate(animation) == 40.0
                  ? Icon(Icons.cancel_outlined, color: Colors.white)
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
