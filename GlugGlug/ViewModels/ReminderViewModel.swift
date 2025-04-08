//
//  ReminderViewModel.swift
//  GlugGlug
//
//  Created by Yonathan Hilkia on 08/04/25.
//

import UserNotifications
import Foundation


class ReminderViewModel: ObservableObject {
    
    let userDefaultKey = "savedAlarms"
    
    @Published var listAlarms: [Reminder] = [] {
        didSet {
            saveAlarms()
        }
    }
    
    let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter
        }()
    
    func deleteAlarm(at offsets: IndexSet) {
        let remindersToDelete = offsets.map { listAlarms[$0] }
        listAlarms.remove(atOffsets: offsets)
        for reminder in remindersToDelete {
            cancelNotification(for: reminder)
        }
        sortAlarms()
    }
    
    func sortAlarms() {
        listAlarms.sort { $0.time < $1.time }
    }
    
    func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(listAlarms) {
            UserDefaults.standard.set(encoded, forKey: userDefaultKey)
        }
    }
    
    func loadAlarms() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: savedData) {
            listAlarms = decoded
        }
    }
    
    func cancelNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }

    func requestNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }

    }
    

    func scheduleNotification(for reminder: Reminder) {
        
        guard reminder.isEnabled else { return } //cek ke enable ga jamnya, kalo ga yaudah gausah di schedule
        
        let randomNotifBody = [
            "Even you are busy, don't forget it's time to rehydrate so you can perform better!",
            "Time for a water break! Stay hydrated, stay awesome!",
            "Glug Glug alert! Your body says thanks for the H2O!",
            "Hydration station calling! Time to sip some water!",
            "Water time! Keep those fluids flowing!",
            "Ding ding! Your hydration reminder is here!",
            "Stay fresh, stay hydrated - it's water o'clock!"
        ]
        
        
        let content = UNMutableNotificationContent()
        content.title = "It's Glug Glug time!"
        content.body = randomNotifBody.randomElement() ?? "It's time to rehydrate!"
        content.sound = .default
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: reminder.time) //block ini untuk ngetake user current calendar
        let minute = calendar.component(.minute, from: reminder.time) //berdasarkan local timezonenya
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true) //trigger notif ketika sudah match dengan time yg diset di datecomponent
        
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger) //creates a notification requst
        
        UNUserNotificationCenter.current().add(request) { error in //access app notif manager //add request buat schedule notifnya
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
