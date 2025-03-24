//
//  ContentView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        TabView {
            HomeView()
            StatisticView()
            ReminderView()
        }
    }
}

#Preview {
    ContentView()
}
