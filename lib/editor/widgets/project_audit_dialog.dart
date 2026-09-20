import 'package:deltarune_studio/domain/project_audit.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ProjectAuditDialog extends StatelessWidget {
  const ProjectAuditDialog({super.key, required this.document});

  final ProjectDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final strings = ProjectFeatureStrings.of(context);
    final issues = auditProject(document).issues;
    return AlertDialog(
      title: Text(strings.resourceAudit),
      content: SizedBox(
        width: 680,
        height: 480,
        child: issues.isEmpty
            ? Center(child: Text(strings.noAuditIssues))
            : ListView.separated(
                itemCount: issues.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return ListTile(
                    leading: Icon(
                      _icon(issue.severity),
                      color: _color(context, issue.severity),
                    ),
                    title: Text(_label(strings, issue.code)),
                    subtitle: Text('${issue.subject}\n${issue.detail}'),
                    isThreeLine: true,
                  );
                },
              ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.ok),
        ),
      ],
    );
  }

  IconData _icon(ProjectAuditSeverity severity) => switch (severity) {
    ProjectAuditSeverity.info => Icons.info_outline,
    ProjectAuditSeverity.warning => Icons.warning_amber_outlined,
    ProjectAuditSeverity.error => Icons.error_outline,
  };

  Color _color(BuildContext context, ProjectAuditSeverity severity) {
    return switch (severity) {
      ProjectAuditSeverity.info => Theme.of(context).colorScheme.secondary,
      ProjectAuditSeverity.warning => Colors.orange,
      ProjectAuditSeverity.error => Theme.of(context).colorScheme.error,
    };
  }

  String _label(ProjectFeatureStrings strings, String code) => switch (code) {
    'unused_resource' => strings.unusedResource,
    'missing_room' => strings.missingRoom,
    'missing_spawn' => strings.missingSpawn,
    _ => strings.missingResource,
  };
}
