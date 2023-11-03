import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager{
  final FlutterLocalNotificationsPlugin  notificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> initNotification() async{
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings initializationIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload){},
    );
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationIos,
    );
    await notificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (details){}
    );
  }
  Future<void> simpleNotification() async{
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      'channel_Id',
      'channel_title',
      priority: Priority.high,
      importance: Importance.max,
      // channelShowBadge: true,
      icon: ''
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(0, 'Simple Notification', 'NewMessage', notificationDetails);
  }
  Future<void> bigPictureNotification() async{
    BigPictureStyleInformation bigPictureStyleInformation = const BigPictureStyleInformation(
      DrawableResourceAndroidBitmap(''),
      contentTitle: '',
      largeIcon: DrawableResourceAndroidBitmap('')
    );
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'big_Picture_Id',
        'big_Picture_title',
        priority: Priority.high,
        importance: Importance.max,
        styleInformation: bigPictureStyleInformation,
        // channelShowBadge: true,
        // icon: ''
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(1, 'Big_Picture Notification', 'Big_Pic NewMessage', notificationDetails);
  }
  Future<void> multipleNotification() async{
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
        'channel_Id',
        'channel_title',
        priority: Priority.high,
        importance: Importance.max,
        groupKey: 'commonMessage'
        // channelShowBadge: true,
        // icon: ''
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(0, 'New Notification', 'NewMessage', notificationDetails);
  }
}