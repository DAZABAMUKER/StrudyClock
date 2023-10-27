//
//  Timer.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/17/23.
//

import Foundation
import SwiftUI
import Combine
//MARK: - 타이머 클래스 설명
// 타이머의 핵심 코어 기능 집합 클래스
class Timers: ObservableObject {
    @Published var value = 0.0
    @Published var pauses: Bool = true
    @Published var isRunning = false
    @Published var timeString: String = "01:00:00"
    @Published var SettingDegree: Double = 0.0 
    //@Published var subject: String = ""
    
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
        loadData()
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
        //SaveData()
        timer?.cancel()
        timer = nil
        startTime = nil
        isRunning = false
        self.SettingDegree = 0.0
        //self.timeString = "00:00"
        self.value = 0.0
        self.timeString = "00:00"
    }
}

extension Timers {
    func SaveData(subjectOfTimer: String) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordJson = url.appendingPathComponent("record", conformingTo: .json)
        let calander = Calendar(identifier: .gregorian)
        var dateComponent = calander.dateComponents([.year, .month, .day], from: Date())
        dateComponent.timeZone = NSTimeZone.system
        if FileManager.default.fileExists(atPath: recordJson.path) {
            guard let js = NSData(contentsOf: recordJson) else { return }
            let decoder = JSONDecoder()
            if self.oldData?.data.last?.date ?? dateComponent == dateComponent {
                //let total = self.oldData?.data.last?.date.timeZone
                self.oldData?.totalTime += self.value
                var DataOfDate = self.oldData?.data.filter{ $0.date == dateComponent}.first
                var SubjectsOfDate = DataOfDate?.subject
                let filteredData = SubjectsOfDate?.map{$0.subject}
                guard let subjects = filteredData else {print("No subjects"); return}
                if subjects.contains(subjectOfTimer) {
                    let myData = SubjectsOfDate?.filter{$0.subject == subjectOfTimer}
                    let addSubject = Subject(subject: subjectOfTimer, time: (myData?.first?.time ?? 0.0) + value)
                    guard let oldSubject = SubjectsOfDate?.filter({$0.subject == addSubject.subject}).first else {print("old subject Data uwrap error"); return}
                    guard let indexOfSubject = SubjectsOfDate?.firstIndex(of: oldSubject) else {print("index of subject unwrap error");return}
                    SubjectsOfDate?.remove(at: indexOfSubject) // 이거 먼저 해결하자 특정 서브젝트 인덱스 구해서 제거하기
                    SubjectsOfDate?.append(addSubject)
                    DataOfDate?.subject = SubjectsOfDate!
                    DataOfDate?.totalTime += self.value
                    guard let lastData = DataOfDate else {print("DataOfDate optional unwrap error");return}
                    self.oldData?.data.removeLast()
                    self.oldData?.data.append(lastData)
                } else {
                    let addSubject = Subject(subject: subjectOfTimer, time: value)
                    SubjectsOfDate?.append(addSubject)
                    DataOfDate?.subject = SubjectsOfDate!
                    DataOfDate?.totalTime += self.value
                    guard let lastData = DataOfDate else {print("DataOfDate optional unwrap error");return}
                    self.oldData?.data.removeLast()
                    self.oldData?.data.append(lastData)
                }
            } else {
                self.oldData?.totalTime += self.value
                self.oldData?.data.append(YamlData(date: dateComponent, subject: [Subject(subject: subjectOfTimer, time: self.value)], totalTime: self.value))
            }
            try? FileManager.default.removeItem(atPath: recordJson.path)
            let myData = try? JSONEncoder().encode(self.oldData)
            FileManager.default.createFile(atPath: recordJson.path(), contents: myData)
            print(recordJson.path())
        } else {
            let subjectInfo = Subject(subject: subjectOfTimer, time: self.value)
            let data = YamlData(date: dateComponent, subject: [subjectInfo], totalTime: self.value)
            self.oldData = Records(data: [data], totalTime: self.value)
            let myData = try? JSONEncoder().encode(self.oldData)
            FileManager.default.createFile(atPath: recordJson.path(), contents: myData)
            print(recordJson.path())
        }
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
            self.oldData = myData
        } else {
            self.oldData = Records(data: [], totalTime: 0.0)
        }
    }
}
