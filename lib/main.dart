import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void showNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var android = AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: android);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Reminder',
    'It\'s time for your task!',
    platformChannelSpecifics,
    payload: 'item x',
  );
}

Future<void> checkPermissions() async {
  var notificationPermission = await Permission.notification.status;

  if (!notificationPermission.isGranted) {
    await Permission.notification.request();

    if (await Permission.notification.isDenied) {
      openAppSettings();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkPermissions();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationScheduler(),
    );
  }
}

class NotificationScheduler extends StatefulWidget {
  @override
  _NotificationSchedulerState createState() => _NotificationSchedulerState();
}

class _NotificationSchedulerState extends State<NotificationScheduler> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleNotification() async {
    await checkPermissions();

    DateTime now = DateTime.now();
    DateTime notificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (notificationTime.isBefore(now)) {
      notificationTime = notificationTime.add(Duration(days: 1));
    }

    Duration delay = notificationTime.difference(now);

    Future.delayed(delay, showNotification);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification scheduled for ${_selectedTime.format(context)}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Selected time: ${_selectedTime.format(context)}',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Select Time'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: Text('Schedule Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
