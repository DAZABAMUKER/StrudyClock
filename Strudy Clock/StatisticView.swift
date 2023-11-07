//
//  StatisticView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
import Charts

struct StatisticView: View {
    
    @State var subjects: [String] = []
    
    @State var data: Records?
    @State var sevenTimeData: [YamlData] = []
    
    @State var scWidth = 0.0
    @State var scHeight = 0.0
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        //let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
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
                    
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification), perform: { _ in
                    self.scHeight = 0
                    self.scWidth = 0
                })
            }
            ScrollView{
                VStack{
                    Text("공부 통계")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(ClockColor[0])
                        .padding()
                    if self.data != nil {
                        VStack{
                            HStack{
                                Text("주간 공부 시간")
                                    .bold()
                                    .font(.title3)
                                Spacer()
                            }
                            .padding(.horizontal)
                            Chart(self.sevenTimeData, id: \.self) { time in
                                PointMark(
                                    x: .value("Day", Calendar.current.date(from: time.date)!, unit: .day),
                                    y: .value("Time", Int(time.totalTime/3600))
                                )
                                .foregroundStyle(
                                    Color.clear
                                )
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
                            
                            .frame(width: self.scWidth > self.scHeight ? self.scWidth*0.9 : self.scWidth*0.85, height: self.scWidth > self.scHeight ? self.scHeight*0.5 : self.scWidth*2/5)
                            //.chartScrollableAxes(.horizontal)
                            //.chartXVisibleDomain(length: 7 )
                            .chartYAxis {
                                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                                    AxisValueLabel() {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue) h")
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
                                                HStack(spacing: 5){
                                                    HStack(alignment: .center, spacing: 0){
                                                    Text("\(month)월")
                                                    .font(.caption2)
                                                    }
                                                    HStack(alignment: .center, spacing: 0){
                                                        Text(date, format: .dateTime.day())
                                                        Text("일")
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
                                        AxisValueLabel("    일", centered: false)
                                    }
                                    
                                }
                            }
                            .padding()

                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(self.colorScheme == .dark ? Color.black : Color.white)
                                    .shadow(radius: 10)
                            )
                        }
                        
                        //LazyVGrid(columns: columns, con<<#Content: View#>>tent: {
                        if self.scWidth > self.scHeight {
                            LazyVGrid(columns: columns) {
                                ForEach(self.subjects, id: \.self) { sub in
                                    HStack{
                                        VStack{
                                            HStack{
                                                Text(sub)
                                                    .fontWeight(.semibold)
                                                Spacer()
                                            }
                                            Chart(self.sevenTimeData, id: \.self) { data in
                                                PointMark(
                                                    x: .value("Day", Calendar.current.date(from: data.date)!, unit: .day),
                                                    y: .value("Time", Int(data.subject.filter({$0.subject == sub}).first?.time ?? 0.0)/3600)
                                                )
                                                .foregroundStyle(Color.clear)
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
                                                .foregroundStyle(ClockColor[0])
                                                
                                            }
                                            .chartYAxis {
                                                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                                                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                                                    AxisValueLabel() {
                                                        if let intValue = value.as(Int.self) {
                                                            Text("\(intValue) h")
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
                                        .padding(10)
                                        .frame(width: self.scWidth*0.2, height: self.scWidth*0.2)
                                        .background{
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(lineWidth: 3.0)
                                                .foregroundStyle(self.colorScheme == .dark ? ClockColor[0] : ClockColor[0])
                                        }
                                        VStack{
                                            Text("오늘 공부 시간")
                                                .STime(data: self.$sevenTimeData, sub: sub)
                                            //.STime(time: self.sevenTimeData.last?.subject.filter{$0.subject == sub}.first?.time ?? 0.0)
                                            /*
                                             Text("이번주 평균 시간")
                                             .STime(time: self.sevenTimeData.map{$0.subject}.flatMap{$0}.filter{$0.subject == sub}.map{$0.time}.reduce(0.0){$0 + $1} / 7.0)
                                             Text("이번주 총 시간")
                                             .STime(time: self.sevenTimeData.map{$0.subject}.flatMap{$0}.filter{$0.subject == sub}.map{$0.time}.reduce(0.0){$0 + $1})
                                             */
                                        }
                                        .foregroundStyle(.white)
                                        .frame(width: self.scWidth*0.2, height: self.scWidth*0.2)
                                        .background{
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(ClockColor[0])
                                                .shadow(radius: 5)
                                        }
                                    }
                                }
                            }
                        } else {
                            ForEach(self.subjects, id: \.self) { sub in
                                HStack{
                                    VStack{
                                        HStack{
                                            Text(sub)
                                                .fontWeight(.semibold)
                                            Spacer()
                                        }
                                        Chart(self.sevenTimeData, id: \.self) { data in
                                            PointMark(
                                                x: .value("Day", Calendar.current.date(from: data.date)!, unit: .day),
                                                y: .value("Time", Int(data.subject.filter({$0.subject == sub}).first?.time ?? 0.0)/3600)
                                            )
                                            .foregroundStyle(Color.clear)
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
                                            .foregroundStyle(ClockColor[0])
                                            
                                        }
                                        .chartYAxis {
                                            AxisMarks(values: .automatic(desiredCount: 3)) { value in
                                                AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                                                AxisValueLabel() {
                                                    if let intValue = value.as(Int.self) {
                                                        Text("\(intValue) h")
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
                                    .padding(10)
                                    .frame(width: self.scWidth < self.scHeight ? self.scWidth*0.45 : (self.scHeight)*0.45, height: self.scWidth < self.scHeight ? self.scWidth*0.45 : self.scHeight*0.45)
                                    .background{
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 3.0)
                                            .foregroundStyle(self.colorScheme == .dark ? ClockColor[0] : ClockColor[0])
                                    }
                                    VStack{
                                        Text("오늘 공부 시간")
                                            .STime(data: self.$sevenTimeData, sub: sub)
                                        //.STime(time: self.sevenTimeData.last?.subject.filter{$0.subject == sub}.first?.time ?? 0.0)
                                        /*
                                         Text("이번주 평균 시간")
                                         .STime(time: self.sevenTimeData.map{$0.subject}.flatMap{$0}.filter{$0.subject == sub}.map{$0.time}.reduce(0.0){$0 + $1} / 7.0)
                                         Text("이번주 총 시간")
                                         .STime(time: self.sevenTimeData.map{$0.subject}.flatMap{$0}.filter{$0.subject == sub}.map{$0.time}.reduce(0.0){$0 + $1})
                                         */
                                    }
                                    .foregroundStyle(.white)
                                    .frame(width: self.scWidth < self.scHeight ? self.scWidth*0.45 : (self.scHeight)*0.45, height: self.scWidth < self.scHeight ? self.scWidth*0.45 : self.scHeight*0.45)
                                    .background{
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(ClockColor[0])
                                            .shadow(radius: 5)
                                    }
                                }
                            }
                        }
                        Text("총 공부 시간: \(secondsToHoursMinutesSeconds(Int(self.data?.totalTime ?? 0)))")
                    }
                    Spacer()
                }
                .onAppear(){
                    loadData()
                    loadSubjectArray()
                }
            }
            .frame(width: self.scWidth > self.scHeight ? self.scWidth : self.scWidth, height: self.scHeight)
        }
    }
    
    private func loadSubjectArray() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let subjectJson = url.appendingPathComponent("subject_array", conformingTo: .json)
        print(url)
        if FileManager.default.fileExists(atPath: subjectJson.path()) {
            guard let js = NSData(contentsOf: subjectJson) else {print("json not found!"); return}
            let decoder = JSONDecoder()
            guard let myData = try? decoder.decode([String].self, from: js as Data) else {print("subject Data not found!"); return}
            self.subjects = myData
        } else {
            self.subjects = []
        }
    }
    
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
    
    func get7DaysTotalTime() {
        guard let allData = self.data?.data else {print("time get error");return}
        let calander = Calendar(identifier: .gregorian)
        var dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
        dateComponent.timeZone = NSTimeZone.system
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Calendar.current.date(from: dateComponent)!) ?? Date()
        self.sevenTimeData = allData.filter{Calendar.current.date(from: $0.date)!.compare(sevenDaysAgo) == .orderedDescending}
    }
    
    func loadData() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordJson = url.appendingPathComponent("record", conformingTo: .json)
        let calander = Calendar(identifier: .gregorian)
        var dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
        dateComponent.timeZone = NSTimeZone.system
        if FileManager.default.fileExists(atPath: recordJson.path) {
            guard let js = NSData(contentsOf: recordJson) else { return }
            let decoder = JSONDecoder()
            guard let myData = try? decoder.decode(Records.self, from: js as Data) else {
                return
            }
            self.data = myData
        } else {
            self.data = Records(data: [], totalTime: 0.0)
        }
        get7DaysTotalTime()
    }
    
}

#Preview {
    StatisticView()
}
