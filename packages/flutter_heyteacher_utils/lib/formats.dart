import 'package:intl/intl.dart';

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

String formatDuration(num? milliseconds, {bool showSeconds = false}) {
  if (milliseconds != null) {
    Duration duration = Duration(milliseconds: milliseconds.toInt());
    NumberFormat numberFormat = NumberFormat("00");
    return ""
        "${numberFormat.format(duration.inHours)}:"
        "${numberFormat.format(duration.inMinutes - (duration.inHours * 60))}"
        "${showSeconds ? ":${numberFormat.format(duration.inSeconds - (duration.inMinutes * 60))}" : ""}";
  } else {
    return "";
  }
}
