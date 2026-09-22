import 'package:deltarune_studio/domain/project_character.dart';
import 'package:deltarune_studio/domain/project_content.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:flutter/material.dart';

class ProjectInteractionInspector extends StatelessWidget {
  const ProjectInteractionInspector({
    super.key,
    required this.object,
    required this.onChanged,
  });

  final ProjectSceneObject object;
  final ValueChanged<ProjectSceneObject> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = ProjectFeatureStrings.of(context);
    final interaction = object.interaction;
    return SizedBox(
      width: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpansionTile(
            initiallyExpanded: interaction.enabled,
            tilePadding: EdgeInsets.zero,
            title: Text(strings.interaction),
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.interaction),
                value: interaction.enabled,
                onChanged: (value) =>
                    _interaction(interaction.copyWith(enabled: value)),
              ),
              if (interaction.enabled)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _numberField(
                      strings.interactionDistance,
                      interaction.distance,
                      (value) =>
                          _interaction(interaction.copyWith(distance: value)),
                    ),
                    _textField(
                      strings.interactionPrompt,
                      interaction.prompt,
                      (value) =>
                          _interaction(interaction.copyWith(prompt: value)),
                    ),
                    _textField(
                      strings.interactionFunction,
                      interaction.functionName,
                      (value) => _interaction(
                        interaction.copyWith(functionName: value),
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.interactionOnce),
                        value: interaction.once,
                        onChanged: (value) => _interaction(
                          interaction.copyWith(once: value ?? false),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.requireFacing),
                        value: interaction.requireFacing,
                        onChanged: (value) => _interaction(
                          interaction.copyWith(requireFacing: value ?? false),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (object.type != 'background') _collision(context),
        ],
      ),
    );
  }

  Widget _collision(BuildContext context) {
    final strings = ProjectFeatureStrings.of(context);
    final collision = object.collision;
    if (collision == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => onChanged(
            object.copyWith(
              collision: const ProjectCollisionBox(
                x: -16,
                y: -16,
                width: 32,
                height: 32,
              ),
            ),
          ),
          icon: const Icon(Icons.crop_square),
          label: Text(strings.objectCollision),
        ),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        Text(strings.objectCollision),
        _numberField('X', collision.x, (value) {
          _collisionChanged(collision.copyWith(x: value));
        }),
        _numberField('Y', collision.y, (value) {
          _collisionChanged(collision.copyWith(y: value));
        }),
        _numberField('W', collision.width, (value) {
          _collisionChanged(collision.copyWith(width: value));
        }),
        _numberField('H', collision.height, (value) {
          _collisionChanged(collision.copyWith(height: value));
        }),
        IconButton(
          tooltip: strings.erase,
          onPressed: () => onChanged(object.copyWith(clearCollision: true)),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  Widget _textField(
    String label,
    String value,
    ValueChanged<String> onSubmitted,
  ) {
    return SizedBox(
      width: 220,
      child: TextFormField(
        key: ValueKey('$label:$value'),
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        onFieldSubmitted: onSubmitted,
      ),
    );
  }

  Widget _numberField(
    String label,
    double value,
    ValueChanged<double> onSubmitted,
  ) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        key: ValueKey('$label:$value'),
        initialValue: value.toStringAsFixed(1),
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onFieldSubmitted: (text) {
          final parsed = double.tryParse(text);
          if (parsed != null) onSubmitted(parsed);
        },
      ),
    );
  }

  void _interaction(ProjectInteraction interaction) {
    onChanged(object.copyWith(interaction: interaction));
  }

  void _collisionChanged(ProjectCollisionBox collision) {
    onChanged(object.copyWith(collision: collision));
  }
}
