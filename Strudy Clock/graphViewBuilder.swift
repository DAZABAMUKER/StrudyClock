//
//  graphViewBuilder.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/30/23.
//

import SwiftUI

struct graphViewBuilder: ViewModifier {
    
    @Binding var timeData: [YamlData]
    @State var sub: String
    @State var timeString = ""
    
    @State var viewIndex = 0
    
    func secondsToHoursMinutesSeconds(_ seconds: Int = 0) -> String {
        let timeDict: [Times : Int] = [.Hour : seconds / 3600, .Minute : (seconds % 3600) / 60, .Second : (seconds % 3600) % 60 ]
        var results = ""
        if seconds < 3600 {
            results = "\(String(format:"%02d",(timeDict[.Minute] ?? 0) + 60 * (timeDict[.Hour] ?? 0)))\(String(localized: "분")) \(String(format:"%02d",timeDict[.Second] ?? 0))\(String(localized: "초"))"
        } else {
            results = "\(String(format:"%02d",timeDict[.Hour] ?? 0))\(String(localized: "시간")) \(String(format:"%02d",timeDict[.Minute] ?? 0))\(String(localized: "분")) \(String(format:"%02d",timeDict[.Second] ?? 0))\(String(localized: "초"))"
        }
        return results
    }
    
    public func body(content: Content) -> some View {
        if viewIndex == 0 {
            VStack{
                content
                    .bold()
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .onAppear(){
                        let timeWant = timeData.last?.subject.filter{$0.subject == sub}.first?.time ?? 0.0
                        //print("timeWant: \(timeWant)")
                        self.timeString = secondsToHoursMinutesSeconds(Int(timeWant))
                    }
                Text(self.timeString)
            }
            .onTapGesture {
                self.viewIndex = 1
            }
        } else if viewIndex == 1 {
            VStack{
                Text("이번주 평균 시간")
                    .bold()
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .onAppear(){
                        let timeWant =  timeData.map{$0.subject}.flatMap{$0}.filter{$0.subject == sub}.map{$0.time}.reduce(0.0){$0 + $1} / 7.0
                        self.timeString = secondsToHoursMinutesSeconds(Int(timeWant))
                    }
                Text(self.timeString)
            }
            .onTapGesture {
                self.viewIndex = 2
            }
        } else {
            VStack{
                Text("이번주 총 시간")
                    .bold()
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .onAppear(){
                        let timeWant = timeData.map{$0.subject}.flatMap{$0}.filter{$0.subject == sub}.map{$0.time}.reduce(0.0){$0 + $1}
                        self.timeString = secondsToHoursMinutesSeconds(Int(timeWant))
                    }
                Text(self.timeString)
            }
            .onTapGesture {
                self.viewIndex = 0
            }
        }
        /*
        VStack(spacing: 5){
            HStack{
                content
                    .bold()
                    .font(.title3)
                    .onAppear(){
                        self.timeString = secondsToHoursMinutesSeconds(Int(self.time))
                    }
            }
            //.border(.yellow)
            HStack{
                Text(self.timeString)
            }
            //.border(.cyan)
        }
         */
        //.padding(5)
    }
}

struct grapDetailhViewBuilder: ViewModifier {
    
    @State var subTimeDetail = false
    var sub: String
    var data: [YamlData]
    
    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                self.subTimeDetail = true
            }
            .sheet(isPresented: self.$subTimeDetail) {
                GraphSubDetailView(datas: self.data, sub: sub)
            }
    }
}
extension View {
    func STime(data: Binding<[YamlData]>, sub: String) -> some View {
        self.modifier(graphViewBuilder(timeData: data, sub: sub))
    }
    func SDetail(sub: String, data: [YamlData]) -> some View {
        self.modifier(grapDetailhViewBuilder(sub: sub, data: data))
    }
}
