import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class TermsOverlay extends StatelessWidget {
  final String htmlData = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Terms and Conditions</title>
</head>
<body>
  <p>Last updated: June 18, 2025</p>

  <p>Welcome to Bhasha Buddy designed for educational and entertainment purposes for children aged 8–14. Please read these Terms and Conditions carefully before using the App operated by us.</p>

  <h2>1. Acceptance of Terms</h2>
  <p>By downloading, accessing, or using the App, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the App.</p>

  <h2>2. Use of the App</h2>
  <ul>
    <li>This App is intended for students aged 8–14 under parental supervision.</li>
    <li>Users are required to create an account via Firebase Authentication to access certain features.</li>
    <li>All information provided during registration must be accurate and up to date.</li>
  </ul>

  <h2>3. Privacy and Data</h2>
  <p>We are committed to protecting your privacy. The App collects limited personal information such as email addresses and nicknames, and may process audio and image data for educational features such as speech recognition and handwriting recognition.</p>
  <p>For more details, refer to our <a href="#">Privacy Policy</a>.</p>

  <h2>4. Educational Features</h2>
  <ul>
    <li>The App uses text-to-speech technology to invoke spoken words.</li>
    <li>The App may prompt children to upload images of handwriting for educational tasks.</li>
    <li>All features are designed with the safety and development of children in mind.</li>
  </ul>

  <h2>5. Parental Controls</h2>
  <p>We provide parental tools for monitoring progress, limiting screen time, and accessing learning reports. Parents must ensure they supervise usage appropriately.</p>

  <h2>6. Intellectual Property</h2>
  <p>All content, features, and source code in this App are the intellectual property of Caramel Labs and protected by copyright laws.</p>

  <h2>7. Limitation of Liability</h2>
  <p>We do not accept responsibility for any indirect or consequential loss arising from the use of the App. Use of the App is at your own risk.</p>

  <h2>8. Changes to Terms</h2>
  <p>We may update these Terms and Conditions from time to time. Continued use of the App after changes constitutes your acceptance of the new terms.</p>

  <h2>9. Contact Us</h2>
  <p>If you have any questions about these Terms and Conditions, please contact us at caramel@gmail.com.</p>
</body>
</html>
  ''';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: 500),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Terms and Conditions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Html(data: htmlData),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}