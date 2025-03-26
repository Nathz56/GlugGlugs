//
//  ReminderView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//


import UserNotifications
import SwiftUI


struct Reminder: Identifiable, Codable {
    var id = UUID()
    var time: Date
    var isEnabled: Bool
}

struct ReminderView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var menuAddAlarm = false
    @State private var listAlarms: [Reminder] = [] {
        didSet {
            saveAlarms()
        }
    }
    @State private var selectedReminder: Reminder?
    
    let userDefaultKey = "savedAlarms"
    
    var body: some View {
        NavigationStack {
            VStack {
                if listAlarms.isEmpty {
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            Image(systemName: "alarm")
                                .resizable()
                                .frame(width: 70, height: 70, alignment: .leading)
                                .foregroundColor(.blue)
                                .symbolEffect(.wiggle.wholeSymbol, options: .nonRepeating)
                                .padding(19)
                            
                            Image(systemName: "xmark.circle.fill")
                                .background(colorScheme == .dark ? .black : .white)
                                .foregroundStyle(.red)
                                .font(.system(size: 41))
                                .symbolEffect(.wiggle.wholeSymbol, options: .nonRepeating)
                        }
                        Text("No reminders yet! \n Set one now to stay hydrated!")
                            .multilineTextAlignment(.center)
                    }
                } else {
                    addReminderView()
                }
            }
            .navigationTitle("Reminder")
            .navigationBarItems(
                trailing: Button("Add") {
                    menuAddAlarm.toggle()
                }
            )
            .sheet(isPresented: $menuAddAlarm) {
                AddAlarmView { newAlarm in
                    let reminder = Reminder(time: newAlarm, isEnabled: true)
                    listAlarms.append(reminder)
                    scheduleNotification(for: reminder)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedReminder) { reminder in
                EditAlarmView(reminder: Binding(
                    get: { reminder },
                    set: { updatedReminder in
                        if let index = listAlarms.firstIndex(where: { $0.id == updatedReminder.id }) {
                            listAlarms[index] = updatedReminder
                            cancelNotification(for: reminder)
                            if updatedReminder.isEnabled {
                                scheduleNotification(for: updatedReminder)
                            }
                        }
                        selectedReminder = updatedReminder
                    }
                ), saveTime: { _ in
                 
                })
                .presentationDetents([.medium, .large]) // Half-modal screen
            }
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("Notification permission granted")
                    } else if let error = error {
                        print("Error requesting permission: \(error.localizedDescription)")
                    }
                }
                loadAlarms()
            }
        
            .padding(15)
        }
        .tabItem {
            Image(systemName: "alarm.fill")
            Text("Reminder")
        }
    }
    
    private func deleteAlarm(at offsets: IndexSet) {
        listAlarms.remove(atOffsets: offsets)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private func addReminderView() -> some View {
        List {
            ForEach(listAlarms.indices, id: \.self) { index in
                HStack {
                    Text("\(listAlarms[index].time, formatter: timeFormatter)")
                        .font(.largeTitle)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { listAlarms[index].isEnabled },
                        set: { newValue in
                            listAlarms[index].isEnabled = newValue
                            if newValue {
                                scheduleNotification(for: listAlarms[index])
                            } else {
                                cancelNotification(for: listAlarms[index])
                            }
                        }
                    ))
                }
                .padding(8)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedReminder = listAlarms[index]
                }
            }
            .onDelete(perform: deleteAlarm)
        }
        .listStyle(.plain)
        .listRowSpacing(15)
    }
    
    private func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(listAlarms) {
            UserDefaults.standard.set(encoded, forKey: userDefaultKey)
        }
    }
    
    private func loadAlarms() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: savedData) {
            listAlarms = decoded
        }
    }
}

private func scheduleNotification(for reminder: Reminder) {
    guard reminder.isEnabled else { return }
    
    let content = UNMutableNotificationContent()
    content.title = "Time to Hydrate!"
    content.body = "Don't forget to drink water"
    content.sound = .default
    
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: reminder.time)
    let minute = calendar.component(.minute, from: reminder.time)
    
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    
    let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("❌ Error scheduling notification: \(error.localizedDescription)")
        }
    }
}

private func cancelNotification(for reminder: Reminder) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
}

#Preview {
    ReminderView()
}
