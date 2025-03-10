import 'package:flutter/widgets.dart';
import 'package:bus_tracking_app/utils/asset_generator.dart';
import 'package:logging/logging.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  final log = Logger('AssetGenerator');
  log.info('Generating assets...');
  await generateAssets();
  log.info('Assets generated successfully!');
} 