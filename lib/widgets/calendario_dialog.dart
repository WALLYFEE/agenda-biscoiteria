// lib/widgets/calendario_dialog.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';

class CalendarioDialog extends StatefulWidget {
  final List<Pedido> pedidos;
  final DateTime dataInicial;

  const CalendarioDialog({
    super.key,
    required this.pedidos,
    required this.dataInicial,
  });

  @override
  _CalendarioDialogState createState() => _CalendarioDialogState();
}

class _CalendarioDialogState extends State<CalendarioDialog> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.dataInicial;
    _focusedDay = widget.dataInicial;
  }

  List<Pedido> _getPedidosParaDia(DateTime day) {
    final String dataFormatada = DateFormat('yyyy-MM-dd').format(day);
    return widget.pedidos
        .where((pedido) => pedido.dataEntrega == dataFormatada)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              focusedDay: _focusedDay,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle(
                  color: Colors.red[300],
                  fontSize: 13, // diminua para evitar corte
                  fontWeight: FontWeight.w500,
                ),
                weekdayStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13, // <= ajuste aqui!
                  fontWeight: FontWeight.w500,
                ),
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) => _getPedidosParaDia(day),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFF7B3F00),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF7B3F00),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pedidos para ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B3F00),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child:
                  _getPedidosParaDia(_selectedDay).isEmpty
                      ? const Center(child: Text('Nenhum pedido para este dia'))
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _getPedidosParaDia(_selectedDay).length,
                        itemBuilder: (context, index) {
                          final pedido =
                              _getPedidosParaDia(_selectedDay)[index];
                          return ListTile(
                            leading: Icon(
                              pedido.concluido
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color:
                                  pedido.concluido
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                            title: Text(pedido.produto.descricao),
                            subtitle: Text(
                              'Quantidade: ${pedido.quantidade} | Valor Total: ${pedido.valorTotal}',
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedDay),
                  child: const Text('Selecionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
