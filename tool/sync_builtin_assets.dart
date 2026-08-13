import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  final targetArg = args.isEmpty ? null : args.first;
  if (targetArg == null || targetArg.isEmpty) {
    stderr.writeln('Usage: dart run tool/sync_builtin_assets.dart <target>');
    exitCode = 64;
    return;
  }
  final root = Directory.current;
  final target = Directory(targetArg);
  final lockFile = File('${target.path}.lock');
  await lockFile.parent.create(recursive: true);
  final lock = await lockFile.open(mode: FileMode.write);
  try {
    await lock.lock();
    await target.create(recursive: true);
    await _syncDirectory(
      Directory(p.join(root.path, 'assets', 'builtin')),
      target,
    );
    await _syncDirectory(
      Directory(p.join(root.path, 'assets', 'dialogue', 'portraits')),
      Directory(p.join(target.path, 'dialogue', 'portraits')),
    );
    await _syncDirectory(
      Directory(p.join(root.path, 'assets', 'dialogue', 'sound')),
      Directory(p.join(target.path, 'dialogue', 'sound')),
    );
  } finally {
    await lock.unlock();
    await lock.close();
  }
}

Future<void> _syncDirectory(Directory source, Directory target) async {
  if (!await source.exists()) {
    return;
  }
  if (await target.exists()) {
    await _deleteTree(target);
  }
  await target.create(recursive: true);
  await for (final entity in source.list(recursive: true)) {
    final relative = p.relative(entity.path, from: source.path);
    final destination = p.join(target.path, relative);
    if (entity is Directory) {
      await Directory(destination).create(recursive: true);
    } else if (entity is File) {
      await File(destination).parent.create(recursive: true);
      await entity.copy(destination);
    }
  }
}

Future<void> _deleteTree(Directory directory) async {
  await for (final entity in directory.list(followLinks: false)) {
    if (entity is Directory) {
      await _deleteTree(entity);
    } else {
      await entity.delete();
    }
  }
  await directory.delete();
}
