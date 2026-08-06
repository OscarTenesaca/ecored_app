import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:flutter/material.dart';

class CustomButtonSelect extends StatelessWidget {
  final ValueNotifier<Map<String, String>?> selectNotifier;
  final List<Map<String, String>> optionsList;
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Color? iconColor;

  const CustomButtonSelect({
    super.key,
    required this.selectNotifier,
    required this.optionsList,
    this.title = 'Seleccionar opción',
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Se construye con un Container + InkWell (no ElevatedButton) para
    // igualar exactamente el mismo look de CustomInput: mismo radio (18),
    // sin borde visible y sin sombra/elevación, en vez de aproximarlo con
    // el estilo por defecto de un botón Material.
    return ValueListenableBuilder<Map<String, String>?>(
      valueListenable: selectNotifier,
      builder: (context, value, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openSelect(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: iconColor ?? textColor, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      value?['label'] ?? title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: textColor),
                ],
              ),
            ),
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
            SizedBox(
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
