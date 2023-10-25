//
//  TimerView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI

struct TimerView: Shape {
    var degrees: Double
    func path(in rect: CGRect) -> Path {
        var p = Path()
        //print(degrees)
        var angle = self.degrees
        if 0.0 < angle && angle < 0.1 {
            angle = 360.0
        }
        p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width, startAngle: .degrees(0), endAngle: .degrees(-angle), clockwise: true)
        return p
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return p
    }
}
