//
//  Timer.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/17/23.
//

import Foundation
import SwiftUI
import Combine

class Timers: ObservableObject {
    @Published var value = 0.0
    @Published var pauses: Bool = true
    @Published var isRunning = false
    @Published var timeString: String = "01:00:00"
    @Published var SettingDegree: Double = 0.0 
    
    var oldData: Records? = nil
    
    private var timer: AnyCancellable?
    private var startTime: Date? {
        didSet {
            saveStartTime()
        }
    }
    
    func saveStartTime() {
        if let startTime = startTime {
            UserDefaults.standard.set(startTime, forKey: "startTime")
        } else {
            UserDefaults.standard.removeObject(forKey: "startTime")
        }
    }
    
    func fetchStartTime() -> Date? {
        UserDefaults.standard.object(forKey: "startTime") as? Date
    }
    
    
    init() {
        
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int = 0) -> String {
        let timeDict: [Times : Int] = [.Hour : seconds / 3600, .Minute : (seconds % 3600) / 60, .Second : (seconds % 3600) % 60 ]
        var results = ""
        if seconds < 3600 {
            results = "\(String(format:"%02d",(timeDict[.Minute] ?? 0) + 60 * (timeDict[.Hour] ?? 0))) : \(String(format:"%02d",timeDict[.Second] ?? 0))"
        } else {
            results = "\(String(format:"%02d",timeDict[.Hour] ?? 0)) : \(String(format:"%02d",timeDict[.Minute] ?? 0)) : \(String(format:"%02d",timeDict[.Second] ?? 0))"
        }
        return results
    }
    
}

extension Timers {
    func start() {
        timer?.cancel() // cancel timer if any
                timer = Timer
            .publish(every: 0.1, on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] _ in
                        //self!.value += 1
                        
                        self!.value += 0.1
                        //print(Int(self?.value ?? 0.0))
                        self!.timeString = self!.secondsToHoursMinutesSeconds(Int(self!.SettingDegree - (self!.value )))
                        //print(self?.timeString ?? "")
                        //self?.value = floor(elapsed)
                        //print(elapsed)
                        //                        guard elapsed < 60 else {
                        //                            self.stop()
                        //                            return
                        //                        }
                    }
        
        isRunning = true
    }
    func backgroundTime() {
        if self.startTime != nil {
            guard
                //let self = self,
                let startTime = self.startTime
            else { return }
            
            let now = Date()
            let elapsed = now.timeIntervalSince(startTime)
            self.value += floor(elapsed)
            self.startTime = nil
        }
    }
    func backProcess() {
        startTime = Date()
    }
    func stop() {
        timer?.cancel()
        timer = nil
        startTime = nil
        isRunning = false
        self.SettingDegree = 0.0
        //self.timeString = "00:00"
        self.value = 0.0
    }
}

extension Timers {
    func SaveData() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordJson = url.appendingPathComponent("record", conformingTo: .json)
        if FileManager.default.fileExists(atPath: recordJson.path) {
            guard let js = NSData(contentsOf: recordJson) else { return }
            let decoder = JSONDecoder()
            guard let myData = try? decoder.decode(Records.self, from: js as Data) else {
                return
            }
            self.oldData = myData
            //var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date.now)
            //dateComponents.timeZone = NSTimeZone.system
            let calander = Calendar(identifier: .gregorian)
            let dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
            if self.oldData?.data.last?.date ?? calander.dateComponents([.year, .month, .day], from: Date()) == calander.dateComponents([.year, .month, .day], from: Date()) {
                //let total = self.oldData?.data.last?.date.timeZone
                self.oldData?.totalTime += self.value
            } else {
                self.oldData?.totalTime += self.value
                self.oldData?.data.append(YamlData(date: dateComponent, subject: [Subject(subject: "토익", time: self.value)], totalTime: self.value))
            }
            try? FileManager.default.removeItem(atPath: recordJson.path)
        }
        
    }
}
