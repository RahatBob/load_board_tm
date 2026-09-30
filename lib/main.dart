import 'package:flutter/material.dart';

void main() {
  runApp(const LoadBoardApp());
}

class LoadBoardApp extends StatelessWidget {
  const LoadBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Load Board TM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const AuthScreen(),
    );
  }
}

// ==========================================
// 1. ЭКРАН SMS-АВТОРИЗАЦИИ (БЕЗ ИМЕНИ)
// ==========================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String selectedLang = 'ru'; // 'tm', 'ru', 'en'
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool isCodeSent = false;

  Map<String, Map<String, String>> localizedText = {
    'tm': {
      'title': 'Load Board TM',
      'sub': 'Ýük we eltip bermek platformasy',
      'enter_phone': 'Telefon belgiňizi giriziň',
      'get_code': 'SMS kody almak',
      'enter_code': 'SMS kody giriziň',
      'verify': 'Tassyklamak',
    },
    'ru': {
      'title': 'Load Board TM',
      'sub': 'Платформа логистики и доставок',
      'enter_phone': 'Введите ваш номер телефона',
      'get_code': 'Получить SMS-код',
      'enter_code': 'Введите код из SMS',
      'verify': 'Подтвердить и войти',
    },
    'en': {
      'title': 'Load Board TM',
      'sub': 'Logistics & Delivery Board',
      'enter_phone': 'Enter your phone number',
      'get_code': 'Get SMS Code',
      'enter_code': 'Enter SMS code',
      'verify': 'Verify & Enter',
    }
  };

  @override
  Widget build(BuildContext context) {
    var t = localizedText[selectedLang]!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Выбор языка
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _langButton('🇹🇲 TM', 'tm'),
                  const SizedBox(width: 8),
                  _langButton('🇷🇺 RU', 'ru'),
                  const SizedBox(width: 8),
                  _langButton('🇬🇧 EN', 'en'),
                ],
              ),
              const Spacer(),
              const Center(
                child: Text('🚚', style: TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 12),
              Text(
                t['title']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                t['sub']!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 40),

              if (!isCodeSent) ...[
                Text(t['enter_phone']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Text('🇹🇲 +993 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    hintText: '6X XX-XX-XX',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_phoneController.text.isNotEmpty) {
                      setState(() => isCodeSent = true);
                    }
                  },
                  child: Text(t['get_code']!, style: const TextStyle(fontSize: 16)),
                ),
              ] else ...[
                Text(t['enter_code']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: const InputDecoration(
                    hintText: '• • • •',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          userPhone: '+993 ${_phoneController.text}',
                          currentLang: selectedLang,
                        ),
                      ),
                    );
                  },
                  child: Text(t['verify']!, style: const TextStyle(fontSize: 16)),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langButton(String label, String langCode) {
    bool isSelected = selectedLang == langCode;
    return InkWell(
      onTap: () => setState(() => selectedLang = langCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. ГЛАВНЫЙ ЭКРАН (КАРТА, РАДИУС, ГРУЗЫ)
// ==========================================
class HomeScreen extends StatefulWidget {
  final String userPhone;
  final String currentLang;

  const HomeScreen({super.key, required this.userPhone, required this.currentLang});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isShipperMode = false; // false = Доставщик, true = Грузоотправитель
  double searchRadiusKm = 10.0; // Слайдер от 0.5 до 100 км
  String selectedTransport = 'Все';
  late String lang;

  // Демо-данные опубликованных грузов
  List<Map<String, dynamic>> loads = [
    {
      'id': '1',
      'title': 'Запчасти (Коробка 8 кг)',
      'origin': 'Ашхабад, 11 мкр',
      'dest': 'Мары, Автовокзал',
      'pickupTime': 'Сегодня до 16:00',
      'deliverTime': 'Завтра до 11:00',
      'transport': '🚗 На машине',
      'comment': 'Нужен большой багажник типа Toyota Sienna.',
      'price': '150 TMT',
      'phone': '+993 65 123456',
      'distanceKm': 1.2,
      'isMyLoad': false,
    },
    {
      'id': '2',
      'title': 'Документы в конверте',
      'origin': 'Ашхабад, Тёкучка (Гулистан)',
      'dest': 'Ашхабад, Мир 2',
      'pickupTime': 'Прямо сейчас',
      'deliverTime': 'В течение 2 часов',
      'transport': '🚶 Пешком',
      'comment': 'Быстрая передача в руки.',
      'price': '30 TMT',
      'phone': '+993 61 987654',
      'distanceKm': 0.8,
      'isMyLoad': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    lang = widget.currentLang;
  }

  @override
  Widget build(BuildContext context) {
    // Фильтрация грузов по радиусу и типу транспорта
    List<Map<String, dynamic>> filteredLoads = loads.where((load) {
      bool matchRadius = load['distanceKm'] <= searchRadiusKm;
      bool matchTransport = selectedTransport == 'Все' || load['transport'].contains(selectedTransport);
      return matchRadius && matchTransport;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        title: const Text('Load Board TM', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (lang == 'tm') lang = 'ru';
                else if (lang == 'ru') lang = 'en';
                else lang = 'tm';
              });
            },
            child: Text(
              lang == 'tm' ? '🇹🇲 TM' : (lang == 'ru' ? '🇷🇺 RU' : '🇬🇧 EN'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Переключатель Роли (DAT Style)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(lang == 'tm' ? '🚚 Men Äkidiji' : '🚚 Я Доставщик')),
                    selected: !isShipperMode,
                    selectedColor: Colors.blue[100],
                    onSelected: (val) => setState(() => isShipperMode = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(lang == 'tm' ? '📦 Ýük ugradýan' : '📦 Я Отправитель')),
                    selected: isShipperMode,
                    selectedColor: Colors.orange[100],
                    onSelected: (val) => setState(() => isShipperMode = true),
                  ),
                ),
              ],
            ),
          ),

          if (!isShipperMode) ...[
            // 2. Имитация Карта Google Maps + Слайдер Радиуса
            Container(
              height: 140,
              width: double.infinity,
              color: Colors.blueGrey[100],
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.map, size: 100, color: Colors.black12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.my_location, color: Colors.blue, size: 36),
                      Container(
                        padding: const EdgeInsets.all(4),
                        color: Colors.white70,
                        child: Text(
                          'Текущая геолокация: Ашхабад (Радиус: ${searchRadiusKm < 1 ? '${(searchRadiusKm * 1000).toInt()} м' : '${searchRadiusKm.toStringAsFixed(1)} км'})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Слайдер радиуса (500 м - 100 км)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🎯 Радиус поиска:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        searchRadiusKm < 1 ? '${(searchRadiusKm * 1000).toInt()} метров' : '${searchRadiusKm.toStringAsFixed(1)} км',
                        style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: searchRadiusKm,
                    min: 0.5,
                    max: 100.0,
                    divisions: 199,
                    onChanged: (val) => setState(() => searchRadiusKm = val),
                  ),
                ],
              ),
            ),

            // Фильтр 6 видов транспорта
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  'Все', '🚶 Пешком', '🚲 Вело', '🚌 Автобус', '🚗 На машине', '🚐 Газель', '🚛 Грузовик'
                ].map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(type),
                      selected: selectedTransport == type || (type == 'Все' && selectedTransport == 'Все'),
                      onSelected: (val) => setState(() => selectedTransport = type),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Список Найдено
            Expanded(
              child: filteredLoads.isEmpty
                  ? const Center(child: Text('В выбранном радиусе нет грузов'))
                  : ListView.builder(
                      itemCount: filteredLoads.length,
                      itemBuilder: (ctx, idx) {
                        var item = filteredLoads[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(item['price'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const Divider(),
                                Text('📍 Откуда: ${item['origin']} (${item['distanceKm']} км от вас)'),
                                Text('🏁 Куда: ${item['dest']}'),
                                Text('🕒 Забрать: ${item['pickupTime']} | Доставить: ${item['deliverTime']}'),
                                Text('🚚 Транспорт: ${item['transport']}'),
                                if (item['comment'].isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.all(6),
                                    color: Colors.yellow[100],
                                    child: Text('💬 Требования: ${item['comment']}', style: const TextStyle(fontSize: 12)),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (item['isMyLoad'] == true)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                        icon: const Icon(Icons.delete),
                                        label: const Text('Удалить (Снять)'),
                                        onPressed: () {
                                          setState(() => loads.removeAt(idx));
                                        },
                                      )
                                    else
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                        icon: const Icon(Icons.call),
                                        label: const Text('ПОЗВОНИТЬ'),
                                        onPressed: () {},
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ] else ...[
            // 3. Форма отправки груза
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Подать новый груз', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const TextField(decoration: InputDecoration(labelText: 'Что везем? (например: Коробки, Оборудование)', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    const TextField(decoration: InputDecoration(labelText: 'Откуда забрать (город, этрап, точка)', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    const TextField(decoration: InputDecoration(labelText: 'Куда доставить', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    const TextField(decoration: InputDecoration(labelText: 'Время забора и доставки', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    const TextField(decoration: InputDecoration(labelText: 'Требования к машине (например: Sienna, крытая Газель)', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    const TextField(decoration: InputDecoration(labelText: 'Оплата (TMT)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
                      onPressed: () {
                        setState(() {
                          loads.add({
                            'id': DateTime.now().toString(),
                            'title': 'Новый груз (Моё)',
                            'origin': 'Ашхабад',
                            'dest': 'Мары',
                            'pickupTime': 'Сегодня',
                            'deliverTime': 'Завтра',
                            'transport': '🚗 На машине',
                            'com
