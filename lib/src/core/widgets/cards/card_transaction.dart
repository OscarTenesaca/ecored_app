import 'package:flutter/material.dart';

class CardTransaction extends StatelessWidget {
  final IconData icon; // Ícono de la transacción
  final Color iconBgColor; // Color de fondo del ícono
  final String title; // Título de la transacción (monto)
  final Color titleColor; // Color del título
  final String subtitle; // Subtítulo (fecha de la transacción)
  final Color subtitleColor; // Color del subtítulo

  const CardTransaction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleColor = Colors.white,
    this.iconBgColor = Colors.green,
    this.subtitleColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        leading: Container(
          decoration: BoxDecoration(
            color: iconBgColor, // Color de fondo del ícono
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon, // Ícono de la transacción
            color: Colors.white,
            size: 30, // Tamaño del ícono
          ),
        ),
        title: Text(
          title, // Monto de la transacción
          style: TextStyle(
            color: titleColor, // Color del título (por ejemplo, monto)
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle, // Fecha de la transacción
          style: TextStyle(
            color: subtitleColor, // Color del subtítulo (fecha)
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right), // Icono de flecha al final
        onTap: () {
          // Acción al seleccionar la transacción (se puede personalizar)
        },
      ),
    );
  }
}
