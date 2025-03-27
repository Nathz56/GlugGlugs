//
//  EditAlarmView.swift
//  GlugGlug
//
//  Created by Yonathan Hilkia on 26/03/25.
//

import SwiftUI

struct EditAlarmView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var reminder: Reminder
    @State private var tempTime: Date // Variabel sementara untuk menyimpan waktu
    let saveTime: (Reminder) -> Void
    
    let buttonText = "Save Changes"
    
    init(reminder: Binding<Reminder>, saveTime: @escaping (Reminder) -> Void) {
        self._reminder = reminder
        self.saveTime = saveTime
        self._tempTime = State(initialValue: reminder.wrappedValue.time) // Inisialisasi dengan waktu awal
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }.buttonStyle(.borderless)
                    Spacer()
                    Spacer()
                    Text("Edit Alarm")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Spacer()
                    Button("Save") {
                        reminder.time = tempTime // Update waktu hanya saat tombol ditekan
                        saveTime(reminder)
                        dismiss()
                    }.buttonStyle(.borderedProminent)
                    Spacer()
                }
                
                
                DatePicker("Select Time", selection: $tempTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
//                Spacer()
            }
        }
    }
}

#Preview {
    EditAlarmView(reminder: .constant(Reminder(time: Date(), isEnabled: true))) { _ in }
}
