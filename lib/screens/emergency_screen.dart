import 'package:flutter/material.dart';
import '../l10n/localization.dart';
import '../services/emergency_service.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _controller = TextEditingController(text: '112');
  bool _busy = false;

  Future<void> _wrap(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: l.enterPhone,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 64,
          child: FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _wrap(() async {
                      LumiOverlay.set(emotion: LumiEmotion.excited, speech: 'Calling 103...');
                      await EmergencyService.callNumber('103');
                    }),
            icon: const Icon(Icons.local_hospital, size: 28),
            label: Text(l.call103, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _wrap(() async {
                      LumiOverlay.set(emotion: LumiEmotion.excited, speech: 'Calling 112...');
                      await EmergencyService.callNumber('112');
                    }),
            icon: const Icon(Icons.sos, size: 32),
            label: Text(l.call112, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy
              ? null
              : () => _wrap(() async {
                    LumiOverlay.set(emotion: LumiEmotion.pointing, speech: 'Sending SMS + GPS');
                    await EmergencyService.smsWithGps(_controller.text.trim());
                  }),
          icon: const Icon(Icons.sms),
          label: Text(l.smsGps),
        ),
        const SizedBox(height: 16),
        const Text('Smart 911 (auto-detect region) - demo via dialer/SMS'),
        const SizedBox(height: 16),
        const _KazInsuranceList(),
        const SizedBox(height: 8),
        const _LifeProductsList(),
      ],
    );
  }
}

class _KazInsuranceList extends StatelessWidget {
  const _KazInsuranceList();
  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> items = [
      {
        'name': 'Halyk-Life',
        'desc': 'Страхование жизни',
        'bullets': [
          'Рисковое и накопительное страхование',
          'Семейные программы',
          'Телемедицина/второе мнение (по тарифу)',
        ],
      },
      {
        'name': 'Nomad Life',
        'desc': 'Страхование жизни и аннуитеты',
        'bullets': [
          'Накопительное/рисковое',
          'Программы на образование и семью',
          'Онлайн-сервисы обслуживания',
        ],
      },
      {
        'name': 'Freedom Life',
        'desc': 'Жизнь + инвестиционные решения',
        'bullets': [
          'Инвестиционное/накопительное страхование',
          'Возможные налоговые льготы (по тарифу)',
          'Поддержка 24/7',
        ],
      },
      {
        'name': 'Eurasia Life',
        'desc': 'Страхование жизни',
        'bullets': [
          'Рисковое/накопительное',
          'Семейные планы',
          'Покрытие критических заболеваний (по тарифу)',
        ],
      },
      {
        'name': 'Tengri Life',
        'desc': 'Страхование жизни',
        'bullets': [
          'Накопительное и рисковое продукты',
          'Семейные и детские программы',
          'Онлайн-оформление и сервис',
        ],
      },
      {
        'name': 'KM Life',
        'desc': 'Страхование жизни',
        'bullets': [
          'Рисковое/накопительное',
          'Аннуитетные решения',
          'Поддержка клиентов 24/7',
        ],
      },
      {
        'name': 'ГАК (Гос. аннуитетная компания)',
        'desc': 'Аннуитетные программы',
        'bullets': [
          'Страховые аннуитеты',
          'Госпрограммы',
          'Пенсионные решения',
        ],
      },
    ];
    return ExpansionTile(
      title: const Text('Страхование жизни в Казахстане (инфо)'),
      children: [
        for (final it in items)
          ListTile(
            title: Text(it['name'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it['desc'] as String),
                const SizedBox(height: 4),
                for (final s in (it['bullets'] as List).cast<String>()) Text('• $s'),
              ],
            ),
            isThreeLine: true,
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            'Информация носит справочный характер. Подробные условия, тарифы и доступность услуг зависят от компании и региона.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _LifeProductsList extends StatelessWidget {
  const _LifeProductsList();
  @override
  Widget build(BuildContext context) {
    final products = const [
      'Рисковое страхование жизни (term life)',
      'Накопительное страхование (endowment)',
      'Инвестиционное страхование жизни (unit-linked)',
      'Страховые аннуитеты (пенсионные/доходные)',
      'Покрытие критических заболеваний (доп. опция)',
      'Семейные и детские программы',
    ];
    return ExpansionTile(
      title: const Text('Варианты продуктов'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final p in products) Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $p'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
