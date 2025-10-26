import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_heyteacher_utils/src/e2ee/e2ee_view_model.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/src/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A card widget for managing the End-to-End Encryption (E2EE) passphrase.
///
/// This widget provides a [TextField] for the user to enter or update their
/// E2EE passphrase (AAD). It includes a visibility toggle and handles the
/// confirmation logic for changing an existing passphrase to prevent accidental
/// data loss.
class E2EEPassphraseCard extends StatefulWidget {
  /// Creates an [E2EEPassphraseCard].
  const E2EEPassphraseCard({
    required this.focusNode,
    required this.setPassphraseCallback,
    super.key,
  });

  /// The [FocusNode] for the passphrase input field.
  final FocusNode focusNode;

  /// A callback that is invoked after the passphrase has been successfully set.
  final VoidCallback setPassphraseCallback;

  @override
  State<E2EEPassphraseCard> createState() => _E2EEPassphraseCard();
}

class _E2EEPassphraseCard extends State<E2EEPassphraseCard> {
  bool _passphraseVisibility = false;
  bool _warningAlreadyShowed = false;
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: E2EEViewModel.instance(AuthViewModel.instance.uid).getAAD(),
    builder: (_, aadSnapshot) => Card(
      child: ListTile(
        focusNode: widget.focusNode,
        leading: const Icon(Icons.password),
        title: StreamBuilder<User?>(
          stream: AuthViewModel.instance.stateChangesStream,
          builder: (_, userSnapshot) => TextField(
            enabled: userSnapshot.hasData,
            onChanged: (value) async =>
                _setPassphrase(value, oldValue: aadSnapshot.data),
            obscureText:
                !_passphraseVisibility &&
                (aadSnapshot.data?.isNotEmpty ?? false),
            decoration: InputDecoration(
              isDense: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ThemeViewModel.instance.theme.colorScheme.onSurface,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _passphraseVisibility
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => setState(
                  () => _passphraseVisibility = !_passphraseVisibility,
                ),
              ),
              labelText: FlutterHeyteacherUtilsLocalizations.of(
                context,
              )!.encryptionPassphrase,
            ),
            controller: TextEditingController(text: aadSnapshot.data ?? ''),
          ),
        ),
      ),
    ),
  );

  Future<void> _setPassphrase(String value, {String? oldValue}) async {
    // first time, show a warning on change encryption password and
    // lost ability to decrypt data
    if (!_warningAlreadyShowed && (oldValue?.isNotEmpty ?? false)) {
      unawaited(
        showConfirmCancelDialog(
          context: context,
          confirmCallback: (_) async {
            await E2EEViewModel.instance(
              AuthViewModel.instance.uid,
            ).setAAD(aadValue: value);
            _warningAlreadyShowed = true;
            widget.setPassphraseCallback();
            return null;
          },
          cancelCallback: (_) async {
            setState(() {});
            return null;
          },
          content: Text(
            FlutterHeyteacherUtilsLocalizations.of(
              context,
            )!.areYouSureToChangeEncryptionPassphrase,
          ),
        ),
      );
    } else {
      await E2EEViewModel.instance(
        AuthViewModel.instance.uid,
      ).setAAD(aadValue: value);
      widget.setPassphraseCallback();
    }
  }
}

/// A card widget for managing the End-to-End Encryption (E2EE) secret key.
///
/// This widget displays the status of the secret key (whether it's stored or
/// not) and provides actions to export or import it.
///
/// - **Export**: Displays the secret key as a QR code for another device 
///   to scan.
/// - **Import**: Allows importing the secret key by scanning a QR code 
///   (on mobile) or by pasting the key data (on non-mobile platforms).
class E2EESecretKeyCard extends StatefulWidget {
  /// Creates an [E2EESecretKeyCard].
  const E2EESecretKeyCard({
    required FocusNode encryptionPassphraseFocusNode,
    required void Function() secretKeyImportedCallback,
    super.key,
  }) : _secretKeyImportedCallback = secretKeyImportedCallback,
       _encryptionPassphraseFocusNode = encryptionPassphraseFocusNode;

  /// The [FocusNode] for the passphrase input field, used to remove focus
  /// when showing the QR code.
  final FocusNode _encryptionPassphraseFocusNode;
  /// A callback that is invoked after the secret key has been successfully
  /// imported.
  final VoidCallback _secretKeyImportedCallback;

  @override
  State<E2EESecretKeyCard> createState() => _E2EESecretKeyCardState();
}

class _E2EESecretKeyCardState extends State<E2EESecretKeyCard> {
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: E2EEViewModel.instance(AuthViewModel.instance.uid).secretKeyStored,
    builder: (_, secretKeySnapshot) => Card(
      child: ListTile(
        leading: Icon(
          secretKeySnapshot.data ?? false ? Icons.key : Icons.key_off,
          color: secretKeySnapshot.data ?? false
              ? ThemeViewModel.instance.greenColor
              : ThemeViewModel.instance.redColor,
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            FlutterHeyteacherUtilsLocalizations.of(
              context,
            )!.encryptionSecretKey,
          ),
        ),
        trailing: Wrap(
          children: [
            IconButton(
              onPressed: () => AuthViewModel.instance.autenticated
                  ? _showQrCode()
                  : showConfirmCancelDialog<void>(
                      context: context,
                      content: Text(
                        FlutterHeyteacherUtilsLocalizations.of(
                          context,
                        )!.userNotAuthenticated,
                      ),
                    ),
              icon: const Icon(Icons.qr_code),
            ),
            if (PlatformHelper.isMobile)
              IconButton(
                onPressed: _showQrCodeScanner,
                icon: const Icon(Icons.qr_code_scanner),
              ),
            if (PlatformHelper.isNotMobile)
              IconButton(
                onPressed: _uploadSecretKey,
                icon: const Icon(Icons.upload),
              ),
          ],
        ),
      ),
    ),
  );

  Future<void> _showQrCode() async {
    // remove focus on encryption passphrase
    widget._encryptionPassphraseFocusNode.unfocus();
    await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return FutureBuilder<String>(
          future: E2EEViewModel.instance(
            AuthViewModel.instance.uid,
          ).exportSecretJwkJson(),
          builder: (_, snapshot) => snapshot.hasData
              ? AlertDialog(
                  title: Text(
                    FlutterHeyteacherUtilsLocalizations.of(
                      context,
                      // impossible to avoid length exceeding
                      // ignore: lines_longer_than_80_chars
                    )!.scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase,
                  ),
                  content: SizedBox(
                    width: 500,
                    child: QrImageView(
                      data: snapshot.data!,
                      backgroundColor: Colors.white,
                    ),
                  ),
                )
              : snapshot.hasError
              ? AlertDialog(
                  content: Text(snapshot.error.toString()),
                  actions: <Widget>[
                    IconButton(
                      key: const ValueKey('ib_dialog_no'),
                      icon: Icon(
                        Icons.close,
                        color: ThemeViewModel.instance.redColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                )
              : const ProgressIndicatorView(),
        );
      },
    );
    setState(() {});
  }

  Future<void> _uploadSecretKey() async {
    String? secretJwkJson;
    await showConfirmCancelDialog<void>(
      context: context,
      title: Text(
        FlutterHeyteacherUtilsLocalizations.of(context)!.encryptionSecretKey,
      ),
      confirmCallback: (_) async {
        await E2EEViewModel.instance(
          AuthViewModel.instance.uid,
        ).importSecretJwkJson(secretJwkJson!);
        if (mounted) setState(() {});
        widget._secretKeyImportedCallback();
        return null;
      },
      content: TextField(
        minLines: 10,
        maxLines: 20,
        // expands: true,
        keyboardType: TextInputType.multiline,
        onChanged: (value) => secretJwkJson = value,
        decoration: InputDecoration(
          isDense: true,

          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: ThemeViewModel.instance.theme.colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _showQrCodeScanner() async {
    // get localized confirm question message before async invocation
    final confirmQuestionMessage = FlutterHeyteacherUtilsLocalizations.of(
      context,
    )!.areYouSureToImportEncryptionSecretKey;
    widget._encryptionPassphraseFocusNode.unfocus();
    if (AuthViewModel.instance.notAutenticated) {
      unawaited(showConfirmCancelDialog<void>(
        context: context,
        content: Text(
          FlutterHeyteacherUtilsLocalizations.of(context)!.userNotAuthenticated,
        ),
      ));
      return;
    }
    String? secretJwkJson;
    await showDialog<bool>(
      context: context,
      builder: (context) => MobileScanner(
        onDetect: (barcodeCapture) {
          if (barcodeCapture.barcodes.firstOrNull?.displayValue?.isNotEmpty ??
              false) {
            secretJwkJson = barcodeCapture.barcodes.first.displayValue;
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
    if (secretJwkJson != null) {
      unawaited(showConfirmCancelDialog(
        context: context.mounted ? context : context,
        content: Text(confirmQuestionMessage),
        confirmCallback: (_) async {
          // get localized success message before async invocation
          final successMessage = FlutterHeyteacherUtilsLocalizations.of(
            context,
          )!.encryptionSecretKeyImported;
          await E2EEViewModel.instance(
            AuthViewModel.instance.uid,
          ).importSecretJwkJson(secretJwkJson!);
          setState(() {});
          widget._secretKeyImportedCallback();
          return successMessage;
        },
      ));
    }
  }
}
