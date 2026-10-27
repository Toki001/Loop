package com.jameskierdoliguez.loop

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.ApplicationInfo

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.jameskierdoliguez.loop/storage").setMethodCallHandler { call, result ->
            if (call.method == "configure" || call.method == "inspect") {
                // App-private credential-protected filesDir is path_provider's
                // support directory. XML excludes both cloud and device transfer.
                result.success(mapOf(
                    "privateStorage" to !isDeviceProtectedStorage,
                    "backupExcluded" to (applicationInfo.flags and ApplicationInfo.FLAG_ALLOW_BACKUP == 0)
                ))
            } else {
                result.notImplemented()
            }
        }
    }
}
