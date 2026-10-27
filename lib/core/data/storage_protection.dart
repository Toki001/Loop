import 'dart:io';

import 'package:flutter/services.dart';

import 'local_failure.dart';

class StorageProtection {
  const StorageProtection();
  static const _channel = MethodChannel('com.jameskierdoliguez.loop/storage');

  /// Native adapter chooses its own sandbox directory. No arbitrary path input.
  Future<void> configure() => guardLocal(() async {
    if (!Platform.isIOS && !Platform.isAndroid) return; // Host test filesystem.
    final result = await _channel.invokeMapMethod<String, Object?>('configure');
    if (result?['privateStorage'] != true ||
        result?['backupExcluded'] != true) {
      throw const LocalFailure(LocalFailureKind.unavailable);
    }
    // Simulator volumes can accept setAttributes but return no protection
    // attribute. This is reported as unverified, never manufactured as a pass.
    // Physical iOS builds still require the actual attribute readback.
    if (Platform.isIOS &&
        result?['isSimulator'] != true &&
        (result?['protection'] !=
                'NSFileProtectionCompleteUntilFirstUserAuthentication' ||
            result?['allEntriesProtected'] != true)) {
      throw const LocalFailure(LocalFailureKind.unavailable);
    }
  });

  Future<Map<String, Object?>> inspect() => guardLocal(
    () async => Map.unmodifiable(
      await _channel.invokeMapMethod<String, Object?>('inspect') ?? {},
    ),
  );
}
