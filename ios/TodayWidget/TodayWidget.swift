// 今天的事。这是 WidgetKit 源码，还没有加进 Xcode 目标。
// 没有 Team ID 时加上 App Group，签名会失败，所以不要把这个文件编进 Runner。
//
// 在 Mac 上、有付费开发者账号之后：
// 1. 用 ios/Runner.xcworkspace 打开工程。
// 2. File > New > Target > Widget Extension，名字用 TodayWidget，部署目标 iOS 15.5。
// 3. 用这个文件替换向导生成的 Swift，Info.plist 指向同目录的 Info.plist。
// 4. Runner 和 TodayWidget 都打开 App Groups，填 group.com.maokangji.maokangji。
//    描述文件可以用同目录的 entitlements，或在 Signing & Capabilities 里点出来。
// 5. 不要把这个文件加进 Runner 目标，否则会和 AppDelegate 抢 @main。
//
// 小组件整块可点，打开对应页面。和 Android 一样，没有逐条「完成」按钮。
// 互动按钮要 iOS 17，这里不做。

import WidgetKit
import SwiftUI

private let suiteName = "group.com.maokangji.maokangji"
private let payloadKey = "payload"

struct TodayEntry: TimelineEntry {
  let date: Date
  let today: String
  let next: String
  let route: String
  let appearance: String
}

struct TodayProvider: TimelineProvider {
  func placeholder(in context: Context) -> TodayEntry {
    TodayEntry(
      date: Date(),
      today: "今天没什么要办",
      next: "还没有",
      route: "/calendar",
      appearance: "system"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
    completion(load())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
    let entry = load()
    let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(next)))
  }

  func load() -> TodayEntry {
    let raw = UserDefaults(suiteName: suiteName)?.string(forKey: payloadKey)
    return parse(raw)
  }
}

private func parse(_ raw: String?) -> TodayEntry {
  let empty = TodayEntry(
    date: Date(),
    today: "今天没什么要办",
    next: "还没有",
    route: "/calendar",
    appearance: "system"
  )
  guard
    let raw,
    let data = raw.data(using: .utf8),
    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
  else { return empty }

  var lines: [String] = []
  if let today = json["today"] as? [String] {
    lines = today.filter { !$0.isEmpty }
  } else if let today = json["today"] as? [Any] {
    lines = today.compactMap { $0 as? String }.filter { !$0.isEmpty }
  }
  let body = lines.isEmpty ? "今天没什么要办" : lines.joined(separator: "\n")
  let next = (json["next"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "还没有"
  var route = (json["route"] as? String) ?? "/calendar"
  if !route.hasPrefix("/") || route.hasPrefix("//") || route.contains("://") {
    route = "/calendar"
  }
  let appearance = (json["appearance"] as? String) ?? "system"
  let mode = appearance == "light" || appearance == "dark" ? appearance : "system"
  return TodayEntry(date: Date(), today: body, next: next, route: route, appearance: mode)
}

private struct ForceScheme: ViewModifier {
  let appearance: String

  @ViewBuilder
  func body(content: Content) -> some View {
    switch appearance {
    case "light":
      content.environment(\.colorScheme, .light)
    case "dark":
      content.environment(\.colorScheme, .dark)
    default:
      content
    }
  }
}

struct TodayWidgetView: View {
  var entry: TodayEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("肉垫本")
        .font(.caption)
        .foregroundColor(Color("WidgetMuted"))
      Text(entry.today)
        .font(.subheadline)
        .foregroundColor(Color("WidgetInk"))
        .lineLimit(4)
      Text("下一个：\(entry.next)")
        .font(.caption)
        .foregroundColor(Color("WidgetMuted"))
        .lineLimit(2)
    }
    .padding(12)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetBackground(Color("WidgetPaper"))
    .modifier(ForceScheme(appearance: entry.appearance))
    .widgetURL(link(entry.route))
  }

  func link(_ route: String) -> URL? {
    var parts = URLComponents()
    parts.scheme = "zhuaji"
    parts.host = "open"
    parts.queryItems = [URLQueryItem(name: "route", value: route)]
    return parts.url
  }
}

extension View {
  @ViewBuilder
  func widgetBackground(_ color: Color) -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(color, for: .widget)
    } else {
      background(color)
    }
  }
}

struct TodayWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "TodayWidget", provider: TodayProvider()) { entry in
      TodayWidgetView(entry: entry)
    }
    .configurationDisplayName("今天的事")
    .description("今天要办的，和下一个提醒。")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct TodayWidgetBundle: WidgetBundle {
  var body: some Widget {
    TodayWidget()
  }
}
