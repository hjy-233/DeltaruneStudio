class RecentProjectsStore {
  static final List<String> _paths = [];

  Future<List<String>> load() async => List<String>.from(_paths);

  Future<void> save(List<String> paths) async {
    _paths
      ..clear()
      ..addAll(paths);
  }
}
