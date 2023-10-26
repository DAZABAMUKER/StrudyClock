//
//  DecodeYaml.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/23/23.
//

import Foundation

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

