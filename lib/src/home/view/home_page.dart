import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:opinio_quest/src/home/provider/home_provider.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final homeProvider = ref.read(homePageProvider.notifier);
    final state = ref.watch(homePageProvider);
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (context, connectivity, child) {
          if (connectivity == ConnectivityResult.none) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'Oops, \n\nNow we are Offline!',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          } else {
            return child;
          }
        },
        builder: (context) {
          return Builder(
            builder: (BuildContext context) {
              return Theme(
                data: ThemeData(
                  primaryColor: Colors.red,
                ),
                child: OverlayLoaderWithAppIcon(
                  isLoading: state.isLoading,
                  overlayBackgroundColor: Colors.black,
                  circularProgressColor: Colors.black,
                  appIcon: Image.asset(
                    'assets/images/logo.png',
                  ),
                  appIconSize: 35,
                  child: GestureDetector(
                    // onVerticalDragUpdate: (details) {
                    //   print(details);
                    // },
                    //  onHorizontalDragUpdate: (updateDetails) {},
                    child: SafeArea(
                      bottom: false,
                      child: WebView(
                        userAgent: "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0",
                        initialUrl: 'https://www.opinioquest.com',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (WebViewController webViewController) {
                          homeProvider.controller.complete(webViewController);
                        },
                        onProgress: (int progress) {
                          homeProvider.controller.future.then((webviewController) => webviewController
                              .runJavascript(
                                  "javascript:(function() {  var nav = document.getElementsByClassName('header-mobile-left')[0];nav.parentNode.removeChild(nav); var header2 = document.getElementsByClassName('header-v2-mobile')[0];header2.parentNode.removeChild(header2);    var head = document.getElementsByClassName('header-mobile-center')[0];head.parentNode.removeChild(head);var footer = document.getElementsByTagName('footer')[0];footer.parentNode.removeChild(footer);})()")
                              .then((value) => debugPrint('Page finished running Javascript'))
                              .catchError((onError) => debugPrint('$onError')));
                          if (progress > 80) {
                            homeProvider.isLoading = false;
                          }
                        },
                        javascriptChannels: <JavascriptChannel>{
                          _toasterJavascriptChannel(context),
                        },
                        navigationDelegate: (NavigationRequest request) {
                          if (request.url.startsWith('https://www.youtube.com/')) {
                            return NavigationDecision.prevent;
                          }
                          return NavigationDecision.navigate;
                        },
                        onPageStarted: (String url) {
                          homeProvider.isLoading = true;
                        },
                        zoomEnabled: true,
                        onPageFinished: (String url) {
                          homeProvider.isLoading = false;
                        },
                        gestureNavigationEnabled: true,
                        backgroundColor: Colors.white,
                        geolocationEnabled: true, // set geolocationEnable true or not
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        // ignore: deprecated_member_use
      },
    );
  }
}
