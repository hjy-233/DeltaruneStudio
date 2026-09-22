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

class GodotPackedFile {
  const GodotPackedFile({required this.path, required this.bytes});

  final String path;
  final int bytes;
}

class GodotExportPreflight {
  const GodotExportPreflight({
    required this.files,
    required this.missingResources,
    required this.unsupportedFiles,
  });

  final List<GodotPackedFile> files;
  final List<String> missingResources;
  final List<String> unsupportedFiles;

  int get totalBytes => files.fold(0, (sum, file) => sum + file.bytes);
  bool get hasBlockingErrors => missingResources.isNotEmpty;
}
