import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FlutterLocalNotificationsPlugin fltrNotification;
  var task;
  String? _selectedTime;
  int? _selectedValue;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    var androidInitialize = new AndroidInitializationSettings('icon');
    var iosInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iosInitialize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initializationSettings,
        onSelectNotification: (payload) {
      notificationSelected(payload!);
    });
  }

  Future _showDailyScheduledNotification(
      {required DateTime scheduledTime}) async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Programming",
        importance: Importance.max);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    fltrNotification.zonedSchedule(
        0,
        "Task",
        "Task created",
        _scheduleDaily(Time(8)),

        // tz.TZDateTime.from(scheduledTime, tz.local),
        generalNotificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  static tz.TZDateTime _scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute, time.second);
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(Duration(days: 1))
        : scheduledDate;
  }

  Future _showScheduleNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Programming",
        importance: Importance.max);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    var scheduledTime;
    if (_selectedTime == "Hour") {
      scheduledTime = DateTime.now().add(Duration(hours: _selectedValue!));
    } else if (_selectedTime == "Minutes") {
      scheduledTime = DateTime.now().add(Duration(minutes: _selectedValue!));
    } else {
      scheduledTime = DateTime.now().add(Duration(seconds: _selectedValue!));
    }

    fltrNotification.schedule(
        1, "task", task, scheduledTime, generalNotificationDetails,
        payload: "task");
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Programming",
        importance: Importance.max);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);

    await fltrNotification.show(
        0, "task", "task created", generalNotificationDetails,
        payload: "Task");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            color: Colors.amber[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    onChanged: (val) {
                      // setState(() {
                      task = val;
                      // });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton(
                        value: _selectedTime,
                        items: [
                          DropdownMenuItem(
                              child: Text("Seconds"), value: "Seconds"),
                          DropdownMenuItem(
                              child: Text("Minutes"), value: "Minutes"),
                          DropdownMenuItem(child: Text("Hour"), value: "Hour")
                        ],
                        hint: Text("Select Time",
                            style: TextStyle(color: Colors.black)),
                        onChanged: (val) {
                          setState(() {
                            _selectedTime = val as String?;
                          });
                        }),
                    DropdownButton(
                        value: _selectedValue,
                        items: [
                          DropdownMenuItem(child: Text("1"), value: 1),
                          DropdownMenuItem(child: Text("2"), value: 2),
                          DropdownMenuItem(child: Text("3"), value: 3)
                        ],
                        hint: Text("Select value",
                            style: TextStyle(color: Colors.black)),
                        onChanged: (val) {
                          setState(() {
                            _selectedValue = val as int?;
                          });
                        }),
                  ],
                ),
                ElevatedButton(
                    onPressed: _showScheduleNotification,
                    child: Text('Set task with notification')),
                ElevatedButton(
                    onPressed: () {
                      _showDailyScheduledNotification(
                          scheduledTime:
                              DateTime.now().add(Duration(seconds: 2)));
                      print(DateTime.now());
                    },
                    child: Text('Daily Scheduled Notifications')),
                ElevatedButton(
                    onPressed: _showNotification,
                    child: Text('Simple notification')),
              ],
            )));
  }

  Future notificationSelected(String payload) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text("Notification: $payload"),
            ));
  }
}
