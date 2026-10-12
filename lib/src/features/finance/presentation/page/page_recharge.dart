import 'package:ecored_app/src/core/models/location_model.dart';
import 'package:ecored_app/src/core/services/location_service.dart';
import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PageRecharge extends StatefulWidget {
  const PageRecharge({super.key});

  @override
  State<PageRecharge> createState() => _PageRechargeState();
}

class _PageRechargeState extends State<PageRecharge> {
  // Se crea una sola vez: si se armara dentro de build(), cualquier rebuild
  // (p. ej. al mostrar un snackbar) volvería a pedir la recarga.
  Future<_RechargeDetail>? _future;
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _loadData();
  }

  Future<_RechargeDetail> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments as ModelTransaction;
    final provider = context.read<FinanceProvider>();
    final recharge = await provider.getRechargeData({'id': args.recharge});
    final location = await _resolveLocation(recharge);
    return _RechargeDetail(recharge: recharge, location: location);
  }

  void _retry() {
    setState(() => _future = _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: accentColor(), size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          FutureBuilder<_RechargeDetail>(
            future: _future,
            builder: (context, snapshot) {
              final detail = snapshot.data;
              return IconButton(
                key: _shareButtonKey,
                tooltip: 'Compartir comprobante',
                icon: Icon(
                  Icons.ios_share,
                  color: detail == null ? grayInputColor() : accentColor(),
                ),
                onPressed: detail == null ? null : () => _share(detail),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<_RechargeDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: accentColor()),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No se pudo cargar la recarga.',
                    style: TextStyle(
                      color: whiteColor().withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _retry,
                    child: Text(
                      'Reintentar',
                      style: TextStyle(
                        color: accentColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final detail = snapshot.data!;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 16),
                  child: child,
                ),
              );
            },
            child: _content(detail),
          );
        },
      ),
    );
  }

  Widget _content(_RechargeDetail detail) {
    final recharge = detail.recharge;
    final status = _RechargeStatus.of(recharge.status);
    final hasBreakdown = recharge.subtotal != null || recharge.tax != null;
    final hasGateway =
        recharge.payment.name.isNotEmpty || recharge.paymentValue != null;

    final references =
        <MapEntry<String, String>>[
          MapEntry('ID de transacción', recharge.transactionId),
          MapEntry('Autorización', recharge.authorizationCode),
        ].where((e) => e.value.isNotEmpty).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, color: status.color, size: 16),
                const SizedBox(width: 6),
                Text(
                  status.label,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '+${_money(recharge.value)}',
            style: TextStyle(
              color: accentColor(),
              fontSize: 52,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Recarga de saldo',
          style: TextStyle(
            color: whiteColor(),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(recharge.createdAt),
          style: TextStyle(color: grayInputColor(), fontSize: 14),
        ),
        const SizedBox(height: 24),

        // ── Resumen ──
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              if (hasBreakdown) ...[
                _pairRow(
                  _InfoCell(
                    label: 'Subtotal',
                    value:
                        recharge.subtotal == null
                            ? '—'
                            : _money(recharge.subtotal!),
                  ),
                  _InfoCell(
                    label:
                        recharge.taxPercentage == null
                            ? 'IVA'
                            : 'IVA (${_percent(recharge.taxPercentage!)})',
                    value: recharge.tax == null ? '—' : _money(recharge.tax!),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: accentColor().withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      'Total pagado',
                      style: TextStyle(
                        color: whiteColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _money(recharge.value),
                      style: TextStyle(
                        color: accentColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasGateway) ...[
                const SizedBox(height: 4),
                _pairRow(
                  _InfoCell(
                    label: 'Pasarela de pago',
                    value: _paymentMethodLabel(recharge.payment.name),
                  ),
                  _InfoCell(
                    label:
                        recharge.paymentPercentage == null
                            ? 'Comisión pasarela'
                            : 'Comisión pasarela '
                                '(${_percent(recharge.paymentPercentage!)})',
                    value:
                        recharge.paymentValue == null
                            ? '—'
                            : _money(recharge.paymentValue!),
                  ),
                ),
              ],
              _divider(),
              _pairRow(
                _InfoCell(
                  label: 'Tipo de recarga',
                  value: _statusCreatedLabel(recharge.statusCreated),
                ),
                _InfoCell(label: 'Ubicación', value: detail.location ?? '—'),
              ),
              if ((recharge.reason ?? '').isNotEmpty) ...[
                _divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _InfoCell(
                    label: 'Motivo',
                    value: recharge.reason!,
                    maxLines: 4,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Referencias ──
        if (references.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            'REFERENCIAS',
            style: TextStyle(
              color: grayInputColor(),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: _cardDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    for (var i = 0; i < references.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 24,
                          endIndent: 24,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      _ReferenceRow(
                        label: references[i].key,
                        value: references[i].value,
                        onCopy: () => _copy(references[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _pairRow(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: left,
              ),
            ),
            Container(width: 1, color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    indent: 12,
    endIndent: 12,
    color: Colors.white.withValues(alpha: 0.08),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: deepForestGreen(),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
  );

  Future<void> _copy(MapEntry<String, String> reference) async {
    await Clipboard.setData(ClipboardData(text: reference.value));
    if (!mounted) return;
    showSnackbar(context, '${reference.key} copiado', SnackbarStatus.success);
  }

  Future<void> _share(_RechargeDetail detail) async {
    final recharge = detail.recharge;
    final lines = <String>[
      'Comprobante de recarga · Ecored',
      'Monto: +${_money(recharge.value)}',
      'Estado: ${_RechargeStatus.of(recharge.status).label}',
      'Fecha: ${_formatDate(recharge.createdAt)}',
      if (recharge.payment.name.isNotEmpty)
        'Pasarela: ${_paymentMethodLabel(recharge.payment.name)}',
      if (recharge.transactionId.isNotEmpty)
        'ID de transacción: ${recharge.transactionId}',
      if (recharge.authorizationCode.isNotEmpty)
        'Autorización: ${recharge.authorizationCode}',
      if (recharge.devReference.isNotEmpty)
        'Referencia: ${recharge.devReference}',
    ];

    // En iPad la hoja de compartir necesita un punto de anclaje.
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin =
        box == null ? null : box.localToGlobal(Offset.zero) & box.size;

    await SharePlus.instance.share(
      ShareParams(
        text: lines.join('\n'),
        subject: 'Comprobante de recarga Ecored',
        sharePositionOrigin: origin,
      ),
    );
  }
}

// ───────────────── Datos ─────────────────

class _RechargeDetail {
  final ModelRecharge recharge;
  final String? location;

  const _RechargeDetail({required this.recharge, this.location});
}

/// "Azuay, Ecuador". El backend guarda solo los ids de provincia/país en la
/// recarga; si coinciden con los del usuario se usan sus nombres (sin
/// pedir nada), si no se buscan en el catálogo. Si falla, la pantalla igual
/// se muestra, solo sin ubicación.
Future<String?> _resolveLocation(ModelRecharge recharge) async {
  final countryId = recharge.country;
  final provinceId = recharge.province;
  if (countryId == null && provinceId == null) return null;

  final user = Preferences().getUser();
  String? country = user?.country?.id == countryId ? user?.country?.name : null;
  String? province =
      user?.province?.id == provinceId ? user?.province?.name : null;

  try {
    final service = LocationServiceImpl();
    if (country == null && countryId != null) {
      country = _nameById(await service.countries(), countryId);
    }
    if (province == null && provinceId != null && countryId != null) {
      province = _nameById(
        await service.provinces({'country': countryId}),
        provinceId,
      );
    }
  } catch (_) {
    // Sin conexión o catálogo no disponible: se muestra lo que se tenga.
  }

  final parts =
      [province, country]
          .whereType<String>()
          .where((name) => name.isNotEmpty)
          .map(_titleCase)
          .toList();
  return parts.isEmpty ? null : parts.join(', ');
}

String? _nameById(List<LocationModel> locations, String id) {
  for (final location in locations) {
    if (location.id == id) return location.name;
  }
  return null;
}

class _RechargeStatus {
  final String label;
  final Color color;
  final IconData icon;

  const _RechargeStatus(this.label, this.color, this.icon);

  static _RechargeStatus of(String status) {
    switch (status) {
      case 'DONE':
        return _RechargeStatus('Completada', accentColor(), Icons.check);
      case 'PENDING':
        return _RechargeStatus('Pendiente', warningColor(), Icons.schedule);
      case 'REFUND':
        return _RechargeStatus('Reembolsada', infoColor(), Icons.replay);
      case 'DELETED':
        return _RechargeStatus('Eliminada', errorColor(), Icons.close);
      case 'EXPIRED':
        return _RechargeStatus('Expirada', errorColor(), Icons.timer_off);
      default:
        return _RechargeStatus(status, grayInputColor(), Icons.info_outline);
    }
  }
}

// ───────────────── Formato ─────────────────

final NumberFormat _moneyFormat = NumberFormat('#,##0.00', 'en_US');

String _money(double value) => '\$${_moneyFormat.format(value)}';

// 15.0 → "15%", 2.5 → "2.5%"
String _percent(double value) =>
    value == value.roundToDouble()
        ? '${value.toInt()}%'
        : '${value.toStringAsFixed(1)}%';

const List<String> _monthsShort = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

// "2026-10-11T23:55:06.000Z" → "11 oct 2026 · 18:55:06" (hora local)
String _formatDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  final local = parsed.toLocal();
  final time = DateFormat('HH:mm:ss').format(local);
  return '${local.day} ${_monthsShort[local.month - 1]} ${local.year} · $time';
}

String _titleCase(String value) => value
    .toLowerCase()
    .split(' ')
    .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
    .join(' ');

// Nuvei es la pasarela para pagos con tarjeta: al usuario se le muestra el
// medio de pago, no el nombre del proveedor.
String _paymentMethodLabel(String name) =>
    name.toLowerCase() == 'nuvei'
        ? 'Pago con tarjeta débito/crédito'
        : _capitalize(name);

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

String _statusCreatedLabel(String statusCreated) {
  switch (statusCreated) {
    case 'AUTOMATIC':
      return 'Automática';
    case 'MANUAL':
      return 'Manual';
    default:
      return statusCreated;
  }
}

// ───────────────── Widgets ─────────────────

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _InfoCell({
    required this.label,
    required this.value,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: grayInputColor(), fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: whiteColor(),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _ReferenceRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  // Recorta por el medio para que se vean el inicio y el final del código
  // ("REF69e4399a…91762868613"); al copiar se copia completo.
  String get _displayValue {
    const keep = 11;
    if (value.length <= keep * 2 + 1) return value;
    return '${value.substring(0, keep)}…'
        '${value.substring(value.length - keep)}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopy,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: grayInputColor(), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _displayValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: whiteColor(),
                      fontSize: 15,
                      fontFamily: 'monospace',
                      fontFamilyFallback: const ['Menlo', 'Courier'],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Copiar',
              onPressed: onCopy,
              icon: Icon(Icons.copy_rounded, color: accentColor(), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
