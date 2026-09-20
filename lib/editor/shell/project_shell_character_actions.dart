part of 'project_shell.dart';

extension _ProjectShellCharacterActions on _ProjectShellState {
  Future<void> _newCharacter() async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final name = await _askValue(l10n.newCharacter, l10n.characterDefaultName);
    if (!mounted || name == null || name.trim().isEmpty) {
      return;
    }
    await _run(
      () => _repository.addCharacter(document, name),
      preserveActiveRoom: true,
      success: (updated) {
        final created = updated.characters.firstWhere(
          (item) => !document.characters.any(
            (existing) => existing.path == item.path,
          ),
        );
        _selectedCharacterPath = created.path;
        _selectedAssetPath = null;
        _selectedRoomPath = null;
        _selectedObjectId = null;
        return l10n.characterCreated(created.definition.name);
      },
    );
  }

  void _selectCharacter(ProjectCharacterFile character) {
    _selectCharacterState(character);
  }

  Future<void> _saveCharacter(ProjectCharacterFile character) async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await _run(
      () => _repository.saveCharacter(document, character),
      preserveActiveRoom: true,
      success: (_) {
        _selectedCharacterPath = character.path;
        return l10n.characterSaved;
      },
    );
  }

  Future<void> _deleteCharacter(ProjectCharacterFile character) async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(
      l10n.deleteQuestion(character.definition.name),
    );
    if (!mounted || confirmed != true) {
      return;
    }
    await _run(
      () => _repository.deleteCharacter(document, character),
      preserveActiveRoom: true,
      success: (_) {
        _selectedCharacterPath = null;
        return l10n.characterDeleted;
      },
    );
  }
}
