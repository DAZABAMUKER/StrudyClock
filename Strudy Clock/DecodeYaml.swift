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

struct Subject: Codable {
    var subject: String
    var time: Double
    
}

