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
    
    @EnvironmentObject var reminderViewModel: ReminderViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var menuAddAlarm = false
    @State private var selectedReminder: Reminder?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                if reminderViewModel.listAlarms.isEmpty {
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
                    reminderViewModel.listAlarms.append(reminder)
                    reminderViewModel.sortAlarms()
                    reminderViewModel.scheduleNotification(for: reminder)
                }
                .presentationDetents([.height(350)])
            }
            .sheet(item: $selectedReminder) { reminder in
                EditAlarmView(reminder: Binding(
                    get: { reminder }, //ambil jamnya
                    set: { updatedReminder in
                        if let index = reminderViewModel.listAlarms.firstIndex(where: { $0.id == updatedReminder.id }) { //nyari alarm di array dari id 0 satu satu di iterate
                            reminderViewModel.listAlarms[index] = updatedReminder //array ketemu baru direplace sama reminder baru
                            reminderViewModel.sortAlarms()
                            reminderViewModel.cancelNotification(for: reminder) //cancel notif alarm sblmnya
                            if updatedReminder.isEnabled {
                                reminderViewModel.scheduleNotification(for: updatedReminder) //schedulebuat alarm baru
                            }
                        }
                        selectedReminder = updatedReminder
                    }
                ), saveTime: { _ in }) //closure kosong buat editalarmview, kalo logicnya ttp di struct atas
                .presentationDetents([.height(330)])
            }
            .onAppear {
                reminderViewModel.requestNotification()
                reminderViewModel.loadAlarms()
            }
        }
        .tabItem {
            Image(systemName: "alarm.fill")
            Text("Reminder")
        }
    }
    
    func addReminderView() -> some View {
        List {
            ForEach(reminderViewModel.listAlarms.indices, id: \.self) { index in
                HStack {
                    Text("\(reminderViewModel.listAlarms[index].time, formatter: reminderViewModel.timeFormatter)")
                        .font(.system(size: 40))
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { reminderViewModel.listAlarms[index].isEnabled },
                        set: { newValue in
                            reminderViewModel.listAlarms[index].isEnabled = newValue
                            if newValue {
                                reminderViewModel.scheduleNotification(for: reminderViewModel.listAlarms[index])
                            } else {
                                reminderViewModel.cancelNotification(for: reminderViewModel.listAlarms[index])
                            }
                        }
                    )) .tint(.blue)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .opacity(reminderViewModel.listAlarms[index].isEnabled ? 1.0 : 0.6)
                .onTapGesture {
                  selectedReminder = reminderViewModel.listAlarms[index]
                }
            }
            .onDelete(perform: reminderViewModel.deleteAlarm)
        }
        .listStyle(.plain)
        .listRowSpacing(15)
    }
}

#Preview {
    ReminderView()
        .environmentObject(ReminderViewModel())
}
