//
//  StrudyWidget.swift
//  StrudyWidget
//
//  Created by 안병욱 on 11/8/23.
//

import WidgetKit
import SwiftUI
import Charts

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> StrudyEntry {
        StrudyEntry(date: Date(), data: [YamlData(date: Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date()), subject: [Subject(subject: "토익", time: 0.0)], totalTime: 0.0)])
    }

    func getSnapshot(in context: Context, completion: @escaping (StrudyEntry) -> ()) {
        let entry = StrudyEntry(date: Date(), data: [YamlData(date: Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date()), subject: [Subject(subject: "토익", time: 0.0)], totalTime: 0.0)])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        getData { data in
            let date = Date()
            let data = data
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: date)
            let timeline = Timeline(entries: [data], policy: .after(nextUpdate ?? Date()))
            completion(timeline)
        }
    }
}

struct StrudyEntry: TimelineEntry {
    let date: Date
    let data: [YamlData]
}

struct StrudyWidgetEntryView : View {
    var entry: Provider.Entry
    var sub: String
    var clockColor = Color(red: 216/255, green: 63/255, blue: 49/255)
    @State var subjects: [String] = []

    var body: some View {
        VStack {
            Text("\(Int(entry.data.first?.subject.first?.time ?? 0.0))")
            Chart(entry.data, id: \.self) { data in
                
                AreaMark(
                    x: .value("Day", Calendar.current.date(from: data.date)!, unit: .day),
                    y: .value("Time", (data.subject.filter({$0.subject == sub}).first?.time ?? 0.0)/3600)
                )
                .foregroundStyle(
                    LinearGradient(colors: [clockColor.opacity(0.5), .clear.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                )
                PointMark(
                    x: .value("Day", Calendar.current.date(from: data.date)!, unit: .day),
                    y: .value("Time", (data.subject.filter({$0.subject == sub}).first?.time ?? 0.0)/3600)
                )
                .foregroundStyle(clockColor)
                LineMark(
                    x: .value("Day", Calendar.current.date(from: data.date)!, unit: .day),
                    y: .value("Time", (data.subject.filter({$0.subject == sub}).first?.time ?? 0.0)/3600)
                )
                .foregroundStyle(clockColor)
                
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                    AxisValueLabel() {
                        if let doubleValue = value.as(Double.self) {
                            let times = String(format: "%.2f", doubleValue)
                            Text("\(times) 시간")
                                .font(.system(size: 10))
                        }
                    }
                    AxisTick()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 2)) { value in
                    //AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.0))
                    //AxisValueLabel(format: .dateTime.month().day())
                    //AxisValueLabel("    일", centered: false)
                    
                    if let date = value.as(Date.self) {
                        //let month = Calendar.current.component(.month, from: date)
                        AxisValueLabel {
                            if value.index == 0 {
                                VStack{
                                    HStack(alignment: .center, spacing: 0){
                                        Text(date, format: .dateTime.day())
                                        Text("일")
                                    }
                                    /*
                                     HStack(alignment: .center, spacing: 0){
                                     Text("\(month)월")
                                     .font(.caption2)
                                     }
                                     */
                                }
                            } else {
                                HStack(alignment: .center, spacing: 0){
                                    Text(date, format: .dateTime.day())
                                    Text("일")
                                }
                            }
                        }
                    } else {
                        AxisValueLabel(format: .dateTime.month().day())
                        AxisValueLabel("    일", centered: false)
                    }
                    
                }
            }
        }
    }
}

struct StrudyWidget: Widget {
    let kind: String = "StrudyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                StrudyWidgetEntryView(entry: entry, sub: "토익")
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                StrudyWidgetEntryView(entry: entry, sub: "토익")
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

func getData(completion: @escaping (StrudyEntry) -> Void ) {
    let data = loadData()
    let sevenDays = get7DaysTotalTime(data: data.data)
    completion(StrudyEntry(date: Date(), data: sevenDays))
}

func get7DaysTotalTime(data: [YamlData]) -> [YamlData] {
    let calander = Calendar(identifier: .gregorian)
    var dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
    dateComponent.timeZone = NSTimeZone.system
    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Calendar.current.date(from: dateComponent)!) ?? Date()
    return data.filter{Calendar.current.date(from: $0.date)!.compare(sevenDaysAgo) == .orderedDescending}
}

func loadData() -> Records {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    print(url)
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
