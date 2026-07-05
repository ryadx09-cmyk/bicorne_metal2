import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bicorne Metal',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Job {
  String clientName;
  String jobType;
  double materialCost;
  double workerCost;
  double amountDue;

  Job({
    required this.clientName,
    required this.jobType,
    this.materialCost = 0,
    this.workerCost = 0,
    this.amountDue = 0,
  });

  double get profit => amountDue - materialCost - workerCost;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Job> jobs = [];

  double get totalProfit =>
      jobs.fold(0, (sum, job) => sum + job.profit);

  void _addJob(Job job) {
    setState(() {
      jobs.add(job);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bicorne Metal'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey.shade50,
            child: Column(
              children: [
                const Text(
                  'الربح الصافي الكلي',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${totalProfit.toStringAsFixed(2)} د.ج',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: totalProfit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: jobs.isEmpty
                ? const Center(child: Text('ما كاينة حتى شغلة، زيد واحدة'))
                : ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(job.clientName),
                          subtitle: Text(job.jobType),
                          trailing: Text(
                            '${job.profit.toStringAsFixed(2)} د.ج',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: job.profit >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JobDetailScreen(job: job),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newJob = await Navigator.push<Job>(
            context,
            MaterialPageRoute(builder: (context) => const AddJobScreen()),
          );
          if (newJob != null) {
            _addJob(newJob);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الكليان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'نوع الشغل (حدادة / ستارة حديدية)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}

class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late TextEditingController _materialController;
  late TextEditingController _workerController;
  late TextEditingController _dueController;

  @override
  void initState() {
    super.initState();
    _materialController =
        TextEditingController(text: widget.job.materialCost.toString());
    _workerController =
        TextEditingController(text: widget.job.workerCost.toString());
    _dueController =
        TextEditingController(text: widget.job.amountDue.toString());
  }

  void _save() {
    setState(() {
      widget.job.materialCost =
          double.tryParse(_materialController.text) ?? 0;
      widget.job.workerCost = double.tryParse(_workerController.text) ?? 0;
      widget.job.amountDue = double.tryParse(_dueController.text) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.job.clientName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _materialController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'مصاريف المواد (حديد...)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _workerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'مصاريف العمال',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المستحقات (المبلغ الكلي من الكليان)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _save(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('الربح الصافي', style: TextStyle(fontSize: 16)),
                  Text(
                    '${widget.job.profit.toStringAsFixed(2)} د.ج',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.job.profit >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
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
