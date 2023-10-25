//
//  DecodeYaml.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/23/23.
//

import Foundation

struct Records: Codable {
    var data: [YamlData]
    var totalTime: Int
}

struct YamlData: Codable {
    var date: Calendar
    var subject: [Subject]
    var totalTime: Int
}

struct Subject: Codable {
    var subject: String
    var time: Int
    
}
