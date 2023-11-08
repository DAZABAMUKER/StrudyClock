//
//  GraphDetailView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 11/7/23.
//

import SwiftUI
import Charts

struct GraphDetailView: View {
    
    @State var data: [YamlData]
    @State var scWidth = 0.0
    @State var scHeight = 0.0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var total = ""
    @State var graphWidth = 0.0
    @State var over = false
    
    func secondsToHoursMinutesSeconds(_ seconds: Int = 0) -> String {
        let timeDict: [Times : Int] = [.Hour : seconds / 3600, .Minute : (seconds % 3600) / 60, .Second : (seconds % 3600) % 60 ]
        var results = ""
        if seconds < 3600 {
            results = "\(String(format:"%02d",(timeDict[.Minute] ?? 0) + 60 * (timeDict[.Hour] ?? 0)))분 \(String(format:"%02d",timeDict[.Second] ?? 0))초"
        } else {
            results = "\(String(format:"%02d",timeDict[.Hour] ?? 0))시간 \(String(format:"%02d",timeDict[.Minute] ?? 0))분 \(String(format:"%02d",timeDict[.Second] ?? 0))초"
        }
        return results
    }
    func timeCal() -> Bool {
        let calander = Calendar(identifier: .gregorian)
        var dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
        dateComponent.timeZone = NSTimeZone.system
        let daysAgo = Calendar.current.date(byAdding: .day, value: -20, to: Calendar.current.date(from: dateComponent)!) ?? Date()
        let results = Calendar.current.date(from: self.data.first?.date ?? dateComponent)!.compare(daysAgo) == .orderedAscending
        print(results)
        return results
    }
    
    var body: some View {
        ZStack{
            GeometryReader{ geometry in
                ZStack{}.onAppear() {
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    //print(geometry.size.height)
                }
                .onChange(of: geometry.size) { _ in
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    print(geometry.size.height)
                    print(geometry.size.width)
                    self.total = secondsToHoursMinutesSeconds(Int(self.data.last?.totalTime ?? 0.0))
                    self.graphWidth = self.scWidth*1.85 + (Double(self.data.count) / 20.0)
                    print(self.graphWidth)
                    self.over = timeCal()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in
                    self.scHeight = 0
                    self.scWidth = 0
                })
            }
            VStack{
                HStack{
                    Text("총 공부 시간")
                    .font(.title3)
                    .bold()
                    .padding()
                Spacer()
                Button{
                    dismiss()
                } label: {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .foregroundStyle(ClockColor[0])
                        .padding()
                }
            }
                ScrollView(.horizontal){
                    Chart(self.data, id: \.self) { time in
                        
                        AreaMark(
                            x: .value("Day", Calendar.current.date(from: time.date)!, unit: .day),
                            y: .value("Time", time.totalTime/3600)
                        )
                        .foregroundStyle(
                            LinearGradient(colors: [ClockColor[0].opacity(0.5), ClockColor[0].opacity(0.05)], startPoint: .top, endPoint: .bottom)
                        )
                        PointMark(x: .value("Day", Calendar.current.date(from: time.date)!, unit: .day), y: .value("Time", time.totalTime/3600))
                            .foregroundStyle(ClockColor[0])
                        LineMark(x: .value("Day", Calendar.current.date(from: time.date)!, unit: .day), y: .value("Time", time.totalTime/3600))
                            .foregroundStyle(ClockColor[0])
                    }
                    .frame(width: self.over ? self.graphWidth : self.scWidth*0.85, height: self.scWidth > self.scHeight ? self.scHeight*0.7 : self.scHeight*2/5)
                    //.chartScrollableAxes(.horizontal)
                    //.chartXVisibleDomain(length: 7 )
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 3)) { value in
                            AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                            AxisValueLabel() {
                                if let intValue = value.as(Double.self) {
                                    let times = String(format: "%.2f", intValue)
                                    Text("\(times) 시간")
                                        .font(.system(size: 10))
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 2)) { value in
                            //AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.0))
                            //AxisValueLabel(format: .dateTime.month().day())
                            //AxisValueLabel("    일", centered: false)
                            
                            if let date = value.as(Date.self) {
                                let month = Calendar.current.component(.month, from: date)
                                AxisValueLabel {
                                    if value.index == 0 {
                                        VStack(spacing: 5){
                                            
                                            HStack(alignment: .center, spacing: 0){
                                                Text(date, format: .dateTime.day())
                                                Text("일")
                                            }
                                            HStack(alignment: .center, spacing: 0){
                                                Text("\(month)월")
                                                    .font(.caption2)
                                            }
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
                                //AxisValueLabel("    일", centered: false)
                            }
                            
                        }
                    }
                    .padding()
                    .onAppear(){
                        
                    }
                    
                    
                }
            }
        }
    }
}


struct GraphSubDetailView: View {
    
    @State var datas: [YamlData]
    @State var scWidth = 0.0
    @State var scHeight = 0.0
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State var total = ""
    @State var graphWidth = 0.0
    @State var over = false
    @State var sub = ""
    
    func secondsToHoursMinutesSeconds(_ seconds: Int = 0) -> String {
        let timeDict: [Times : Int] = [.Hour : seconds / 3600, .Minute : (seconds % 3600) / 60, .Second : (seconds % 3600) % 60 ]
        var results = ""
        if seconds < 3600 {
            results = "\(String(format:"%02d",(timeDict[.Minute] ?? 0) + 60 * (timeDict[.Hour] ?? 0)))분 \(String(format:"%02d",timeDict[.Second] ?? 0))초"
        } else {
            results = "\(String(format:"%02d",timeDict[.Hour] ?? 0))시간 \(String(format:"%02d",timeDict[.Minute] ?? 0))분 \(String(format:"%02d",timeDict[.Second] ?? 0))초"
        }
        return results
    }
    func timeCal() -> Bool {
        let calander = Calendar(identifier: .gregorian)
        var dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
        dateComponent.timeZone = NSTimeZone.system
        let daysAgo = Calendar.current.date(byAdding: .day, value: -20, to: Calendar.current.date(from: dateComponent)!) ?? Date()
        let results = Calendar.current.date(from: self.datas.first?.date ?? dateComponent)!.compare(daysAgo) == .orderedAscending
        print(results)
        return results
    }
    
    var body: some View {
        ZStack{
            GeometryReader{ geometry in
                ZStack{}.onAppear() {
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    //print(geometry.size.height)
                }
                .onChange(of: geometry.size) { _ in
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                    print(geometry.size.height)
                    print(geometry.size.width)
                    self.total = secondsToHoursMinutesSeconds(Int(self.datas.last?.totalTime ?? 0.0))
                    self.graphWidth = self.scWidth*1.85 + (Double(self.datas.count) / 20.0)
                    print(self.graphWidth)
                    self.over = timeCal()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in
                    self.scHeight = 0
                    self.scWidth = 0
                })
            }
            VStack{
                HStack{
                    Text(self.sub)
                        .font(.title3)
                        .bold()
                        .padding()
                    Spacer()
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .foregroundStyle(ClockColor[0])
                            .padding()
                    }
                }
                ScrollView(.horizontal){
                    Chart(self.datas, id: \.self) { data in
                        AreaMark(
                            x: .value("Day", Calendar.current.date(from: data.date)!, unit: .day),
                            y: .value("Time", (data.subject.filter({$0.subject == sub}).first?.time ?? 0.0)/3600)
                        )
                        .foregroundStyle(
                            LinearGradient(colors: [ClockColor[0].opacity(0.5), ClockColor[0].opacity(0.05)], startPoint: .top, endPoint: .bottom)
                        )
                        PointMark(
                            x: .value("Day", Calendar.current.date(from: data.date)!, unit: .day),
                            y: .value("Time", (data.subject.filter({$0.subject == sub}).first?.time ?? 0.0)/3600)
                        )
                        .foregroundStyle(ClockColor[0])
                        LineMark(
                            x: .value("Day", Calendar.current.date(from: data.date)!, unit: .day),
                            y: .value("Time", (data.subject.filter({$0.subject == sub}).first?.time ?? 0.0)/3600)
                        )
                    }
                    .foregroundStyle(ClockColor[0])
                    .frame(width: self.over ? self.graphWidth : self.scWidth*0.85, height: self.scWidth > self.scHeight ? self.scHeight*0.7 : self.scHeight*2/5)
                    //.chartScrollableAxes(.horizontal)
                    //.chartXVisibleDomain(length: 7 )
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 3)) { value in
                            AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                            AxisValueLabel() {
                                if let intValue = value.as(Double.self) {
                                    let times = String(format: "%.2f", intValue)
                                    Text("\(times) 시간")
                                        .font(.system(size: 10))
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 2)) { value in
                            
                            if let date = value.as(Date.self) {
                                let month = Calendar.current.component(.month, from: date)
                                AxisValueLabel {
                                    if value.index == 0 {
                                        VStack(spacing: 5){
                                            
                                            HStack(alignment: .center, spacing: 0){
                                                Text(date, format: .dateTime.day())
                                                Text("일")
                                            }
                                            HStack(alignment: .center, spacing: 0){
                                                Text("\(month)월")
                                                    .font(.caption2)
                                            }
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
                                //AxisValueLabel("    일", centered: false)
                            }
                            
                        }
                    }
                    .padding()
                    .onAppear(){
                        
                    }
                }
                
            }
        }
    }
}
