import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:logger/web.dart';
import 'package:people_counter/notification_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationHelper.init();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  int masuk = 0;
  int keluar = 0;
  int lastMasuk = 0;
  int lastKeluar = 0;
  Timer? _timer;
  final logger = Logger();

  String formattedDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _listenToRealtimeUpdates();
    _startPeriodic();
  }

  void _startPeriodic() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (masuk != lastMasuk || keluar != lastKeluar) {
        NotificationHelper.scheduledNotification(
          'Jumlah pengunjung saat ini',
          'Masuk: $masuk, Keluar: $keluar',
        );
        logger.i("Masuk: $masuk, Keluar: $keluar");
        setState(() {
          lastMasuk = masuk;
          lastKeluar = keluar;
        });
      } else {
        logger.i("Tidak ada pengunjung masuk atau keluar");
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _listenToRealtimeUpdates() {
    _ref.child('data').onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          masuk = data['down'] ?? 0;
          keluar = data['up'] ?? 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Counter People App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Jumlah Pengunjung',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Text(formattedDate),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Masuk',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            '$masuk',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 60,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Keluar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            '$keluar',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 60,
            ),
          ),
        ],
      )),
    );
  }
}
