import 'package:intl/intl.dart';

/// Will remove special characters from a string and replace them with "_"
String makeFilenameSafe(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9\.]'), '_');
}

/// Remove \, ' and " from string
String escapeString(String input) {
  input = input.replaceAll('\\', ''); // Escape backslashes
  input = input.replaceAll("'", ""); // Escape single quotes
  input = input.replaceAll('"', ''); // Escape double quotes
  return input;
}

/// Converts dates to d MMMM y
String formatDateToString(DateTime dateTime) {
  final DateFormat formatter = DateFormat('d MMMM y');
  final String formattedDate = formatter.format(dateTime);
  return formattedDate;
}

/// Convert a duration to "$duration seconds/minutes/hours/days"
String formatDurationToWords(Duration dur) {
  if (dur.inSeconds < 60) {
    return "${dur.inSeconds} seconds";
  }

  if (dur.inMinutes < 60) {
    return "${dur.inMinutes} minutes";
  }

  if (dur.inHours < 24) {
    return "${dur.inHours} hours";
  }

  return "${dur.inDays} days";
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}

/// Generate a tag url, `/tag/value/`
String generateTagUrl(String name) => '/tag/$name/';

/// Return the value of an enum as a string
String enumToString(Object enumValue) {
  return enumValue.toString().split('.').last;
}
