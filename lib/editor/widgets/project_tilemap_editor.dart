import 'dart:io';

import 'package:deltarune_studio/domain/project_content.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:flutter/material.dart';

class ProjectTileMapEditor extends StatefulWidget {
  const ProjectTileMapEditor({
    super.key,
    required this.document,
    required this.scene,
  });

  final ProjectDocument document;
  final ProjectScene scene;

  @override
  State<ProjectTileMapEditor> createState() => _ProjectTileMapEditorState();
}

class _ProjectTileMapEditorState extends State<ProjectTileMapEditor> {
  late ProjectTileMap _tileMap = widget.scene.tileMap;
  String _kind = 'ground';
  String _asset = '';

  List<ProjectAsset> get _visualAssets => widget.document.assets
      .where((asset) => const ['backgrounds', 'props'].contains(asset.type))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    if (_visualAssets.isNotEmpty) _asset = _visualAssets.first.path;
  }

  @override
  Widget build(BuildContext context) {
    final strings = ProjectFeatureStrings.of(context);
    final game = widget.document.manifest.gameSettings;
    return Dialog(
      child: SizedBox(
        width: 980,
        height: 720,
        child: Column(
          children: [
            _toolbar(strings),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: game.viewportWidth / game.viewportHeight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = constraints.maxWidth / game.viewportWidth;
                      return _TileCanvas(
                        projectPath: widget.document.path,
                        scene: widget.scene,
                        tileMap: _tileMap,
                        scale: scale,
                        onPaint: _paintAt,
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      widget.scene.copyWith(tileMap: _tileMap),
                    ),
                    child: Text(strings.apply),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(ProjectFeatureStrings strings) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(strings.tileMap, style: Theme.of(context).textTheme.titleLarge),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'ground', label: Text(strings.ground)),
              ButtonSegment(value: 'wall', label: Text(strings.wall)),
              ButtonSegment(value: 'collision', label: Text(strings.collision)),
              ButtonSegment(value: 'erase', label: Text(strings.erase)),
            ],
            selected: {_kind},
            onSelectionChanged: (value) => setState(() => _kind = value.first),
          ),
          if (_kind == 'ground' || _kind == 'wall')
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                initialValue: _visualAssets.any((item) => item.path == _asset)
                    ? _asset
                    : null,
                decoration: InputDecoration(labelText: strings.tileResource),
                items: [
                  for (final asset in _visualAssets)
                    DropdownMenuItem(
                      value: asset.path,
                      child: Text(asset.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _asset = value ?? ''),
              ),
            ),
          _numberField(
            strings.tileWidth,
            _tileMap.tileWidth,
            (value) => _tileMap = _tileMap.copyWith(tileWidth: value),
          ),
          _numberField(
            strings.tileHeight,
            _tileMap.tileHeight,
            (value) => _tileMap = _tileMap.copyWith(tileHeight: value),
          ),
        ],
      ),
    );
  }

  Widget _numberField(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        key: ValueKey('$label:$value'),
        initialValue: value.toStringAsFixed(0),
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onFieldSubmitted: (text) {
          final parsed = double.tryParse(text);
          if (parsed != null && parsed >= 4) setState(() => onChanged(parsed));
        },
      ),
    );
  }

  void _paintAt(Offset point) {
    final column = (point.dx / _tileMap.tileWidth).floor();
    final row = (point.dy / _tileMap.tileHeight).floor();
    final cells = _tileMap.cells.where((cell) {
      if (cell.column != column || cell.row != row) return true;
      if (_kind == 'erase') return false;
      return _kind == 'collision'
          ? cell.kind != 'collision'
          : cell.kind == 'collision';
    }).toList();
    if (_kind != 'erase' && (_kind == 'collision' || _asset.isNotEmpty)) {
      cells.add(
        ProjectTileCell(
          column: column,
          row: row,
          kind: _kind,
          asset: _kind == 'collision' ? '' : _asset,
        ),
      );
    }
    setState(() => _tileMap = _tileMap.copyWith(cells: cells));
  }
}

class _TileCanvas extends StatelessWidget {
  const _TileCanvas({
    required this.projectPath,
    required this.scene,
    required this.tileMap,
    required this.scale,
    required this.onPaint,
  });

  final String projectPath;
  final ProjectScene scene;
  final ProjectTileMap tileMap;
  final double scale;
  final ValueChanged<Offset> onPaint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => onPaint(details.localPosition / scale),
      onPanStart: (details) => onPaint(details.localPosition / scale),
      onPanUpdate: (details) => onPaint(details.localPosition / scale),
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          children: [
            if (scene.background != null)
              Positioned.fill(
                child: Image.file(
                  File('$projectPath/${scene.background}'),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
            for (final cell in tileMap.cells) _cell(cell),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GridPainter(
                    tileWidth: tileMap.tileWidth * scale,
                    tileHeight: tileMap.tileHeight * scale,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(ProjectTileCell cell) {
    final left = cell.column * tileMap.tileWidth * scale;
    final top = cell.row * tileMap.tileHeight * scale;
    final width = tileMap.tileWidth * scale;
    final height = tileMap.tileHeight * scale;
    if (cell.kind == 'collision') {
      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: ColoredBox(color: Colors.cyan.withValues(alpha: 0.35)),
      );
    }
    final file = File('$projectPath/${cell.asset}');
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: file.existsSync()
          ? Image.file(
              file,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            )
          : const ColoredBox(color: Colors.red),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.tileWidth, required this.tileHeight});

  final double tileWidth;
  final double tileHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += tileWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += tileHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return tileWidth != oldDelegate.tileWidth ||
        tileHeight != oldDelegate.tileHeight;
  }
}
