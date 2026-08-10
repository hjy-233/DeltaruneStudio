import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InspectorStringField extends StatefulWidget {
  const InspectorStringField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    super.key,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  State<InspectorStringField> createState() => _InspectorStringFieldState();
}

class _InspectorStringFieldState extends State<InspectorStringField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant InspectorStringField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.selection.isValid && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: widget.maxLines,
      decoration: InputDecoration(labelText: widget.label),
      onChanged: widget.onChanged,
      onSubmitted: widget.onChanged,
      onEditingComplete: () => widget.onChanged(_controller.text),
    );
  }
}

class InspectorNumberField extends StatefulWidget {
  const InspectorNumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<InspectorNumberField> createState() => _InspectorNumberFieldState();
}

class _InspectorNumberFieldState extends State<InspectorNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
  }

  @override
  void didUpdateWidget(covariant InspectorNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.value.toStringAsFixed(1);
    if (!_controller.selection.isValid && _controller.text != next) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(labelText: widget.label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      onChanged: _submit,
      onSubmitted: _submit,
      onEditingComplete: () => _submit(_controller.text),
    );
  }

  void _submit(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      widget.onChanged(parsed);
    }
  }
}

class InspectorInfo extends StatelessWidget {
  const InspectorInfo({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class InspectorSectionTitle extends StatelessWidget {
  const InspectorSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
