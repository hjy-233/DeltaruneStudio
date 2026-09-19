import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'project_character.dart';

class ProjectCharacterBrowser extends StatelessWidget {
  const ProjectCharacterBrowser({
    super.key,
    required this.characters,
    required this.selectedPath,
    required this.onSelected,
    required this.onAdd,
  });

  final List<ProjectCharacterFile> characters;
  final String? selectedPath;
  final ValueChanged<ProjectCharacterFile> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        ListTile(
          title: Text(l10n.charactersTab),
          trailing: IconButton(
            tooltip: l10n.newCharacter,
            onPressed: onAdd,
            icon: const Icon(Icons.add),
          ),
        ),
        Expanded(
          child: characters.isEmpty
              ? Center(child: Text(l10n.noCharacters))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return ListTile(
                      dense: true,
                      selected: selectedPath == character.path,
                      leading: const Icon(Icons.person_outline),
                      title: Text(character.definition.name),
                      subtitle: Text(
                        character.definition.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => onSelected(character),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
