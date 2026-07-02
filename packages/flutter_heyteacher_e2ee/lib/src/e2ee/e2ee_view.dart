import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show AuthViewModel, FlutterHeyteacherAuthLocalizations;
import 'package:flutter_heyteacher_e2ee/src/e2ee/e2ee_view_model.dart'
    show E2EEViewModel;
import 'package:flutter_heyteacher_e2ee/src/l10n/flutter_heyteacher_e2ee.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ProgressIndicatorView, ThemeViewModel, showConfirmCancelDialog;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A text field for managing the End-to-End Encryption (E2EE) passphrase.
///
/// This widget provides a [TextField] for the user to enter or update their
/// E2EE passphrase (AAD). It includes a visibility toggle and handles the
/// confirmation logic for changing an existing passphrase to prevent accidental
/// data loss.
class _E2EEPassphraseTextField extends StatefulWidget {
  /// Creates an [_E2EEPassphraseTextField].
  const _E2EEPassphraseTextField({
    required this.focusNode,
    required this.setPassphraseCallback,
    super.key,
  });

  /// The [FocusNode] for the passphrase input field.
  final FocusNode focusNode;

  /// A callback that is invoked after the passphrase has been successfully set.
  final VoidCallback? setPassphraseCallback;

  @override
  State<_E2EEPassphraseTextField> createState() => _E2EEPassphraseListTile();
}

class _E2EEPassphraseListTile extends State<_E2EEPassphraseTextField> {
  bool _passphraseVisibility = false;
  bool _warningAlreadyShowed = false;

  bool _authenticated = AuthViewModel.instance.autenticated;
  String? _aad;

  StreamSubscription<dynamic>? _authStremSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init(_) async {
    // read AAD
    _aad = await E2EEViewModel.instance(AuthViewModel.instance.uid).getAAD();
    setState(() {});
    // listen for auth changes
    unawaited(_authStremSubscription?.cancel());
    _authStremSubscription = AuthViewModel.instance.stateChangesStream.listen(
      (user) async {
        _aad = await E2EEViewModel.instance(
          AuthViewModel.instance.uid,
        ).getAAD();
        setState(() => _authenticated = user != null);
      },
    );
  }

  @override
  void dispose() {
    unawaited(_authStremSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    focusNode: widget.focusNode,
    enabled: _authenticated,
    onChanged: (value) async => _setPassphrase(value, oldValue: _aad),
    obscureText: !_passphraseVisibility && (_aad?.isNotEmpty ?? false),
    decoration: InputDecoration(
      isDense: true,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ThemeViewModel.instance.colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _passphraseVisibility ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () => setState(
          () => _passphraseVisibility = !_passphraseVisibility,
        ),
      ),
      labelText: FlutterHeyteacherE2EELocalizations.of(
        context,
      )!.encryptionPassphrase,
    ),
    controller: TextEditingController(text: _aad ?? ''),
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
            ).setAAD(value);
            _warningAlreadyShowed = true;
            _aad = value;
            widget.setPassphraseCallback?.call();
            return null;
          },
          cancelCallback: (_) async {
            setState(() {});
            return null;
          },
          content: Text(
            FlutterHeyteacherE2EELocalizations.of(
              context,
            )!.areYouSureToChangeEncryptionPassphrase,
          ),
        ),
      );
    } else {
      await E2EEViewModel.instance(AuthViewModel.instance.uid).setAAD(value);
      _aad = value;
      widget.setPassphraseCallback?.call();
    }
  }
}

/// A list tile widget for managing the End-to-End Encryption (E2EE) secret key.
///
/// This widget displays the status of the secret key (whether it's stored or
/// not) and provides actions to export or import it.
///
/// - **Export**: Displays the secret key as a QR code for another device
///   to scan.
/// - **Import**: Allows importing the secret key by scanning a QR code
///   (on mobile) or by pasting the key data (on non-mobile platforms).
class E2EESecretKeyListTile extends StatefulWidget {
  /// Creates an [E2EESecretKeyListTile].
  const E2EESecretKeyListTile({
    VoidCallback? secretKeyImportedCallback,
    Key? e2eePassphraseKey,
    super.key,
  }) : _e2eePassphraseKey = e2eePassphraseKey,
       _secretKeyImportedCallback = secretKeyImportedCallback;

  /// A callback that is invoked after the secret key has been successfully
  /// imported.
  final VoidCallback? _secretKeyImportedCallback;

  final Key? _e2eePassphraseKey;

  @override
  State<E2EESecretKeyListTile> createState() => _E2EESecretKeyListTileState();
}

class _E2EESecretKeyListTileState extends State<E2EESecretKeyListTile> {
  /// The [FocusNode] for the passphrase input field, used to remove focus
  /// when showing the QR code.
  late FocusNode _encryptionPassphraseFocusNode;

  final TextEditingController _secretKeyTextEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _encryptionPassphraseFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _encryptionPassphraseFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: E2EEViewModel.instance(AuthViewModel.instance.uid).secretKeyStored,
    builder: (_, secretKeySnapshot) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        secretKeySnapshot.data ?? false ? Icons.key : Icons.key_off,
        color: secretKeySnapshot.data ?? false
            ? ThemeViewModel.instance.greenColor
            : ThemeViewModel.instance.redColor,
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(
          FlutterHeyteacherE2EELocalizations.of(
            context,
          )!.encryptionSecretKey,
        ),
      ),
      subtitle: _E2EEPassphraseTextField(
        focusNode: _encryptionPassphraseFocusNode,
        setPassphraseCallback: widget._secretKeyImportedCallback,
        key: widget._e2eePassphraseKey,
      ),
      trailing: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.qr_code),
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text(
                      FlutterHeyteacherE2EELocalizations.of(context)!.show,
                    ),
                  ),
                  onPressed: () => AuthViewModel.instance.autenticated
                      ? _showQrCode()
                      : showConfirmCancelDialog<void>(
                          context: context,
                          content: Text(
                            FlutterHeyteacherAuthLocalizations.of(
                              context,
                            )!.userNotAuthenticated,
                          ),
                        ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: PlatformHelper.isMobile
                      ? _showQrCodeScanner
                      : null,
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.qr_code_scanner),
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text(
                      FlutterHeyteacherE2EELocalizations.of(context)!.scan,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async => _secretKeyDialog(
                  initialValue: await E2EEViewModel.instance(
                    AuthViewModel.instance.uid,
                  ).exportSecretJwkJson(),
                ),
                icon: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.edit),
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    FlutterHeyteacherE2EELocalizations.of(context)!.edit,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _showQrCode() async {
    // remove focus on encryption passphrase
    _encryptionPassphraseFocusNode.unfocus();
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
                    FlutterHeyteacherE2EELocalizations.of(
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

  Future<void> _secretKeyDialog({String? initialValue}) async {
    String? secretJwkJson;
    _secretKeyTextEditingController.text = initialValue ?? '';
    await showConfirmCancelDialog<void>(
      context: context,
      title: Text(
        FlutterHeyteacherE2EELocalizations.of(context)!.encryptionSecretKey,
      ),
      confirmCallback: (_) async {
        final i10n = FlutterHeyteacherE2EELocalizations.of(context)!;
        // split - trim each line - jon
        // the only way to remove special chars in Copy & Paste
        // from a rich text editor (Word, Writer)
        secretJwkJson = secretJwkJson!.split('\n').map((e) => e.trim()).join();
        await E2EEViewModel.instance(
          AuthViewModel.instance.uid,
        ).importSecretJwkJson(
          secretJwkJson!,
        );
        if (mounted) setState(() {});
        widget._secretKeyImportedCallback?.call();
        return i10n.encryptionSecretKeyImported;
      },
      content: TextFormField(
        controller: _secretKeyTextEditingController,
        minLines: 10,
        maxLines: null,
        keyboardType: TextInputType.text,
        onChanged: (value) => secretJwkJson = value,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: ThemeViewModel.instance.colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _showQrCodeScanner() async {
    // get localized confirm question message before async invocation
    final confirmQuestionMessage = FlutterHeyteacherE2EELocalizations.of(
      context,
    )!.areYouSureToImportEncryptionSecretKey;
    _encryptionPassphraseFocusNode.unfocus();
    if (AuthViewModel.instance.notAutenticated) {
      unawaited(
        showConfirmCancelDialog<void>(
          context: context,
          content: Text(
            FlutterHeyteacherAuthLocalizations.of(
              context,
            )!.userNotAuthenticated,
          ),
        ),
      );
      return;
    }
    String? secretJwkJson;
    await showDialog<bool>(
      context: context,
      builder: (context) => Stack(
        alignment: Alignment.bottomCenter,
        children: [
          MobileScanner(
            onDetect: (barcodeCapture) {
              if (barcodeCapture
                      .barcodes
                      .firstOrNull
                      ?.displayValue
                      ?.isNotEmpty ??
                  false) {
                secretJwkJson = barcodeCapture.barcodes.first.displayValue;
                Navigator.of(context).pop(true);
              }
            },
            overlayBuilder: (context, constraints) =>
                const Icon(Icons.qr_code_scanner, size: 180),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            iconSize: 120,
            color: ThemeViewModel.instance.redColor,
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
    );
    if (secretJwkJson != null) {
      unawaited(
        showConfirmCancelDialog<void>(
          context: context.mounted ? context : context,
          content: Text(confirmQuestionMessage),
          confirmCallback: (_) async {
            // get localized success message before async invocation
            final successMessage = FlutterHeyteacherE2EELocalizations.of(
              context,
            )!.encryptionSecretKeyImported;
            await E2EEViewModel.instance(
              AuthViewModel.instance.uid,
            ).importSecretJwkJson(secretJwkJson!);
            setState(() {});
            widget._secretKeyImportedCallback?.call();
            return successMessage;
          },
        ),
      );
    }
  }
}
