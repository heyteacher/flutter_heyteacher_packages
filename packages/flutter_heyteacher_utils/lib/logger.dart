library;

/// Provides UI components and a model for viewing and managing application logs.
///
/// Key features include:
/// - [LoggerScreen]: A dedicated screen to display and filter log messages.
/// - [LoggerListTile]: A convenient [ListTile] for navigating to the [LoggerScreen].
/// - [LoggingRouter]: Defines the routing for the logger UI.
/// - [LoggerModel]: Handles log capture, configuration (including level setting via
///   Firebase Remote Config), in-memory storage, and forwarding of structured logs
///   to Firebase Analytics.

export 'src/logger.dart'
    show LoggerViewModel, LoggerScreen, LoggerCard, LoggingRouter;
