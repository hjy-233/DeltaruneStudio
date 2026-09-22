import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:deltarune_studio/godot/godot_build_service.dart';
import 'package:flutter/material.dart';

class ProjectExportPreflightDialog extends StatelessWidget {
  const ProjectExportPreflightDialog({super.key, required this.report});

  final GodotExportPreflight report;

  @override
  Widget build(BuildContext context) {
    final strings = ProjectFeatureStrings.of(context);
    return AlertDialog(
      title: Text(strings.exportPreflight),
      content: SizedBox(
        width: 760,
        height: 560,
        child: ListView(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                report.hasBlockingErrors ? Icons.error_outline : Icons.check,
                color: report.hasBlockingErrors ? Colors.red : Colors.green,
              ),
              title: Text(
                '${strings.estimatedSize}: ${_formatBytes(report.totalBytes)}',
              ),
              subtitle: Text('${report.files.length} files'),
            ),
            _section(
              context,
              strings.missingResource,
              report.missingResources,
              error: true,
            ),
            _section(
              context,
              strings.unsupportedFiles,
              report.unsupportedFiles,
              error: true,
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(strings.packagedFiles),
              children: [
                for (final file in report.files)
                  ListTile(
                    dense: true,
                    title: SelectableText(file.path),
                    trailing: Text(_formatBytes(file.bytes)),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: report.hasBlockingErrors
              ? null
              : () => Navigator.pop(context, true),
          child: Text(strings.continueExport),
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context,
    String title,
    List<String> values, {
    required bool error,
  }) {
    if (values.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      leading: Icon(
        error ? Icons.warning_amber_outlined : Icons.info_outline,
        color: error ? Colors.orange : null,
      ),
      title: Text('$title (${values.length})'),
      children: [
        for (final value in values)
          ListTile(dense: true, title: SelectableText(value)),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}
