import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.jameskierdoliguez.loop/storage",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "configure" || call.method == "inspect" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        let manager = FileManager.default
        var root = try manager.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                   appropriateFor: nil, create: call.method == "configure")
        if call.method == "configure" {
          var values = URLResourceValues()
          values.isExcludedFromBackup = true
          try root.setResourceValues(values)
          try manager.setAttributes([.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                                    ofItemAtPath: root.path)
          // Include existing M03 preferences and database sidecars on upgrade.
          if let children = manager.enumerator(at: root, includingPropertiesForKeys: [.isSymbolicLinkKey]) {
            for case let url as URL in children {
              if try url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink == true {
                children.skipDescendants()
                continue
              }
              try manager.setAttributes([.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                                        ofItemAtPath: url.path)
            }
          }
        }
        let excluded = try root.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup == true
        // Foundation may bridge the attribute as a raw string or typed value.
        // Missing simulator attributes remain missing; do not infer protection.
        func protectionAt(_ url: URL) throws -> String? {
          let value = try manager.attributesOfItem(atPath: url.path)[.protectionKey]
          return (value as? String) ?? (value as? FileProtectionType)?.rawValue
        }
        let protection = try protectionAt(root)
        #if targetEnvironment(simulator)
        let isSimulator = true
        #else
        let isSimulator = false
        #endif
        var checked = 0
        var allProtected = protection == FileProtectionType.completeUntilFirstUserAuthentication.rawValue
        if let children = manager.enumerator(at: root, includingPropertiesForKeys: [.isSymbolicLinkKey]) {
          for case let url as URL in children {
            if try url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink == true {
              children.skipDescendants()
              continue
            }
            let childProtection = try protectionAt(url)
            allProtected = allProtected && childProtection == FileProtectionType.completeUntilFirstUserAuthentication.rawValue
            checked += 1
          }
        }
        result(["privateStorage": true, "backupExcluded": excluded,
                "protection": protection ?? "unknown",
                "protectionPolicy": FileProtectionType.completeUntilFirstUserAuthentication.rawValue,
                "protectionInspectable": protection != nil, "isSimulator": isSimulator,
                "protectedEntriesChecked": checked, "allEntriesProtected": allProtected])
      } catch {
        result(FlutterError(code: "storage_unavailable", message: "Private storage is unavailable.", details: nil))
      }
    }
  }
}
