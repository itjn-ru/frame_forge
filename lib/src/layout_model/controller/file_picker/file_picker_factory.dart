// Conditional imports for different platforms
import 'file_picker_service.dart';

// Use conditional imports to select the right implementation
import 'web_file_picker_service.dart'
    if (dart.library.io) 'mobile_file_picker_service.dart'
    as platform_service;

/// Factory to get the appropriate file picker service for current platform
FilePickerService createFilePickerService() {
  // This will automatically resolve to the correct implementation
  // WebFilePickerService on web, MobileFilePickerService on mobile/desktop
  return platform_service.createService();
}
