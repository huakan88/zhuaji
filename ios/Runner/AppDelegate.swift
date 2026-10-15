import Flutter
import UIKit
import UserNotifications
import WidgetKit

/// Shared with the WidgetKit extension in `ios/TodayWidget`.
/// The extension is not a build target yet: adding an App Group entitlement
/// without a Team ID breaks device signing. The host still stores the payload
/// under the group id so the extension can read it after the capability is on.
enum WidgetStore {
  static let channelName = "zhuaji/widget"
  static let suiteName = "group.com.maokangji.maokangji"
  static let payloadKey = "payload"
  static let routeKey = "pending_route"
  static var channel: FlutterMethodChannel?

  static var defaults: UserDefaults {
    UserDefaults(suiteName: suiteName) ?? .standard
  }

  static func storePayload(_ json: String) {
    defaults.set(json, forKey: payloadKey)
  }

  static func accept(_ route: String) -> Bool {
    route.hasPrefix("/")
      && !route.hasPrefix("//")
      && !route.contains("://")
      && !route.contains("\n")
      && route.count <= 300
  }

  static func storeRoute(_ route: String) {
    guard accept(route) else { return }
    defaults.set(route, forKey: routeKey)
  }

  static func consumeRoute() -> String? {
    let route = defaults.string(forKey: routeKey)
    defaults.removeObject(forKey: routeKey)
    guard let route, accept(route) else { return nil }
    return route
  }

  /// Cold start keeps the route for Dart `takeRoute`. A later open (the app
  /// is already running) is delivered once on the `open` method.
  static func capture(_ contexts: Set<UIOpenURLContext>, warm: Bool) {
    for context in contexts {
      capture(context.url, warm: warm)
    }
  }

  static func capture(_ url: URL, warm: Bool) {
    guard url.scheme == "zhuaji", url.host == "open" else { return }
    guard
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let route = components.queryItems?.first(where: { $0.name == "route" })?.value
    else { return }
    if warm, let channel {
      guard accept(route) else { return }
      defaults.removeObject(forKey: routeKey)
      channel.invokeMethod("open", arguments: route)
      return
    }
    storeRoute(route)
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: WidgetStore.channelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    WidgetStore.channel = channel
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "update":
        let json = (call.arguments as? [String: Any])?["json"] as? String ?? ""
        WidgetStore.storePayload(json)
        WidgetCenter.shared.reloadAllTimelines()
        result(nil)
      case "takeRoute":
        result(WidgetStore.consumeRoute())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
