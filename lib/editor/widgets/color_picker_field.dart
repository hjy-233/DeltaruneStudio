import 'package:flutter/material.dart';

class ColorPickerField extends StatelessWidget {
  const ColorPickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(value) ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDialog<String>(
              context: context,
              builder: (context) => _ColorPickerDialog(initialValue: value),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const SizedBox(width: 28, height: 20),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(formatHexColor(color))),
              const Icon(Icons.colorize, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _color = parseHexColor(widget.initialValue) ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择颜色'),
      content: SizedBox(
        width: 280,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in _palette)
              _ColorSwatchButton(
                color: color,
                selected: color.toARGB32() == _color.toARGB32(),
                onTap: () => setState(() => _color = color),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(formatHexColor(_color)),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const SizedBox(width: 34, height: 28),
      ),
    );
  }
}

Color? parseHexColor(String value) {
  final normalized = value.trim().replaceFirst('#', '');
  if (normalized.length != 6 && normalized.length != 8) {
    return null;
  }
  final parsed = int.tryParse(
    normalized.length == 6 ? 'FF$normalized' : normalized,
    radix: 16,
  );
  return parsed == null ? null : Color(parsed);
}

String formatHexColor(Color color) {
  final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${value.toUpperCase()}';
}

const _palette = [
  Color(0xFF000000),
  Color(0xFFFFFFFF),
  Color(0xFFFF4D3D),
  Color(0xFFFFC24A),
  Color(0xFF66D36E),
  Color(0xFF55B8FF),
  Color(0xFF9B6DFF),
  Color(0xFFFF70B8),
  Color(0xCC000000),
  Color(0xAAFFFFFF),
  Color(0xCCFF4D3D),
  Color(0xCCFFC24A),
  Color(0xCC66D36E),
  Color(0xCC55B8FF),
  Color(0xCC9B6DFF),
  Color(0xCCFF70B8),
];
