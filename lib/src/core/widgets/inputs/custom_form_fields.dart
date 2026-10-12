import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:flutter/material.dart';

/// Piezas de formulario del rediseño: etiqueta arriba, fondo oscuro
/// translúcido, borde sutil y acento en foco.

Color formFieldFill() => Colors.white.withValues(alpha: 0.04);

Color formFieldBorder() => Colors.white.withValues(alpha: 0.08);

TextStyle formInputStyle({bool muted = false}) => TextStyle(
  color: muted ? Colors.white70 : whiteColor(),
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

InputDecoration formInputDecoration({
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: formFieldFill(),
    hintText: hint,
    hintStyle: TextStyle(
      color: grayInputColor(),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    errorStyle: const TextStyle(fontSize: 11),
    errorMaxLines: 2,
    prefixIcon:
        prefixIcon == null
            ? null
            : Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: prefixIcon,
            ),
    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    suffixIcon:
        suffixIcon == null
            ? null
            : Padding(
              padding: const EdgeInsets.only(right: 14),
              child: suffixIcon,
            ),
    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
    enabledBorder: border(formFieldBorder()),
    disabledBorder: border(formFieldBorder()),
    focusedBorder: border(accentColor(), 1.5),
    errorBorder: border(errorColor()),
    focusedErrorBorder: border(errorColor(), 1.5),
  );
}

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Campo de selección con el mismo aspecto que [formInputDecoration].
/// Si [onTap] es null queda deshabilitado (ícono gris).
class FormSelectField extends StatelessWidget {
  final String label;
  final Widget? leading;
  final bool isPlaceholder;
  final String? errorText;
  final VoidCallback? onTap;
  final IconData trailingIcon;

  const FormSelectField({
    super.key,
    required this.label,
    this.leading,
    this.isPlaceholder = false,
    this.errorText,
    this.onTap,
    this.trailingIcon = Icons.keyboard_arrow_down,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
              decoration: BoxDecoration(
                color: formFieldFill(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError ? errorColor() : formFieldBorder(),
                ),
              ),
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          isPlaceholder
                              ? TextStyle(color: grayInputColor(), fontSize: 15)
                              : formInputStyle(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    trailingIcon,
                    size: 22,
                    color: onTap == null ? grayInputColor() : accentColor(),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText!,
              style: TextStyle(color: errorColor(), fontSize: 11),
            ),
          ),
      ],
    );
  }
}

class FormPickerOption {
  final String id;
  final String label;
  final IconData? icon;
  final String? leadingText;

  const FormPickerOption({
    required this.id,
    required this.label,
    this.icon,
    this.leadingText,
  });
}

/// Hoja inferior para elegir una opción, con buscador opcional.
Future<void> showFormOptionsPicker({
  required BuildContext context,
  required String title,
  required List<FormPickerOption> options,
  required String? selectedId,
  required ValueChanged<String> onSelected,
  bool searchable = false,
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => _FormOptionsPickerSheet(
          title: title,
          options: options,
          selectedId: selectedId,
          searchable: searchable,
          onSelected: onSelected,
        ),
  );
}

class _FormOptionsPickerSheet extends StatefulWidget {
  final String title;
  final List<FormPickerOption> options;
  final String? selectedId;
  final bool searchable;
  final ValueChanged<String> onSelected;

  const _FormOptionsPickerSheet({
    required this.title,
    required this.options,
    required this.selectedId,
    required this.searchable,
    required this.onSelected,
  });

  @override
  State<_FormOptionsPickerSheet> createState() =>
      _FormOptionsPickerSheetState();
}

class _FormOptionsPickerSheetState extends State<_FormOptionsPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final query = _query.trim().toLowerCase();
    final visible =
        query.isEmpty
            ? widget.options
            : widget.options
                .where((o) => o.label.toLowerCase().contains(query))
                .toList();

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      decoration: BoxDecoration(
        color: primaryColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Material propio: sin él, el fondo del Container tapa los fondos y
      // efectos de toque que ListTile pinta sobre el Material del sheet.
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: whiteColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.searchable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: TextField(
                    onChanged: (value) => setState(() => _query = value),
                    cursorColor: accentColor(),
                    style: formInputStyle(),
                    decoration: formInputDecoration(
                      hint: 'Buscar',
                      prefixIcon: Icon(Icons.search, color: grayInputColor()),
                    ),
                  ),
                ),
              Flexible(
                child:
                    visible.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No se encontraron resultados',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: grayInputColor()),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: visible.length,
                          itemBuilder: (_, index) {
                            final option = visible[index];
                            final selected = option.id == widget.selectedId;
                            final leadingText = option.leadingText ?? '';

                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              tileColor:
                                  selected
                                      ? accentColor().withValues(alpha: 0.1)
                                      : null,
                              leading:
                                  option.icon != null
                                      ? Icon(option.icon, color: accentColor())
                                      : leadingText.isNotEmpty
                                      ? Text(
                                        leadingText,
                                        style: const TextStyle(fontSize: 22),
                                      )
                                      : null,
                              title: Text(
                                option.label,
                                style: TextStyle(
                                  color: whiteColor(),
                                  fontSize: 15,
                                  fontWeight:
                                      selected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                ),
                              ),
                              trailing:
                                  selected
                                      ? Icon(Icons.check, color: accentColor())
                                      : null,
                              onTap: () {
                                widget.onSelected(option.id);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
