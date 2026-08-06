import 'package:ecored_app/src/core/theme/theme_colors.dart';
import 'package:ecored_app/src/core/widgets/widget_index.dart';
import 'package:ecored_app/src/features/finance/data/models/model_index.dart';
import 'package:ecored_app/src/features/finance/presentation/provider/finance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageRecharge extends StatefulWidget {
  const PageRecharge({super.key});

  @override
  State<PageRecharge> createState() => _PageRechargeState();
}

class _PageRechargeState extends State<PageRecharge> {
  @override
  Widget build(BuildContext context) {
    final ModelTransaction args =
        ModalRoute.of(context)?.settings.arguments as ModelTransaction;

    return Scaffold(
      backgroundColor: primaryColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: accentColor()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<ModelRecharge>(
        future: _loadData(args),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: accentColor()),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'No se pudo cargar la recarga.',
                style: TextStyle(color: whiteColor().withValues(alpha: 0.8)),
              ),
            );
          }

          final rechargeData = snapshot.data!;
          // print(rechargeData.toJson().toString());
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
            child: ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.only(left: 18, right: 18),
              children: [
                /// -------- CARD PRINCIPAL -----------
                CardSummary(
                  titleColor: grayInputColor(),
                  status: _rechargeStatusLabel(rechargeData.status),
                  statusColor: _rechargeStatusColor(rechargeData.status),
                  subtitle: '+ \$${rechargeData.value.toStringAsFixed(2)}',
                  subtitleColor: successColor(),
                  leftText: _rechargeStatusDescription(rechargeData.status),
                  leftTextColor: grayInputColor(),
                  rightText: rechargeData.createdAt,
                  rightTextColor: whiteColor().withValues(alpha: 0.65),
                ),
                const SizedBox(height: 18),

                /// -------- SECCIÓN DETALLES TRANSACCIÓN -----
                CardTitleDescription(
                  title: 'Detalles de Transacción',
                  icon: Icons.receipt_long,
                  iconColor: accentColor(),
                  rows: [
                    LabelRowText(
                      label: "Método de pago",
                      value:
                          (rechargeData.payment.name.toLowerCase() == 'nuvei')
                              ? "Pago con Tarjeta"
                              : rechargeData.payment.name,
                    ),
                    LabelRowText(
                      label: "Monto",
                      value: '\$${rechargeData.value.toStringAsFixed(2)}',
                    ),
                    LabelRowText(
                      label: "Transaction ID",
                      value: rechargeData.transactionId,
                    ),
                    LabelRowText(
                      label: "Autorización",
                      value: rechargeData.authorizationCode,
                    ),
                    // if (rechargeData.devReference.isNotEmpty)
                    //   LabelRowText(
                    //     label: "Referencia",
                    //     value: rechargeData.devReference,
                    //   ),
                    LabelRowText(
                      label: "Tipo de recarga",
                      value: _statusCreatedLabel(rechargeData.statusCreated),
                    ),
                    LabelRowText(label: "Fecha", value: rechargeData.createdAt),
                    if (rechargeData.reason != null &&
                        rechargeData.reason!.isNotEmpty)
                      LabelRowText(
                        label: "Motivo",
                        value: rechargeData.reason!,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<ModelRecharge> _loadData(ModelTransaction args) async {
    final provider = context.read<FinanceProvider>();
    return await provider.getRechargeData({'id': args.recharge});
  }
}

String _rechargeStatusLabel(String status) {
  switch (status) {
    case 'DONE':
      return 'Completada';
    case 'PENDING':
      return 'Pendiente';
    case 'REFUND':
      return 'Reembolsada';
    case 'DELETED':
      return 'Eliminada';
    case 'EXPIRED':
      return 'Expirada';
    default:
      return status;
  }
}

String _rechargeStatusDescription(String status) {
  switch (status) {
    case 'DONE':
      return 'Recargado con éxito';
    case 'PENDING':
      return 'Recarga pendiente de confirmación';
    case 'REFUND':
      return 'Recarga reembolsada';
    case 'DELETED':
      return 'Recarga eliminada';
    case 'EXPIRED':
      return 'Recarga expirada';
    default:
      return 'Recarga';
  }
}

Color _rechargeStatusColor(String status) {
  switch (status) {
    case 'DONE':
      return successColor();
    case 'PENDING':
      return warningColor();
    case 'REFUND':
      return infoColor();
    case 'DELETED':
    case 'EXPIRED':
      return errorColor();
    default:
      return grayInputColor();
  }
}

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
