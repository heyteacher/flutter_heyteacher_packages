import 'package:intl/intl.dart';

final DateFormat firestorKeyDateTimeFormatter = DateFormat("yyyyMMdd_HHmmss");

final DateFormat dateTimeFormatter = DateFormat("dd/MM/yyyy HH:mm");

final DateFormat timeWithSecondsFormatter = DateFormat("HH:mm:ss");

final NumberFormat intFormatter = NumberFormat("0");

final NumberFormat doubleFormatter = NumberFormat("0.0");

//AppLocalizations.of(ContextHelper.context)!.nHours(duration.inHours)
//AppLocalizations.of(ContextHelper.context)!.nMinutes
String formatDurationTts(num? milliseconds, Function(int) nHours, Function(int) nMinutes) {
  if (milliseconds != null) {
    Duration duration = Duration(milliseconds: milliseconds.toInt());
    return ""
        "${duration.inHours >= 0 ? nHours(duration.inHours):""}"
        "${nMinutes(duration.inMinutes - (duration.inHours * 60))}";
  } else {
    return "";
  }
}

/// formats [milliseconds] from Epoc in readable duration.
/// 
/// If [showHoursIfZero] is true, hours are always showed hh:mm;\[ss\], otherwise duration less then one hour 
/// are showed inn mm:\[ss\].
/// If [showSeconds] is true, the format is \[hh\]:mm:ss, otherwise \[hh\]:mm:\[ss\].
///  If [milliseconds] is null, an empty string is returned
String formatDuration(num? milliseconds, {bool showSeconds = false, bool showHoursIfZero = true}) {
  if (milliseconds != null) {
    Duration duration = Duration(milliseconds: milliseconds.toInt());
    NumberFormat numberFormat = NumberFormat("00");
    return ""
        "${showHoursIfZero || duration.inHours != 0?"${numberFormat.format(duration.inHours)}:":""}"
        "${numberFormat.format(duration.inMinutes - (duration.inHours * 60))}"
        "${showSeconds ? ":${numberFormat.format(duration.inSeconds - (duration.inMinutes * 60))}" : ""}";
  } else {
    return "";
  }
}
