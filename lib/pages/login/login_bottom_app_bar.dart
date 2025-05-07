import 'package:flutter/material.dart';
import 'package:my_flutter_framework/shared/components/message_box.dart';

class LoginBottomAppBar extends StatelessWidget {
  final VoidCallback onLeftAction;
  final VoidCallback onBiometricLogin;
  final VoidCallback onRightAction;

  const LoginBottomAppBar({
    Key? key,
    required this.onLeftAction,
    required this.onBiometricLogin,
    required this.onRightAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 500; // 判斷是否為小螢幕

    return BottomAppBar(
      child: Row(
        children: [
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onLeftAction,
                child: Container(
                  height: 60,
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.white),
                      if (!isSmallScreen) const SizedBox(width: 8),
                      if (!isSmallScreen)
                        const Text(
                          'Left Action',
                          style: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onBiometricLogin,
                child: Container(
                  height: 60,
                  color: Colors.green,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fingerprint, color: Colors.white),
                      if (!isSmallScreen) const SizedBox(width: 8),
                      if (!isSmallScreen)
                        Flexible(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            'Login with Biometrics',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  onRightAction();
                  showMessageBox(
                    context: context,
                    title: 'This is a very long message that should also wrap or truncate properly in the MessageBox widget. The message is intentionally verbose and contains multiple sentences to simulate a real-world scenario where a lot of information needs to be displayed to the user. This test ensures that the widget can handle such cases gracefully without breaking the layout or causing unexpected behavior.',
                    message: 'This is a very long message that should also wrap or truncate properly in the MessageBox widget. The message is intentionally verbose and contains multiple sentences to simulate a real-world scenario where a lot of information needs to be displayed to the user. This test ensures that the widget can handle such cases gracefully without breaking the layout or causing unexpected behavior.',
                    onConfirm: () => Navigator.of(context).pop(),
                  );
                },
                child: Container(
                  height: 60,
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward, color: Colors.white),
                      if (!isSmallScreen) const SizedBox(width: 8),
                      if (!isSmallScreen)
                        const Text(
                          'Right Action',
                          style: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
