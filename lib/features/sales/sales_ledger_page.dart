import 'package:flutter/material.dart';

class SalesLedgerPage extends StatelessWidget {
  const SalesLedgerPage({super.key});

  static final List<_SalesLedgerRow> _rows = <_SalesLedgerRow>[
    _SalesLedgerRow(
      invoiceNo: 'INV-2401',
      date: '2026-02-18',
      party: 'Mitra Traders',
      total: 18500,
      paid: 8000,
      balance: 10500,
      status: 'Pending',
    ),
    _SalesLedgerRow(
      invoiceNo: 'INV-2402',
      date: '2026-02-19',
      party: 'Shree Agencies',
      total: 32000,
      paid: 32000,
      balance: 0,
      status: 'Paid',
    ),
    _SalesLedgerRow(
      invoiceNo: 'INV-2403',
      date: '2026-02-20',
      party: 'Blue Ocean Supplies',
      total: 14200,
      paid: 10000,
      balance: 4200,
      status: 'Partial',
    ),
    _SalesLedgerRow(
      invoiceNo: 'INV-2404',
      date: '2026-02-22',
      party: 'Prime Wholesale',
      total: 27800,
      paid: 0,
      balance: 27800,
      status: 'Pending',
    ),
  ];

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'Paid':
        return Colors.green.shade700;
      case 'Partial':
        return Colors.orange.shade700;
      default:
        return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _FilterChipBox(label: 'This Month'),
            _FilterChipBox(label: 'All Customers'),
            _FilterChipBox(label: 'Outstanding'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Sales Ledger',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Invoice')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Party')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Paid')),
                DataColumn(label: Text('Balance')),
                DataColumn(label: Text('Status')),
              ],
              rows: _rows
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.invoiceNo)),
                        DataCell(Text(item.date)),
                        DataCell(Text(item.party)),
                        DataCell(Text('₹ ${item.total.toStringAsFixed(0)}')),
                        DataCell(Text('₹ ${item.paid.toStringAsFixed(0)}')),
                        DataCell(Text('₹ ${item.balance.toStringAsFixed(0)}')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(context, item.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                color: _statusColor(context, item.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChipBox extends StatelessWidget {
  const _FilterChipBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(label),
    );
  }
}

class _SalesLedgerRow {
  const _SalesLedgerRow({
    required this.invoiceNo,
    required this.date,
    required this.party,
    required this.total,
    required this.paid,
    required this.balance,
    required this.status,
  });

  final String invoiceNo;
  final String date;
  final String party;
  final double total;
  final double paid;
  final double balance;
  final String status;
}
