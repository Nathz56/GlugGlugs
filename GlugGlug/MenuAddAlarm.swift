//
//  MenuAddAlarm.swift
//  GlugGlug
//
//  Created by Yonathan Hilkia on 20/03/25.
//

import SwiftUI

struct AddAlarmView: View {
    
    @Environment(\.dismiss) var dismiss //tutup menu
    @State private var selectedTime = Calendar.current.startOfDay(for: Date()) //biar start di 00 00
    
    var saveTime : (Date) -> Void //closure save waktu
    
    var body: some View {
        VStack {
            Text("Add New Alarm")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
            
            Button("Save Alarm") {
                
                saveTime(selectedTime)
                dismiss()
                
            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    AddAlarmView {_ in}
}
