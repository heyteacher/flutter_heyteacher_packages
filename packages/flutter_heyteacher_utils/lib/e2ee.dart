/// Provides End-to-End Encryption (E2EE) capabilities using AES-GCM.
///
/// This library manages the generation, secure storage, import, and export
/// of cryptographic keys. It leverages `flutter_secure_storage` for key persistence
/// and `webcrypto` for cryptographic operations.
///
/// Key features:
/// - AES-GCM for authenticated encryption.
/// - Secure storage of the user's secret key.
/// - Use of Additional Authenticated Data (AAD), often a user-provided passphrase.
/// - Export/import of the secret key, itself encrypted with a master key (e.g., from Remote Config).
/// - Custom exceptions for specific E2EE-related errors.
library;

export 'src/e2ee.dart'
    show
        E2EEViewModel,
        E2EEPassphraseCard,
        E2EESecretKeyCard,
        E2EEValue,
        AADEmptyException,
        MissingEncryptionSecretKeyException;
