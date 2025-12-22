## 1.1.0

* **BREAKING CHANGE**: Restructured as proper Flutter plugin with automatic registration
* Plugin now auto-registers - no manual MainActivity/AppDelegate changes needed
* Fixed issue where camera, gallery, and document picker wouldn't open in other projects
* Proper plugin structure with platform channels declared in pubspec.yaml
* Native code moved to proper plugin directories (android/src/main, ios/Classes)
* Updated documentation with proper installation instructions
* Added FileProvider configuration instructions for Android
* Improved plugin registration reliability

## 1.0.0

* Initial release
* Camera image picking
* Gallery image picking
* Document file picking (PDF, DOC, DOCX, etc.)
* Audio recording with duration tracking
* Unified bottom sheet UI
* Single Attachment model for all types

