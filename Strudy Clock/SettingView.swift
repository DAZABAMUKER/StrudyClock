//
//  SettingView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
import Charts

struct SettingView: View {
    
    //@Binding var selectedBell: String
    @AppStorage("KEY") var selectedBell: String = "cow-bells"
    var bells = ["cow-bells", "alarm", "uprising2"]
    
    var body: some View {
        VStack(spacing: 0){
            Text("설정")
                .font(.title)
                .bold()
            Spacer()
                .frame(height: 50)
            HStack{
                Text("벨 소리 선택")
                    .font(.title3)
                    .padding(.horizontal)
                Spacer()
                Picker(selection: $selectedBell) {
                    ForEach(self.bells, id: \.self) {
                        Text($0).tag($0)
                    }
                } label: {
                    Text("벨소리 선택")
                }
                .pickerStyle(.menu)
                .tint(ClockColor[0])
                .background{
                  RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(ClockColor[0])
                }
                .padding()
            }
                
            Text("uprising2 sound is shared from JFRecords")
                .font(.footnote)
            Spacer()
        }
    }
    
    
    
}

#Preview {
    SettingView()
}
