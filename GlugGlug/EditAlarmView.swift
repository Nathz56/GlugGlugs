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
    //    @Binding var reminderView: ReminderView
    @State var saveTime: (Reminder) -> Void
    
    let buttonText = "Save Changes"
    var body: some View {
        
        VStack(alignment: .center) {
            Text ("Edit Alarm")
                .font(.title)
            DatePicker("Select Time", selection: $reminder.time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
            
            HStack(alignment: .center) {
                Button ("Save Changes"){
                    saveTime(reminder)
                    dismiss()
                } .buttonStyle(.borderedProminent)
            }
        }
    }
}


#Preview {
    EditAlarmView(reminder: .constant(Reminder(time: Date(), isEnabled: true))) {_ in}
}
