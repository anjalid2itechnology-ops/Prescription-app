import "package:flutter/material.dart";
import "../../models/medicine.dart";
import "../../services/inventory_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/common_widgets.dart";

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _service = InventoryService();
  late Future<List<Medicine>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getInventory();
  }

  void _refresh() => setState(() => _future = _service.getInventory());

  Future<void> _addMedicineSheet() async {
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Add medicine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Medicine name")),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Stock qty"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: "Unit price"),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: expiryCtrl,
                decoration: const InputDecoration(labelText: "Expiry date (yyyy-MM-dd)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  await _service.addMedicine(
                    name: nameCtrl.text.trim(),
                    stockQuantity: int.tryParse(stockCtrl.text.trim()) ?? 0,
                    unitPrice: double.tryParse(priceCtrl.text.trim()) ?? 0,
                    expiryDate: expiryCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _refresh();
                },
                child: const Text("Save medicine"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: "Stock overview",
            action: FilledButton.tonalIcon(
              onPressed: _addMedicineSheet,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Add"),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Medicine>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const AppLoading();
                final list = snapshot.data!;
                if (list.isEmpty) {
                  return const EmptyState(icon: Icons.inventory_2_outlined, message: "No medicines added yet.");
                }
                final lowStock = list.where((m) => m.stockQuantity < 10).toList();
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView(
                    children: [
                      if (lowStock.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  lowStock.length == 1
                                      ? "${lowStock.first.name} is running low on stock"
                                      : "${lowStock.length} medicines are running low on stock",
                                  style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...list.map((m) {
                        final low = m.stockQuantity < 10;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            child: ListTile(
                              title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text("₹${m.unitPrice.toStringAsFixed(2)} · expires ${m.expiryDate}"),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (low ? AppColors.danger : AppColors.success).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  "${m.stockQuantity} left",
                                  style: TextStyle(
                                    color: low ? AppColors.danger : AppColors.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
