import 'package:flutter/material.dart';
import 'package:layout_manager/layout_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutProvider extends StatefulWidget {
  final String uuid;
  final String limiter;
  final String? label;
  final Color backgroundColor;
  final Widget responseWidget;
  final Widget? splashWidget;
  final Function(bool)? onLimitedLayoutChanged;

  const LayoutProvider({
    required this.uuid,
    required this.responseWidget,
    required this.backgroundColor,
    required this.limiter,
    this.label,
    this.onLimitedLayoutChanged,
    this.splashWidget,
    super.key,
  });

  @override
  State<LayoutProvider> createState() => _LayoutProviderState();
}

class _LayoutProviderState extends State<LayoutProvider> {
  WebViewController? webViewController;
  bool isLimitedLayout = false;
  bool isStarted = false;
  String? fetchData;

  @override
  void initState() {
    Future.sync(() async {
      fetchData = await LayoutManager.configurateLayout(
        functionName: widget.label,
        uuid: widget.uuid,
      );

      if (fetchData != null) {
        if (widget.onLimitedLayoutChanged != null) {
          widget.onLimitedLayoutChanged!.call(false);
        }

        webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(widget.backgroundColor)
          ..loadRequest(Uri.parse(fetchData!))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) async {
                final status = await LayoutManager.getLayoutLimiter(
                  widget.label,
                  widget.limiter,
                  url,
                );

                setState(() {
                  isStarted = true;
                  isLimitedLayout = status;

                  if (widget.onLimitedLayoutChanged != null) {
                    widget.onLimitedLayoutChanged!.call(status);
                  }
                });
              },
              onPageFinished: (String url) async {
                final status = await LayoutManager.getLayoutLimiter(
                  widget.label,
                  widget.limiter,
                  url,
                );

                setState(() {
                  isLimitedLayout = status;

                  if (widget.onLimitedLayoutChanged != null) {
                    widget.onLimitedLayoutChanged!.call(status);
                  }
                });
              },
            ),
          );

        return;
      }

      if (widget.onLimitedLayoutChanged != null) {
        widget.onLimitedLayoutChanged!.call(true);
      }

      return;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: LayoutBuilder(
        builder: (context, snapshot) {
          if (!isStarted) {
            return widget.splashWidget ?? const SizedBox();
          }

          if (webViewController == null) {
            return widget.responseWidget;
          }

          if (isLimitedLayout) {
            return widget.responseWidget;
          } else {
            return WebViewWidget(controller: webViewController!);
          }
        },
      ),
    );
  }
}
