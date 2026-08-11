part of 'inspector_panel.dart';

class _FocusEditor extends StatelessWidget {
  const _FocusEditor({required this.focus, required this.onChanged});

  final CameraFocusEvent focus;
  final ValueChanged<CameraFocusEvent> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        InspectorNumberField(
          label: l10n.duration,
          value: focus.duration,
          onChanged: (duration) =>
              onChanged(focus.copyWith(duration: duration)),
        ),
        InspectorNumberField(
          label: l10n.pointX,
          value: focus.target.maybeMap(
            point: (point) => point.x,
            orElse: () => 0,
          ),
          onChanged: (x) => onChanged(
            focus.copyWith(
              target: FocusTarget.point(
                x: x,
                y: focus.target.maybeMap(
                  point: (point) => point.y,
                  orElse: () => 0,
                ),
              ),
            ),
          ),
        ),
        InspectorNumberField(
          label: l10n.pointY,
          value: focus.target.maybeMap(
            point: (point) => point.y,
            orElse: () => 0,
          ),
          onChanged: (y) => onChanged(
            focus.copyWith(
              target: FocusTarget.point(
                x: focus.target.maybeMap(
                  point: (point) => point.x,
                  orElse: () => 0,
                ),
                y: y,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpressionPicker extends StatelessWidget {
  const _ExpressionPicker({
    required this.ready,
    required this.characterObjectId,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final StudioReady ready;
  final String characterObjectId;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final object = ready.objectById(characterObjectId);
    final characterId = object is CharacterInstanceObject
        ? object.characterId
        : null;
    final character = ready.characterById(characterId);
    final expressions = character?.expressions ?? const <CharacterExpression>[];
    return _DropdownField<String>(
      label: label,
      value: value,
      values: expressions.map((expression) => expression.id).toList(),
      labelFor: (id) =>
          expressions
              .where((expression) => expression.id == id)
              .firstOrNull
              ?.name ??
          id,
      onChanged: onChanged,
    );
  }
}

class _TransformEditor extends StatelessWidget {
  const _TransformEditor({required this.transform, required this.onChanged});

  final Transform2D transform;
  final ValueChanged<Transform2D> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(l10n.advancedPosition),
      children: [
        Row(
          children: [
            Expanded(
              child: InspectorNumberField(
                label: 'X',
                value: transform.x,
                onChanged: (x) => onChanged(transform.copyWith(x: x)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InspectorNumberField(
                label: 'Y',
                value: transform.y,
                onChanged: (y) => onChanged(transform.copyWith(y: y)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: InspectorNumberField(
                label: l10n.width,
                value: transform.width,
                onChanged: (width) =>
                    onChanged(transform.copyWith(width: width)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InspectorNumberField(
                label: l10n.height,
                value: transform.height,
                onChanged: (height) =>
                    onChanged(transform.copyWith(height: height)),
              ),
            ),
          ],
        ),
        InspectorNumberField(
          label: l10n.scale,
          value: transform.scale,
          onChanged: (scale) => onChanged(transform.copyWith(scale: scale)),
        ),
      ],
    );
  }
}

class _ObjectPicker extends StatelessWidget {
  const _ObjectPicker({
    required this.ready,
    required this.label,
    required this.value,
    required this.onChanged,
    this.characterOnly = false,
  });

  final StudioReady ready;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool characterOnly;

  @override
  Widget build(BuildContext context) {
    final objects = ready.currentScene.objects.where((object) {
      return !characterOnly || object is CharacterInstanceObject;
    }).toList();
    return _DropdownField<String>(
      label: label,
      value: value,
      values: objects.map((object) => object.objectId).toList(),
      labelFor: (id) =>
          ready
              .objectById(id)
              ?.map(
                characterInstance: (value) => value.name,
                prop: (value) => value.name,
                background: (value) => value.name,
                triggerPoint: (value) => value.name,
                triggerArea: (value) => value.name,
              ) ??
          id,
      onChanged: onChanged,
    );
  }
}

class _AudioEventEditor extends ConsumerWidget {
  const _AudioEventEditor({
    required this.ready,
    required this.assetId,
    required this.isBgm,
    required this.onChanged,
  });

  final StudioReady ready;
  final String assetId;
  final bool isBgm;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AssetPicker(
          ready: ready,
          kind: AssetKind.audio,
          value: assetId,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: assetId.isEmpty
              ? null
              : () => ref
                    .read(previewControllerProvider.notifier)
                    .previewAudioAsset(ready, assetId, bgm: isBgm),
          icon: const Icon(Icons.volume_up),
          label: Text(l10n.play),
        ),
      ],
    );
  }
}

class _AssetPicker extends StatelessWidget {
  const _AssetPicker({
    required this.ready,
    required this.kind,
    required this.value,
    required this.onChanged,
  });

  final StudioReady ready;
  final AssetKind kind;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assets = ready.project.assets
        .where((asset) => asset.kind == kind)
        .map((asset) => asset.id)
        .toList();
    if (value.isEmpty) {
      assets.insert(0, '');
    }
    if (!assets.contains(value) && value.isNotEmpty) {
      assets.add(value);
    }
    return _DropdownField<String>(
      label: l10n.asset,
      value: value,
      values: assets,
      labelFor: (id) => id.isEmpty
          ? l10n.builtIn
          : ready.assetById(id)?.originalName ?? l10n.missingAsset,
      onChanged: onChanged,
    );
  }
}

class _DialoguePortraitPicker extends ConsumerStatefulWidget {
  const _DialoguePortraitPicker({
    required this.ready,
    required this.value,
    required this.onChanged,
  });

  final StudioReady ready;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  ConsumerState<_DialoguePortraitPicker> createState() =>
      _DialoguePortraitPickerState();
}

class _DialoguePortraitPickerState
    extends ConsumerState<_DialoguePortraitPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = _query.trim().toLowerCase();
    final importedPortraits = widget.ready.project.assets
        .where((asset) => asset.kind == AssetKind.dialoguePortrait)
        .where((asset) {
          if (normalized.isEmpty) {
            return true;
          }
          return asset.originalName.toLowerCase().contains(normalized) ||
              asset.relativePath.toLowerCase().contains(normalized);
        })
        .toList();
    final selected = widget.ready.assetById(widget.value);
    final builtInLibrary = ref.watch(builtInAssetLibraryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.portrait,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: ref
                  .read(studioControllerProvider.notifier)
                  .importDialoguePortrait,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('导入头像'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: const InputDecoration(
            isDense: true,
            prefixIcon: Icon(Icons.search, size: 18),
            labelText: '搜索对话头像',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 8),
        if (selected != null && widget.value.isNotEmpty)
          InputChip(
            avatar: _AssetTinyPreview(ready: widget.ready, asset: selected),
            label: Text(selected.originalName, overflow: TextOverflow.ellipsis),
            onDeleted: () => widget.onChanged(''),
          )
        else
          Text(l10n.none, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: ListView(
            children: [
              _PortraitGridHeader(
                label: '用户导入',
                count: importedPortraits.length,
              ),
              if (importedPortraits.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '还没有导入头像',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                _ImportedPortraitGrid(
                  ready: widget.ready,
                  portraits: importedPortraits,
                  selectedAssetId: widget.value,
                  onChanged: widget.onChanged,
                ),
              const SizedBox(height: 12),
              builtInLibrary.when(
                data: (library) {
                  final builtIns = _filterBuiltInPortraits(
                    library.assets,
                    normalized,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PortraitGridHeader(
                        label: '内置头像库',
                        count: builtIns.length,
                      ),
                      if (builtIns.isEmpty)
                        Text(
                          '没有匹配的内置头像',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        _BuiltInPortraitGrid(
                          portraits: builtIns.take(240).toList(),
                          onSelected: ref
                              .read(studioControllerProvider.notifier)
                              .addBuiltInAsset,
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(
                  '$error',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<BuiltInAsset> _filterBuiltInPortraits(
    List<BuiltInAsset> assets,
    String normalized,
  ) {
    return assets.where((asset) {
      if (asset.kind != AssetKind.dialoguePortrait ||
          !asset.assetPath.startsWith('assets/dialogue/portraits/')) {
        return false;
      }
      if (normalized.isEmpty) {
        return true;
      }
      return asset.name.toLowerCase().contains(normalized) ||
          asset.sourcePath.toLowerCase().contains(normalized);
    }).toList();
  }
}

class _PortraitGridHeader extends StatelessWidget {
  const _PortraitGridHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label ($count)',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _ImportedPortraitGrid extends StatelessWidget {
  const _ImportedPortraitGrid({
    required this.ready,
    required this.portraits,
    required this.selectedAssetId,
    required this.onChanged,
  });

  final StudioReady ready;
  final List<AssetRef> portraits;
  final String selectedAssetId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: portraits.length,
      itemBuilder: (context, index) {
        final asset = portraits[index];
        return _PortraitTile(
          active: asset.id == selectedAssetId,
          title: asset.originalName,
          image: _AssetPreviewImage(ready: ready, asset: asset),
          onTap: () => onChanged(asset.id),
        );
      },
    );
  }
}

class _BuiltInPortraitGrid extends StatelessWidget {
  const _BuiltInPortraitGrid({
    required this.portraits,
    required this.onSelected,
  });

  final List<BuiltInAsset> portraits;
  final ValueChanged<BuiltInAsset> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: portraits.length,
      itemBuilder: (context, index) {
        final asset = portraits[index];
        return _PortraitTile(
          active: false,
          title: asset.name,
          image: _BuiltInPortraitPreview(asset: asset),
          onTap: () => onSelected(asset),
        );
      },
    );
  }
}

class _PortraitTile extends StatelessWidget {
  const _PortraitTile({
    required this.active,
    required this.title,
    required this.image,
    required this.onTap,
  });

  final bool active;
  final String title;
  final Widget image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(child: image),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuiltInPortraitPreview extends StatelessWidget {
  const _BuiltInPortraitPreview({required this.asset});

  final BuiltInAsset asset;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.asset(
        asset.assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
      );
    }
    return Image.file(
      File(asset.resolvedPath),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
    );
  }
}

class _DialogueSoundPicker extends ConsumerStatefulWidget {
  const _DialogueSoundPicker({
    required this.ready,
    required this.value,
    required this.onChanged,
  });

  final StudioReady ready;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  ConsumerState<_DialogueSoundPicker> createState() =>
      _DialogueSoundPickerState();
}

class _DialogueSoundPickerState extends ConsumerState<_DialogueSoundPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim().toLowerCase();
    final importedSounds = widget.ready.project.assets
        .where((asset) => asset.kind == AssetKind.audio)
        .where((asset) {
          if (normalized.isEmpty) {
            return true;
          }
          return asset.originalName.toLowerCase().contains(normalized) ||
              asset.relativePath.toLowerCase().contains(normalized);
        })
        .toList();
    final selected = widget.ready.assetById(widget.value);
    final builtInLibrary = ref.watch(builtInAssetLibraryProvider);
    final controller = ref.read(studioControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                '打字音效',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: controller.importAudio,
              icon: const Icon(Icons.library_music),
              label: const Text('导入音效'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: const InputDecoration(
            isDense: true,
            prefixIcon: Icon(Icons.search, size: 18),
            labelText: '搜索对话音效',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 8),
        if (widget.value.isNotEmpty)
          InputChip(
            avatar: const Icon(Icons.volume_up, size: 18),
            label: Text(
              selected?.originalName ?? _builtInSoundName(widget.value),
              overflow: TextOverflow.ellipsis,
            ),
            onDeleted: () => widget.onChanged(''),
          )
        else
          Text(
            AppLocalizations.of(context)!.none,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView(
            children: [
              _SoundListHeader(label: '用户导入', count: importedSounds.length),
              for (final asset in importedSounds)
                _SoundTile(
                  title: asset.originalName,
                  subtitle: asset.relativePath,
                  active: asset.id == widget.value,
                  onTap: () => widget.onChanged(asset.id),
                  onPreview: () => ref
                      .read(previewControllerProvider.notifier)
                      .previewAudioAsset(widget.ready, asset.id),
                ),
              if (importedSounds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '还没有导入音效',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              builtInLibrary.when(
                data: (library) {
                  final sounds = _filterDialogueSounds(
                    library.assets,
                    normalized,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SoundListHeader(label: '内置音效库', count: sounds.length),
                      for (final sound in sounds.take(160))
                        _SoundTile(
                          title: sound.name,
                          subtitle: sound.sourcePath,
                          active: sound.id == widget.value,
                          onTap: () => controller.addBuiltInAsset(sound),
                          onPreview: () => ref
                              .read(previewControllerProvider.notifier)
                              .previewAudioAssetId(widget.ready, sound.id),
                        ),
                      if (sounds.isEmpty)
                        Text(
                          '没有匹配的内置音效',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(
                  '$error',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _builtInSoundName(String assetId) {
    final library = ref.read(builtInAssetLibraryProvider).valueOrNull;
    return library?.assets
            .where((asset) => asset.id == assetId)
            .firstOrNull
            ?.name ??
        assetId;
  }

  List<BuiltInAsset> _filterDialogueSounds(
    List<BuiltInAsset> assets,
    String normalized,
  ) {
    return assets.where((asset) {
      if (asset.kind != AssetKind.audio ||
          !asset.assetPath.startsWith('assets/dialogue/sound/')) {
        return false;
      }
      if (normalized.isEmpty) {
        return true;
      }
      return asset.name.toLowerCase().contains(normalized) ||
          asset.sourcePath.toLowerCase().contains(normalized);
    }).toList();
  }
}

class _SoundListHeader extends StatelessWidget {
  const _SoundListHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        '$label ($count)',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  const _SoundTile({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
    required this.onPreview,
  });

  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: active,
      leading: IconButton(
        tooltip: '试听',
        icon: const Icon(Icons.play_arrow),
        onPressed: onPreview,
      ),
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}

class _AssetTinyPreview extends StatelessWidget {
  const _AssetTinyPreview({required this.ready, required this.asset});

  final StudioReady ready;
  final AssetRef asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: _AssetPreviewImage(ready: ready, asset: asset),
    );
  }
}

class _AssetPreviewImage extends StatelessWidget {
  const _AssetPreviewImage({required this.ready, required this.asset});

  final StudioReady ready;
  final AssetRef asset;

  @override
  Widget build(BuildContext context) {
    final dataUri = asset.dataUri;
    if (dataUri != null && dataUri.isNotEmpty) {
      return Image.memory(
        _bytesFromDataUri(dataUri),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
      );
    }
    final directory = ready.projectDirectory;
    if (directory == null) {
      return const Icon(Icons.image);
    }
    final file = File(p.join(directory.path, asset.relativePath));
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image);
    }
    return Image.file(
      file,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
    );
  }
}

Uint8List _bytesFromDataUri(String dataUri) {
  final comma = dataUri.indexOf(',');
  if (comma < 0) {
    return Uint8List(0);
  }
  return base64Decode(dataUri.substring(comma + 1));
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return InspectorInfo(
        label: label,
        value: AppLocalizations.of(context)!.none,
      );
    }
    final actualValue = values.contains(value) ? value : values.first;
    return DropdownButtonFormField<T>(
      initialValue: actualValue,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem<T>(value: item, child: Text(labelFor(item))),
      ],
      onChanged: (next) {
        if (next != null || null is T) {
          onChanged(next as T);
        }
      },
    );
  }
}
