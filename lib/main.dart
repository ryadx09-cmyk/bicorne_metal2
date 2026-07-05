import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ---------------- الثيم ----------------

const _primaryColor = Color(0xFF1A1D29);
const _accentColor = Color(0xFFFF6B35);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bicorne Metal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor,
          primary: _accentColor,
          secondary: _primaryColor,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------- المودلات ----------------

class MaterialItem {
  String name;
  double? pricePerMeter;
  double? pricePerKg;

  MaterialItem({required this.name, this.pricePerMeter, this.pricePerKg});
}

class MaterialUsage {
  MaterialItem material;
  double quantity;
  String unit;

  MaterialUsage(
      {required this.material, required this.quantity, required this.unit});

  double get cost => unit == 'meter'
      ? quantity * (material.pricePerMeter ?? 0)
      : quantity * (material.pricePerKg ?? 0);
}

class Job {
  String clientName;
  String jobType;
  List<MaterialUsage> materialUsages;
  double workerCost;
  double amountDue;

  Job({
    required this.clientName,
    required this.jobType,
    List<MaterialUsage>? materialUsages,
    this.workerCost = 0,
    this.amountDue = 0,
  }) : materialUsages = materialUsages ?? [];

  double get materialCost =>
      materialUsages.fold(0, (sum, m) => sum + m.cost);

  double get profit => amountDue - materialCost - workerCost;
}

// ---------------- الشاشة الرئيسية ----------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Job> jobs = [];
  final List<MaterialItem> materials = [];

  double get totalProfit => jobs.fold(0, (sum, job) => sum + job.profit);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bicorne Metal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'السلع',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaterialsScreen(materials: materials),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primaryColor, Color(0xFF2E3350)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('الربح الصافي الكلي',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Text(
                  '${totalProfit.toStringAsFixed(2)} د.ج',
                  style: TextStyle(
                    color: totalProfit >= 0
                        ? const Color(0xFF6EE7A0)
                        : const Color(0xFFFF8A80),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${jobs.length} شغلة مسجلة',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: jobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.construction,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('ما كاينة حتى شغلة',
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final initial =
                          job.clientName.isNotEmpty ? job.clientName[0] : '?';
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: _accentColor.withOpacity(0.15),
                            child: Text(initial,
                                style: const TextStyle(
                                    color: _accentColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(job.clientName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(job.jobType),
                          trailing: Text(
                            '${job.profit.toStringAsFixed(0)} د.ج',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: job.profit >= 0
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JobDetailScreen(
                                    job: job, materials: materials),
                              ),
                            );
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newJob = await Navigator.push<Job>(
            context,
            MaterialPageRoute(builder: (context) => const AddJobScreen()),
          );
          if (newJob != null) setState(() => jobs.add(newJob));
        },
        icon: const Icon(Icons.add),
        label: const Text('شغلة جديدة'),
      ),
    );
  }
}

// ---------------- إضافة شغلة ----------------

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شغلة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم الكليان'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                  labelText: 'نوع الشغل (حدادة / ستارة حديدية)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty) return;
                  Navigator.pop(
                    context,
                    Job(
                      clientName: _nameController.text,
                      jobType: _typeController.text,
                    ),
                  );
                },
                child: const Text('إضافة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- السلع ----------------

class MaterialsScreen extends StatefulWidget {
  final List<MaterialItem> materials;
  const MaterialsScreen({super.key, required this.materials});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السلع')),
      body: widget.materials.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('ما كاينة حتى سلعة', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: widget.materials.length,
              itemBuilder: (context, index) {
                final m = widget.materials[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0x1AFF6B35),
                      child: Icon(Icons.category, color: _accentColor),
                    ),
                    title: Text(m.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text([
                      if (m.pricePerMeter != null)
                        'المتر: ${m.pricePerMeter!.toStringAsFixed(2)} د.ج',
                      if (m.pricePerKg != null)
                        'الكيلو: ${m.pricePerKg!.toStringAsFixed(2)} د.ج',
                    ].join('  •  ')),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newMaterial = await Navigator.push<MaterialItem>(
            context,
            MaterialPageRoute(builder: (context) => const AddMaterialScreen()),
          );
          if (newMaterial != null) {
            setState(() => widget.materials.add(newMaterial));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('سلعة جديدة'),
      ),
    );
  }
}

class AddMaterialScreen extends StatefulWidget {
  const AddMaterialScreen({super.key});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _nameController = TextEditingController();
  final _meterController = TextEditingController();
  final _kgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سلعة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(labelText: 'اسم السلعة'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _meterController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'السعر بالمتر (اختياري)'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _kgController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'السعر بالكيلو (اختياري)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty) return;
                  Navigator.pop(
                    context,
                    MaterialItem(
                      name: _nameController.text,
                      pricePerMeter: double.tryParse(_meterController.text),
                      pricePerKg: double.tryParse(_kgController.text),
                    ),
                  );
                },
                child: const Text('إضافة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- تفاصيل الشغلة ----------------

class JobDetailScreen extends StatefulWidget {
  final Job job;
  final List<MaterialItem> materials;
  const JobDetailScreen({super.key, required this.job, required this.materials});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late TextEditingController _workerController;
  late TextEditingController _dueController;

  @override
  void initState() {
    super.initState();
    _workerController =
        TextEditingController(text: widget.job.workerCost.toString());
    _dueController =
        TextEditingController(text: widget.job.amountDue.toString());
  }

  void _saveNumbers() {
    setState(() {
      widget.job.workerCost = double.tryParse(_workerController.text) ?? 0;
      widget.job.amountDue = double.tryParse(_dueController.text) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      appBar: AppBar(title: Text(job.clientName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('المواد المستعملة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (job.materialUsages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('ما زيدت حتى مادة',
                  style: TextStyle(color: Colors.grey.shade600)),
            )
          else
            ...job.materialUsages.map((u) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.category, color: _accentColor),
                    title: Text(u.material.name),
                    subtitle: Text(
                        '${u.quantity} ${u.unit == 'meter' ? 'متر' : 'كغ'}'),
                    trailing: Text('${u.cost.toStringAsFixed(2)} د.ج',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('زيد مادة'),
            onPressed: widget.materials.isEmpty
                ? null
                : () async {
                    final usage = await Navigator.push<MaterialUsage>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddMaterialUsageScreen(materials: widget.materials),
                      ),
                    );
                    if (usage != null) {
                      setState(() => job.materialUsages.add(usage));
                    }
                  },
          ),
          const Divider(height: 32),
          TextField(
            controller: _workerController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'مصاريف العمال'),
            onChanged: (_) => _saveNumbers(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _dueController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'المستحقات (المبلغ الكلي)'),
            onChanged: (_) => _saveNumbers(),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primaryColor, Color(0xFF2E3350)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text('مصاريف المواد: ${job.materialCost.toStringAsFixed(2)} د.ج',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                const Text('الربح الصافي',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(
                  '${job.profit.toStringAsFixed(2)} د.ج',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: job.profit >= 0
                        ? const Color(0xFF6EE7A0)
                        : const Color(0xFFFF8A80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddMaterialUsageScreen extends StatefulWidget {
  final List<MaterialItem> materials;
  const AddMaterialUsageScreen({super.key, required this.materials});

  @override
  State<AddMaterialUsageScreen> createState() =>
      _AddMaterialUsageScreenState();
}

class _AddMaterialUsageScreenState extends State<AddMaterialUsageScreen> {
  MaterialItem? _selected;
  String _unit = 'meter';
  final _qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مادة')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<MaterialItem>(
              value: _selected,
              decoration: const InputDecoration(labelText: 'اختار السلعة'),
              items: widget.materials
                  .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selected = val;
                  if (val != null) {
                    _unit = val.pricePerMeter != null ? 'meter' : 'kg';
                  }
                });
              },
            ),
            const SizedBox(height: 14),
            if (_selected != null)
              Row(
                children: [
                  if (_selected!.pricePerMeter != null)
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('متر'),
                        value: 'meter',
                        groupValue: _unit,
                        onChanged: (v) => setState(() => _unit = v!),
                      ),
                    ),
                  if (_selected!.pricePerKg != null)
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('كغ'),
                        value: 'kg',
                        groupValue: _unit,
                        onChanged: (v) => setState(() => _unit = v!),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 14),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'الكمية'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final qty = double.tryParse(_qtyController.text);
                  if (_selected == null || qty == null) return;
                  Navigator.pop(
                    context,
                    MaterialUsage(
                        material: _selected!, quantity: qty, unit: _unit),
                  );
                },
                child: const Text('إضافة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
