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
            VStack(alignment: .leading, spacing: 0) {
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
                    .frame(maxWidth: .infinity)
                } else {
                    addReminderView()
                }
            }
            .navigationTitle("Reminder")
            .navigationBarItems(leading: EditButton(),
                            trailing: Button("Add") {
                                menuAddAlarm.toggle()
                            }
                        )
            .sheet(isPresented: $menuAddAlarm) {
                AddAlarmView { newAlarm in
                    let reminder = Reminder(time: newAlarm, isEnabled: true)
                    listAlarms.append(reminder)
                    sortAlarms()
                    scheduleNotification(for: reminder)
                }
                .presentationDetents([.height(350)])
            }
            .sheet(item: $selectedReminder) { reminder in
                EditAlarmView(reminder: Binding(
                    get: { reminder }, //ambil jamnya
                    set: { updatedReminder in
                        if let index = listAlarms.firstIndex(where: { $0.id == updatedReminder.id }) { //nyari alarm di array dari id 0 satu satu di iterate
                            listAlarms[index] = updatedReminder //array ketemu baru direplace sama reminder baru
                            sortAlarms()
                            cancelNotification(for: reminder) //cancel notif alarm sblmnya
                            if updatedReminder.isEnabled {
                                scheduleNotification(for: updatedReminder) //schedulebuat alarm baru
                            }
                        }
                        selectedReminder = updatedReminder
                    }
                ), saveTime: { _ in }) //closure kosong buat editalarmview, kalo logicnya ttp di struct atas
                .presentationDetents([.height(330)])
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
        }
        .tabItem {
            Image(systemName: "alarm.fill")
            Text("Reminder")
        }
    }
    
    private func deleteAlarm(at offsets: IndexSet) {
        let remindersToDelete = offsets.map { listAlarms[$0] }
        listAlarms.remove(atOffsets: offsets)
        for reminder in remindersToDelete {
                cancelNotification(for: reminder)
            }
        sortAlarms()
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
                        .font(.system(size: 40))
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
                    )) .tint(.blue)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .opacity(listAlarms[index].isEnabled ? 1.0 : 0.6)
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
    
    private func sortAlarms() {
        listAlarms.sort { $0.time < $1.time }
    }
}

private func scheduleNotification(for reminder: Reminder) {
    guard reminder.isEnabled else { return } //cek ke enable ga jamnya, kalo ga yaudah gausah di schedule
    
    
    
    
    let content = UNMutableNotificationContent()
    content.title = "It's Glug Glug time !!!"
    content.body = "Even you are busy, don't forget it's time to rehydrate so you can perform better!"
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

private func cancelNotification(for reminder: Reminder) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
}

#Preview {
    ReminderView()
}
