import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

enum ProgressDialogType { Normal, Download }

typedef Future<bool> DismissCallback();

String _dialogMessage = "Loading...";
double _progress = 0.0, _maxProgress = 100.0;

Widget _customBody;

TextAlign _textAlign = TextAlign.left;
Alignment _progressWidgetAlignment = Alignment.centerLeft;

TextDirection _direction = TextDirection.ltr;

bool _isShowing = false;
BuildContext _context, _dismissingContext;
ProgressDialogType _progressDialogType;
bool _barrierDismissible = true, _showCloseButton = false, _showLogs = false;
DismissCallback _dismissCallback;

TextStyle _progressTextStyle = TextStyle(
        color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w400),
    _messageStyle = TextStyle(
        color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w600);

double _dialogElevation = 8.0, _borderRadius = 8.0;
Color _backgroundColor = Colors.white;
Curve _insetAnimCurve = Curves.easeInOut;
EdgeInsets _dialogPadding = const EdgeInsets.all(8.0);



Widget _progressWidget = Image.asset(
  'assets/double_ring_loading_io.gif',
  package: 'progress_dialog',
);

class ProgressDialog {
  _Body _dialog;

  ProgressDialog(BuildContext context,
      {ProgressDialogType type,
        bool isDismissible,
        bool showLogs,
        bool showCloseButton,
        TextDirection textDirection,
        Widget customBody,
        DismissCallback dismissCallback,
      }) {
    _context = context;
    _dialog = new _Body(this);
    _progressDialogType = type ?? ProgressDialogType.Normal;
    _barrierDismissible = isDismissible ?? true;
    _showLogs = showLogs ?? false;
    _showCloseButton = showCloseButton ?? false;
    _customBody = customBody ?? null;
    _direction = textDirection ?? TextDirection.ltr;
    _dismissCallback = dismissCallback ?? null;
  }

  void style(
      {Widget child,
      double progress,
      double maxProgress,
      String message,
      Widget progressWidget,
      Color backgroundColor,
      TextStyle progressTextStyle,
      TextStyle messageTextStyle,
      double elevation,
      TextAlign textAlign,
      double borderRadius,
      Curve insetAnimCurve,
      EdgeInsets padding,
      Alignment progressWidgetAlignment}) {
    if (_isShowing) return;
    if (_progressDialogType == ProgressDialogType.Download) {
      _progress = progress ?? _progress;
    }

    _dialogMessage = message ?? _dialogMessage;
    _maxProgress = maxProgress ?? _maxProgress;
    _progressWidget = progressWidget ?? _progressWidget;
    _backgroundColor = backgroundColor ?? _backgroundColor;
    _messageStyle = messageTextStyle ?? _messageStyle;
    _progressTextStyle = progressTextStyle ?? _progressTextStyle;
    _dialogElevation = elevation ?? _dialogElevation;
    _borderRadius = borderRadius ?? _borderRadius;
    _insetAnimCurve = insetAnimCurve ?? _insetAnimCurve;
    _textAlign = textAlign ?? _textAlign;
    _progressWidget = child ?? _progressWidget;
    _dialogPadding = padding ?? _dialogPadding;
    _progressWidgetAlignment =
        progressWidgetAlignment ?? _progressWidgetAlignment;
  }

  void update(
      {double progress,
      double maxProgress,
      String message,
      Widget progressWidget,
      TextStyle progressTextStyle,
      TextStyle messageTextStyle}) {
    if (_progressDialogType == ProgressDialogType.Download) {
      _progress = progress ?? _progress;
    }

    _dialogMessage = message ?? _dialogMessage;
    _maxProgress = maxProgress ?? _maxProgress;
    _progressWidget = progressWidget ?? _progressWidget;
    _messageStyle = messageTextStyle ?? _messageStyle;
    _progressTextStyle = progressTextStyle ?? _progressTextStyle;

    if (_isShowing) _dialog.update();
  }

  bool isShowing() {
    return _isShowing;
  }

  Future<bool> preHide() async {
    Alert(
      context: _context,
      type: AlertType.warning,
      title: "Atención",
      desc: "Va a cancelar la tarea en curso.",
      buttons: [
        DialogButton(
          child: Text(
            "SI",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            if (_dismissCallback != null)
            {
              if (_showLogs) debugPrint('calling Dismiss callback');
              await  _dismissCallback();
            }

            if (_showLogs) debugPrint('calling hide');
            var result = await hide();

            if (_showLogs) debugPrint('calling navigator pop');
            Navigator.pop(_context);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "NO",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {

            Navigator.pop(_context);

          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();

    return Future.value(false);
  }

  Future<bool> hide() async {
    try {
      if (_isShowing) {
        _isShowing = false;
        if (_showLogs) debugPrint('ProgressDialog dismissed');
        Navigator.of(_dismissingContext).pop();
        return Future.value(true);
      } else {
        if (_showLogs) debugPrint('ProgressDialog already dismissed');
        return Future.value(false);
      }
    } catch (err) {
      debugPrint('Seems there is an issue hiding dialog');
      debugPrint(err.toString());
      return Future.value(false);
    }
  }

  Future<bool> show() async {
    try {
      if (!_isShowing) {
        if (_dialog == null)  _dialog =  _Body(this);
        showDialog<dynamic>(
          context: _context,
          barrierDismissible: _barrierDismissible,
          builder: (BuildContext context) {
            _dismissingContext = context;
            return WillPopScope(
              onWillPop: () async => _barrierDismissible,
              child: Dialog(
                  backgroundColor: _backgroundColor,
                  insetAnimationCurve: _insetAnimCurve,
                  insetAnimationDuration: Duration(milliseconds: 100),
                  elevation: _dialogElevation,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(_borderRadius))),
                  child: _dialog),
            );
          },
        );
        // Delaying the function for 200 milliseconds
        // [Default transitionDuration of DialogRoute]
        await Future.delayed(Duration(milliseconds: 200));
        if (_showLogs) debugPrint('ProgressDialog shown');
        _isShowing = true;
        return true;
      } else {
        if (_showLogs) debugPrint("ProgressDialog already shown/showing");
        return false;
      }
    } catch (err) {
      _isShowing = false;
      debugPrint('Exception while showing the dialog');
      debugPrint(err.toString());
      return false;
    }
  }


}

// ignore: must_be_immutable
class _Body extends StatefulWidget {
  final ProgressDialog myProgressDialog;

  _BodyState _dialog = _BodyState();


  _Body(this.myProgressDialog);

  update() {
    _dialog.update();
  }

  @override
  State<StatefulWidget> createState() {
    return _dialog;
  }
}

class _BodyState extends State<_Body> {
  update() {
    setState(() {});
  }

  @override
  void dispose() {
    _isShowing = false;
    if (_showLogs) debugPrint('ProgressDialog dismissed by back button');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loader = Align(
      alignment: _progressWidgetAlignment,
      child: SizedBox(
        width: 60.0,
        height: 60.0,
        child: _progressWidget,
      ),
    );

    final text = Expanded(
      child: _progressDialogType == ProgressDialogType.Normal
          ? Text(
        _dialogMessage,
        textAlign: _textAlign,
        style: _messageStyle,
        textDirection: _direction,
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                      _dialogMessage,
                      style: _messageStyle,
                      textDirection: _direction,
                    )),
              ],
            ),
            SizedBox(height: 4.0),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "${_progress.toInt()}/${_maxProgress.toInt()}",
                style: _progressTextStyle,
                textDirection: _direction,
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        _customBody ??
            Container(
              padding: _dialogPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // row body
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(width: 8.0),
                      _direction == TextDirection.ltr ? loader : text,
                      const SizedBox(width: 8.0),
                      _direction == TextDirection.rtl ? loader : text,
                      const SizedBox(width: 8.0)
                    ],
                  ),
                ],
              ),
            ),
        Visibility(
          visible: _showCloseButton,
          child: Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () async {
                bool  result = await widget.myProgressDialog.preHide();

              },
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.close, color: Colors.red),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
