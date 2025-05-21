import 'package:logger/logger.dart';

class AlwaysLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Log everything regardless of level or build mode
    return true;
  }
}
