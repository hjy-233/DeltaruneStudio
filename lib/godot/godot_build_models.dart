enum GodotExportTarget {
  macOS('macOS', 'zip'),
  windows('Windows Desktop', 'exe'),
  linux('Linux/X11', 'x86_64');

  const GodotExportTarget(this.preset, this.extension);

  final String preset;
  final String extension;
}

abstract class GodotRunSession {
  Stream<String> get output;
  Future<int> get exitCode;
  Future<void> stop();
}
