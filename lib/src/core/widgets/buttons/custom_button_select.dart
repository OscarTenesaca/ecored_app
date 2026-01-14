import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:flutter/material.dart';

class CustomButtonSelect extends StatelessWidget {
  final ValueNotifier<Map<String, String>?> selectNotifier;
  final List<Map<String, String>> optionsList;
  final String title;
  final Color backgroundColor;
  final Color textColor;

  const CustomButtonSelect({
    super.key,
    required this.selectNotifier,
    required this.optionsList,
    this.title = 'Seleccionar opción',
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, String>?>(
      valueListenable: selectNotifier,
      builder: (context, value, _) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
          onPressed: () => _openSelect(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  value?['label'] ?? title,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
    );
  }

  void _openSelect(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return _SelectBottomSheet(
          options: optionsList,
          onSelected: (value) {
            selectNotifier.value = value;
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _SelectBottomSheet extends StatefulWidget {
  final List<Map<String, String>> options;
  final ValueChanged<Map<String, String>> onSelected;

  const _SelectBottomSheet({required this.options, required this.onSelected});

  @override
  State<_SelectBottomSheet> createState() => _SelectBottomSheetState();
}

class _SelectBottomSheetState extends State<_SelectBottomSheet> {
  late List<Map<String, String>> filteredOptions;

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
  }

  void _filter(String value) {
    setState(() {
      filteredOptions =
          widget.options
              .where(
                (e) =>
                    e['label']!.toLowerCase().contains(value.toLowerCase()) ||
                    e['key']!.toLowerCase().contains(value.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: _filter,
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: UtilSize.height(context) * 0.7,
              child: ListView.builder(
                itemCount: filteredOptions.length,
                itemBuilder: (_, index) {
                  final item = filteredOptions[index];
                  return ListTile(
                    title: Text('${item['label']}'),
                    onTap: () => widget.onSelected(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
