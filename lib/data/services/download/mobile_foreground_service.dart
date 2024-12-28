import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/utils/log.dart';
import 'package:permission_handler/permission_handler.dart';

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    logger.info('Mobile foreground service onStart(starter: ${starter.name})');
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {}

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    logger.info('Mobile foreground service onDestroy');
  }
}

Future<void> _requestPermissions() async {
  // Android 13+, you need to allow notification permission to display foreground service notification.
  //
  // iOS: If you need notification, ask for permission.
  // final NotificationPermission notificationPermission =
  //     await FlutterForegroundTask.checkNotificationPermission();
  // if (notificationPermission != NotificationPermission.granted) {
  //   await FlutterForegroundTask.requestNotificationPermission();
  // }

  var notificationStatus = await Permission.notification.request();
  if (notificationStatus.isDenied) {
    logger.info('Permission: Notification permission denied.');
  } else if (notificationStatus.isPermanentlyDenied) {
    logger.info('Permission: Notification permission permanently denied.');
    openAppSettings();
  } else if (notificationStatus.isGranted) {
    logger.info('Permission: Notification permission granted.');
  }

  if (Platform.isAndroid) {
    // Android 12+, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Use this utility only if you provide services that require long-term survival,
    // such as exact alarm service, healthcare service, or Bluetooth communication.
    //
    // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
    // Using this permission may make app distribution difficult due to Google policy.
    if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      // When you call this function, will be gone to the settings page.
      // So you need to explain to the user why set it.
      await FlutterForegroundTask.openAlarmsAndRemindersSettings();
    }
  }
}

void _initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

void initForegroundService() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _requestPermissions();
    _initService();
  });
}

Future<ServiceRequestResult> startService() async {
  logger.info('Mobile foreground service startService');
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: 1,
      notificationTitle: 'download.download-manager'.i18n,
      notificationText: 'Tap to return to the app',
      notificationIcon: null,
      notificationButtons: null,
      notificationInitialRoute: '/settings/download/download_manager',
      callback: startCallback,
    );
  }
}

Future<bool> isRunningService() {
  return FlutterForegroundTask.isRunningService;
}

Future<ServiceRequestResult> stopService() {
  return FlutterForegroundTask.stopService();
}
