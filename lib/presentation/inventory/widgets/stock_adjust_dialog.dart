import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/product.dart';

class StockAdjustDialog extends StatefulWidget {
  final Product product;

  const StockAdjustDialog({super.key, required this.product});

  @override
  State<StockAdjustDialog> createState() => _StockAdjustDialogState();
}

class _StockAdjustDialogState extends State<StockAdjustDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.product.stock}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product.name),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.sku}: ${widget.product.sku}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: AppStrings.stockQuantity,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _adjust(-1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _adjust(1),
                    ),
                  ],
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? AppStrings.stockRequired : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, int.parse(_controller.text));
            }
          },
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }

  void _adjust(int delta) {
    final current = int.tryParse(_controller.text) ?? 0;
    final next = (current + delta).clamp(0, 999999);
    _controller.text = '$next';
  }
}
