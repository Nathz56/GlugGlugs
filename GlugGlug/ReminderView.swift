//
//  ReminderView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI

struct ReminderView: View {
    var body: some View {
        VStack {
            Text("Reminder")
                .font(.largeTitle)
        }
        .tabItem {
            Image(systemName: "alarm.fill")
            Text("Reminder")
        }
    }
}

#Preview {
    ReminderView()
}
