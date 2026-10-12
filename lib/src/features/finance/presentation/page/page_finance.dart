import 'dart:math' as math;

import 'package:ecored_app/src/core/routes/routes_name.dart';
import 'package:ecored_app/src/core/theme/theme_index.dart';
import 'package:ecored_app/src/core/utils/utils_index.dart';
import 'package:ecored_app/src/core/utils/utils_preferences.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// `GET /transaction` devuelve 10 por defecto. Con más historial los filtros
// (Recargas / Pagos) no se quedan con 2 o 3 movimientos sueltos.
const int _transactionsLimit = 100;

enum _MovementFilter { all, recharges, payments }

class PageFinance extends StatefulWidget {
  const PageFinance({super.key});

  @override
  State<PageFinance> createState() => _PageFinanceState();
}

class _PageFinanceState extends State<PageFinance> {
  _MovementFilter _filter = _MovementFilter.all;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<FinanceProvider>();
    final userId = Preferences().getUser()?.id;
    await provider.getWalletData({'user': userId});
    await provider.getTransactionData({
      'user': userId,
      'limit': _transactionsLimit,
    });
  }

  bool _matchesFilter(ModelTransaction transaction) {
    switch (_filter) {
      case _MovementFilter.all:
        return true;
      case _MovementFilter.recharges:
        return transaction.type == 'RECHARGE';
      case _MovementFilter.payments:
        return transaction.type == 'CONSUMPTION';
    }
  }

  void _openDetail(ModelTransaction transaction) {
    switch (transaction.type) {
      case 'RECHARGE':
        Navigator.pushNamed(
          context,
          RouteNames.pageRecharge,
          arguments: transaction,
        );
      case 'CONSUMPTION':
      case 'REFUND':
        if ((transaction.order ?? '').isEmpty) return;
        Navigator.pushNamed(
          context,
          RouteNames.pageOrder,
          arguments: transaction,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final transactions = provider.transactionData;
    final isFirstLoad = transactions == null && provider.isLoading;
    final hasAnyMovement = (transactions ?? const []).isNotEmpty;
    final visible =
        (transactions ?? const <ModelTransaction>[])
            .where(_matchesFilter)
            .toList();

    return Scaffold(
      backgroundColor: primaryColor(),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: accentColor(),
          backgroundColor: deepForestGreen(),
          onRefresh: _loadData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            // El espacio inferior deja ver el último movimiento por encima
            // de la barra de navegación flotante.
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              UtilSize.bottomPadding() + 110,
            ),
            children: [
              Text(
                'Billetera',
                style: TextStyle(
                  color: whiteColor(),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _BalanceCard(
                balance: provider.financeData?.balance ?? 0,
                onRecharge:
                    () => Navigator.pushNamed(context, RouteNames.pagePlan),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Text(
                    'Movimientos',
                    style: TextStyle(
                      color: whiteColor(),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (provider.isLoading && transactions != null)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accentColor(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (isFirstLoad)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: accentColor()),
                  ),
                )
              else if (!hasAnyMovement)
                const _EmptyMovements(
                  title: 'Aún no tienes movimientos',
                  message:
                      'Recarga saldo para pagar tus cargas. Tus recargas y '
                      'pagos aparecerán aquí.',
                )
              else ...[
                _filterChips(),
                const SizedBox(height: 20),
                if (visible.isEmpty)
                  _EmptyMovements(
                    title:
                        _filter == _MovementFilter.recharges
                            ? 'Sin recargas'
                            : 'Sin pagos',
                    message:
                        _filter == _MovementFilter.recharges
                            ? 'Todavía no has recargado saldo.'
                            : 'Tus pagos de carga aparecerán aquí.',
                  )
                else
                  ..._groupByDay(visible).entries.expand(
                    (group) => [
                      _DayHeader(date: group.key),
                      const SizedBox(height: 10),
                      _DayGroup(transactions: group.value, onTap: _openDetail),
                      const SizedBox(height: 22),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChips() {
    const labels = {
      _MovementFilter.all: 'Todos',
      _MovementFilter.recharges: 'Recargas',
      _MovementFilter.payments: 'Pagos',
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          labels.entries.map((entry) {
            final selected = _filter == entry.key;

            return Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color:
                      selected
                          ? accentColor().withValues(alpha: 0.12)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        selected
                            ? accentColor()
                            : Colors.white.withValues(alpha: 0.12),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => _filter = entry.key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: selected ? accentColor() : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ───────────────── Helpers ─────────────────

final NumberFormat _moneyFormat = NumberFormat('#,##0.00', 'en_US');

const List<String> _monthsShort = [
  'ENE',
  'FEB',
  'MAR',
  'ABR',
  'MAY',
  'JUN',
  'JUL',
  'AGO',
  'SEP',
  'OCT',
  'NOV',
  'DIC',
];

// Agrupa por día local manteniendo el orden del backend (más reciente
// primero).
Map<DateTime, List<ModelTransaction>> _groupByDay(
  List<ModelTransaction> transactions,
) {
  final groups = <DateTime, List<ModelTransaction>>{};
  for (final transaction in transactions) {
    final local = transaction.createdAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    groups.putIfAbsent(day, () => []).add(transaction);
  }
  return groups;
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onRecharge;

  const _BalanceCard({required this.balance, required this.onRecharge});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(deepForestGreen(), accentColor(), 0.1)!,
            deepForestGreen(),
          ],
        ),
        border: Border.all(color: accentColor().withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: accentColor().withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CardArcsPainter(color: accentColor()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomPaint(
                        size: const Size(44, 32),
                        painter: _CardChipPainter(
                          color: accentColor(),
                          lineColor: deepForestGreen(),
                        ),
                      ),
                      const Spacer(),
                      Tooltip(
                        message: 'Recargar saldo',
                        child: Material(
                          color: accentColor().withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: onRecharge,
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.add_card_rounded,
                                color: accentColor(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Saldo disponible',
                    style: TextStyle(color: grayInputColor(), fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '\$ ${_moneyFormat.format(balance)}',
                            style: TextStyle(
                              color: accentColor(),
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, color: accentColor(), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'ecored',
                              style: TextStyle(
                                color: whiteColor(),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arcos concéntricos decorativos desde la esquina inferior derecha.
class _CardArcsPainter extends CustomPainter {
  final Color color;

  const _CardArcsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = color.withValues(alpha: 0.12);

    final center = Offset(size.width, size.height);
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, size.height * 0.32 * i, paint);
    }
  }

  @override
  bool shouldRepaint(_CardArcsPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Chip de tarjeta (EMV) dibujado, para no depender de un asset.
class _CardChipPainter extends CustomPainter {
  final Color color;
  final Color lineColor;

  const _CardChipPainter({required this.color, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.height * 0.2)),
      Paint()..color = color,
    );

    final line =
        Paint()
          ..color = lineColor
          ..strokeWidth = math.max(1.5, size.height * 0.06);

    final left = size.width * 0.36;
    final right = size.width * 0.64;
    canvas.drawLine(Offset(left, 0), Offset(left, size.height), line);
    canvas.drawLine(Offset(right, 0), Offset(right, size.height), line);
    for (final y in [size.height / 3, size.height * 2 / 3]) {
      canvas.drawLine(Offset(0, y), Offset(left, y), line);
      canvas.drawLine(Offset(right, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(_CardChipPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.lineColor != lineColor;
}

class _DayHeader extends StatelessWidget {
  final DateTime date;

  const _DayHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final day = date.day.toString().padLeft(2, '0');
    return Text(
      '$day ${_monthsShort[date.month - 1]} ${date.year}',
      style: TextStyle(
        color: grayInputColor(),
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  final List<ModelTransaction> transactions;
  final ValueChanged<ModelTransaction> onTap;

  const _DayGroup({required this.transactions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: deepForestGreen(),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var i = 0; i < transactions.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                _MovementRow(
                  transaction: transactions[i],
                  onTap: () => onTap(transactions[i]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  final ModelTransaction transaction;
  final VoidCallback onTap;

  const _MovementRow({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final String title;
    final IconData icon;
    final bool positive;
    switch (transaction.type) {
      case 'RECHARGE':
        title = 'Recarga Aplicativo';
        icon = Icons.add;
        positive = true;
      case 'REFUND':
        title = 'Reembolso';
        icon = Icons.replay_rounded;
        positive = true;
      case 'CONSUMPTION':
      default:
        title = 'Pago Electrolinera';
        icon = Icons.bolt_outlined;
        positive = false;
    }

    final color = positive ? accentColor() : errorColor();
    final amount =
        '${positive ? '+' : '−'}\$${_moneyFormat.format(transaction.amount)}';
    final time = DateFormat('HH:mm').format(transaction.createdAt.toLocal());

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: whiteColor(),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(color: grayInputColor(), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyMovements({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: Colors.white.withValues(alpha: 0.15),
        radius: 22,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.attach_money,
                color: grayInputColor(),
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: whiteColor(),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: grayInputColor(),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  static const double _dash = 6;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            (Offset.zero & size).deflate(0.6),
            Radius.circular(radius),
          ),
        );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + _dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

// import 'package:ecored_app/src/core/routes/routes_name.dart';
// import 'package:ecored_app/src/core/theme/theme_colors.dart';
// import 'package:ecored_app/src/core/utils/utils_index.dart';
// import 'package:ecored_app/src/core/utils/utils_preferences.dart';
// import 'package:ecored_app/src/core/widgets/cards/card_transaction.dart';
// import 'package:ecored_app/src/core/widgets/labels/label_title.dart';
// import 'package:ecored_app/src/core/widgets/widget_index.dart';
// import 'package:ecored_app/src/features/finance/data/models/model_transaction.dart';
// import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class PageFinance extends StatefulWidget {
//   const PageFinance({super.key});

//   @override
//   State<PageFinance> createState() => _PageFinanceState();
// }

// class _PageFinanceState extends State<PageFinance> {
//   @override
//   void initState() {
//     _loadData();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<FinanceProvider>();
//     return Scaffold(
//       backgroundColor: accentColor()Color(),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.only(
//           top: UtilSize.appBarHeight() + 5,
//           right: 16,
//           left: 16,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             LabelTitle(
//               title: 'Mi Billetera',
//               alignment: Alignment.center,
//               fontWeight: FontWeight.bold,
//               fontSize: 24,
//             ),

//             /// 🔹 Tarjeta de saldo
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               // color: greyColorWithTransparency(),
//               shadowColor: accentColor(),
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     LabelTitle(
//                       alignment: Alignment.center,
//                       title: "Saldo disponible",
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     const SizedBox(height: 8),
//                     LabelTitle(
//                       alignment: Alignment.center,
//                       title: "\$ ${provider.financeData?.balance}",
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       textColor: accentColor(),
//                     ),

//                     const SizedBox(height: 8),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, RouteNames.pagePlan);
//                       },
//                       icon: const Icon(Icons.add_circle),
//                       label: const Text("Recargar"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             /// 🔹 Transacciones
//             const Text(
//               "Transacciones Recientes",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             ListView.separated(
//               padding: EdgeInsets.only(bottom: 16),
//               itemCount: provider.transactionData?.length ?? 0,
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               separatorBuilder: (_, int index) => SizedBox(height: 8),
//               itemBuilder: (BuildContext context, int index) {
//                 // Asegurarse de que no sea null
//                 ModelTransaction? transaction =
//                     provider.transactionData?[index];

//                 return (transaction!.type == 'RECHARGE')
//                     ? CardTransaction(
//                       icon: Icons.attach_money,
//                       title: "+ \$ ${transaction.amount}",
//                       // subtitle: transaction.createdAt.toString(),
//                       subtitle: UtilsDate.formatLocal(
//                         transaction.createdAt.toString(),
//                       ),
//                       onTap: () {
//                         Navigator.pushNamed(
//                           context,
//                           RouteNames.pageRecharge,
//                           arguments: transaction,
//                         );
//                       },
//                     )
//                     : CardTransaction(
//                       icon: Icons.local_gas_station,
//                       iconBgColor: Colors.red,
//                       title: "- \$ ${transaction.amount}",
//                       subtitle: UtilsDate.formatLocal(
//                         transaction.createdAt.toString(),
//                       ),
//                       onTap: () {
//                         Navigator.pushNamed(
//                           context,
//                           RouteNames.pageOrder,
//                           arguments: transaction,
//                         );
//                       },
//                     );
//               },
//             ),
//             Padding(
//               padding: EdgeInsets.only(bottom: UtilSize.bottomPadding() + 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _loadData() async {
//     final provider = context.read<FinanceProvider>();
//     await provider.getWalletData({'user': Preferences().getUser()?.id});
//     await provider.getTransactionData({'user': Preferences().getUser()?.id});
//   }
// }
