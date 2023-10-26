//
//  StatisticView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
import Charts

struct StatisticView: View {
    
    @State var data: Records?
    @State var timeData: [YamlData] = []
    
    @State var scWidth = 0.0
    @State var scHeight = 0.0
    
    var body: some View {
        ZStack{
            GeometryReader { geometry in
                ZStack{}.onAppear() {
                    self.scHeight = geometry.size.height
                    self.scWidth = geometry.size.width
                }
            }
            VStack{
                Text("주간 공부 시간")
                    .onAppear(){
                        loadData()
                    }
                if self.data != nil {
                    Chart(self.timeData, id: \.self) { time in
                        
                        AreaMark(x: .value("Day", Calendar.current.date(from: time.date)!, unit: .day), y: .value("Time", time.totalTime/60))
                            .foregroundStyle(
                                LinearGradient(colors: [ClockColor[0].opacity(0.5), ClockColor[0].opacity(0.05)], startPoint: .top, endPoint: .bottom)
                            )
                        PointMark(x: .value("Day", Calendar.current.date(from: time.date)!, unit: .day), y: .value("Time", time.totalTime/60))
                            .foregroundStyle(ClockColor[0])
                        LineMark(x: .value("Day", Calendar.current.date(from: time.date)!, unit: .day), y: .value("Time", time.totalTime/60))
                            .foregroundStyle(ClockColor[0])
                    }
                    .frame(width: self.scWidth < self.scHeight ? self.scWidth : self.scHeight - 50, height: self.scWidth < self.scHeight ? self.scWidth/2 : self.scHeight/2)
                }
            }
        }
    }
    
    func get7DaysTotalTime() {
        guard let allData = self.data?.data else {print("time get error");return}
        let calander = Calendar(identifier: .gregorian)
        var dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
        dateComponent.timeZone = NSTimeZone.system
        var sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Calendar.current.date(from: dateComponent)!) ?? Date()
        print(sevenDaysAgo)
        self.timeData = allData.filter{Calendar.current.date(from: $0.date)!.compare(sevenDaysAgo) == .orderedDescending}
        print(timeData)
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
            //let subjectInfo = Subject(subject: subjectOfTimer, time: 0.0)
            //let data = YamlData(date: dateComponent, subject: [], totalTime: 0.0)
            self.data = Records(data: [], totalTime: 0.0)
        }
        get7DaysTotalTime()
    }
    
}

#Preview {
    StatisticView()
}
