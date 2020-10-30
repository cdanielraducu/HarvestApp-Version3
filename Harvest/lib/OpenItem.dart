import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenItem extends StatefulWidget {
  final String url;

  OpenItem(this.url);

  @override
  _OpenItemState createState() => _OpenItemState();
}

class _OpenItemState extends State<OpenItem> {
  Future<void> _launched;
  String pdfUrl = 'pdfUrl';

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  Widget pdf() {
    return RaisedButton(
      onPressed: () => setState(() {
        _launched = _launchInBrowser(pdfUrl);
      }),
      child: const Text('Launch in app'),
    );
  }

  void launchPdf() {
    setState(() {
      _launched = _launchInBrowser(pdfUrl);
    });
  }

  bool _isPdfUrl() {
    if (pdfUrl == 'pdfUrl') {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.url == null ? pdfUrl = 'pdfUrl' : pdfUrl = widget.url;
    return _isPdfUrl()
        ? Container()
        : Padding(
            padding: const EdgeInsets.only(
                // bottom: 39,
                ),
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  // child: Ink.image(
                  //   image: AssetImage('lib/assets/asset-pdf.png'),
                  //   fit: BoxFit.contain,
                  child: InkWell(
                    onTap: launchPdf,
                    child: Text('Open spotify'),
                  ),
                  // ),
                ),
                // Container(child: Text('Intrebari')),
              ],
            ),
          );
  }
}
