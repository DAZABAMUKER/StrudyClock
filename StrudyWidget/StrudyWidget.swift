//
//  StrudyWidget.swift
//  StrudyWidget
//
//  Created by 안병욱 on 11/7/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetModels {
        WidgetModels(date: Date(), data: [])
    }
    
//    func placeholder(in context: Context) -> WidgetModels {
//        WidgetModels(date: Date(), data: [])
//    }
//
//    func snapshot(for configuration: [YamlData], in context: Context) async -> WidgetModels {
//        WidgetModels(date: Date(), data: configuration)
//    }
//    func timeline(for configuration: [YamlData], in context: Context) async -> Timeline<WidgetModels> {
//        var entries: [WidgetModels] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = WidgetModels(date: entryDate, data: configuration)
//            entries.append(entry)
//        }
//
//        return Timeline(entries: entries, policy: .atEnd)
//    }
    func getSnapshot(in context: Context, completion: @escaping (WidgetModels) -> Void) {
        let loadingData = WidgetModels(date: Date(), data: [YamlData(date: Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date()), subject: [Subject(subject: "토익", time: 3600.0)], totalTime: 3600.0)])
        completion(loadingData)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetModels>) -> Void) {
        getData { modelData in
            let date = modelData.date
            let data = modelData
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: date)
            let timeline = Timeline(entries: [data], policy: .after(nextUpdate ?? Date()))
        }
    }
}

func getData(completion: @escaping (WidgetModels) -> Void ) {
    let data = loadData()
    completion(WidgetModels(date: Date(), data: data.data))
}

func loadData() -> Records {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let recordJson = url.appendingPathComponent("record", conformingTo: .json)
    let calander = Calendar(identifier: .gregorian)
    var dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
    dateComponent.timeZone = NSTimeZone.system
    if FileManager.default.fileExists(atPath: recordJson.path) {
        guard let js = NSData(contentsOf: recordJson) else { return Records(data: [], totalTime: 0.0) }
        let decoder = JSONDecoder()
        guard let myData = try? decoder.decode(Records.self, from: js as Data) else {
            return Records(data: [], totalTime: 0.0)
        }
        return myData
    } else {
        return Records(data: [], totalTime: 0.0)
    }
}
struct WidgetModels: TimelineEntry {
    let date: Date
    let data: [YamlData]
}

struct StrudyWidgetEntryView : View {
    var entry: WidgetModels

    var body: some View {
        VStack {
            Text("check one two")
        }
    }
}

struct StrudyWidget: Widget {
    let kind: String = "StrudyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Graph", provider: Provider()) { data in
            StrudyWidgetEntryView(entry: data)
        }
        .description(Text("test"))
        .supportedFamilies([.systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

struct Records: Codable {
    var data: [YamlData]
    var totalTime: Double
}

struct YamlData: Codable {
    var date: DateComponents
    var subject: [Subject]
    var totalTime: Double
}
extension YamlData: Hashable {
    static func == (lhs: YamlData, rhs: YamlData) -> Bool {
        return lhs.date == rhs.date && lhs.subject == rhs.subject && lhs.totalTime == rhs.totalTime
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(subject)
        hasher.combine(totalTime)
    }
    
}

struct Subject: Codable,Equatable, Hashable {
    var subject: String
    var time: Double
    
}

#Preview(as: .systemSmall) {
    StrudyWidget()
} timeline: {
    WidgetModels(date: Date(), data: [YamlData(date: Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date()), subject: [Subject(subject: "토익", time: 3600.0)], totalTime: 3600.0)])
    WidgetModels(date: Date(), data: [YamlData(date: Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date()), subject: [Subject(subject: "토익", time: 3600.0)], totalTime: 3600.0)])
}
