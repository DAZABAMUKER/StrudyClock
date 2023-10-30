//
//  SettingView.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/16/23.
//

import SwiftUI
import Charts

struct SettingView: View {
    
    @State var selectedBell = "cow-bells"
    private var bells = ["cow-bells", "alarm", "uprising2"]
    
    var body: some View {
        VStack(spacing: 0){
            Text("설정")
                .font(.title)
                .bold()
            Spacer()
                .frame(height: 50)
            HStack{
                Text("벨 소리 선택")
                    .fontWeight(.semibold)
                    .font(.title3)
                    .padding(.horizontal)
                Spacer()
            }
            Picker(selection: $selectedBell) {
                ForEach(self.bells, id: \.self) {
                    Text($0).tag($0)
                }
            } label: {
                Text("벨소리 선택")
            }
            .pickerStyle(.segmented)
            .padding()
            Text("uprising2 sound is shared from JFRecords")
                .font(.footnote)
            Spacer()
        }
    }
    
    
    
}

#Preview {
    SettingView()
}
