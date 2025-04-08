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
        NavigationStack {
            VStack {
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                    Text("Add New Alarm")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                    Button("Save") {
                        saveTime(selectedTime)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                }
                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                Spacer()
                
            }
            .padding()
         
        }
    }
}

#Preview {
    AddAlarmView {_ in}
}
