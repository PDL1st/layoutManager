import 'package:flutter/material.dart';
import 'package:layout_manager/layout_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutProvider extends StatefulWidget {
  final String uuid;
  final String limiter;
  final String? label;
  final Color backgroundColor;
  final Widget responseWidget;
  const LayoutProvider({
    required this.uuid,
    required this.responseWidget,
    required this.backgroundColor,
    required this.limiter,
    this.label,
    super.key,
  });

  @override
  State<LayoutProvider> createState() => _LayoutProviderState();
}

class _LayoutProviderState extends State<LayoutProvider> {
  WebViewController? webViewController;
  bool urlStatus = false;
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
                  urlStatus = status;
                });
              },
              onPageFinished: (String url) async {
                final status = await LayoutManager.getLayoutLimiter(
                  widget.label,
                  widget.limiter,
                  url,
                );

                setState(() {
                  urlStatus = status;
                });
              },
            ),
          );
      }
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
            return const SizedBox();
          }

          if (webViewController == null) {
            return widget.responseWidget;
          }

          if (urlStatus) {
            return widget.responseWidget;
          } else {
            return WebViewWidget(controller: webViewController!);
          }
        },
      ),
    );
  }
}
