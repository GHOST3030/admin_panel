import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'app_logger.dart';

final loggerProvider = Provider.family<Logger, String>(
  (ref, module) => AppLogger.getLogger(module),
);
