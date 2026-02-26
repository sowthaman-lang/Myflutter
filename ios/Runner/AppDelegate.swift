import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let defaultsChannel = "my_flutter/user_defaults"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: defaultsChannel, binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        let defaults = UserDefaults.standard

        switch call.method {
        case "getString":
          guard let args = call.arguments as? [String: Any],
                let key = args["key"] as? String else {
            result(FlutterError(code: "bad_args", message: "Missing key", details: nil))
            return
          }
          result(defaults.string(forKey: key))

        case "setString":
          guard let args = call.arguments as? [String: Any],
                let key = args["key"] as? String,
                let value = args["value"] as? String else {
            result(FlutterError(code: "bad_args", message: "Missing key/value", details: nil))
            return
          }
          defaults.set(value, forKey: key)
          result(nil)

        case "clear":
          if let bundleId = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleId)
          }
          defaults.synchronize()
          result(nil)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
