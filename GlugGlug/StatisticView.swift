//
//  StatisticView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI
import Charts

struct StatisticView: View {
    @StateObject var healthKitManager = HealthKitManager.shared
    @State private var selectedMode: StatisticMode = .weekly
    @State private var weeksData: [(String, Int)] = []
    
    var body: some View {
        VStack {
            Picker("", selection: $selectedMode) {
                Text("Week").tag(StatisticMode.weekly)
                Text("Month").tag(StatisticMode.monthly)
                Text("Year").tag(StatisticMode.yearly)
            }
            .pickerStyle(.segmented)
            .padding(20)
            
            ChartView(selectedMode: $selectedMode)
            
            Text("Statistic")
                .font(.largeTitle)
            Button(action: fetchData) {
                Text("Fetch Data")
            }
            Button(action: {
                HealthKitManager.shared.addWaterAmount(volume: 200)
            }) {
                Text("Input 200 mL")
            }
            Button(action: getThisWeekStatistic) {
                Text("Get this week statistic")
            }
            Button(action: getThisMonthStatistic) {
                Text("Get this month statistic")
            }
            Button(action: getThisYearStatistic) {
                Text("Get this year statistic")
            }
        }
        .tabItem {
            Image(systemName: "chart.bar.fill")
            Text("Statistic")
        }
    }
    
    private func fetchData() {
        HealthKitManager.shared.getConsumedWaterToday{ waterVolume in
            if let volume = waterVolume {
                print("Total air yang dikonsumsi hari ini: \(volume) mL")
            } else {
                print("Gagal membaca konsumsi air hari ini.")
            }
        }
    }
    
    private func getThisWeekStatistic() {
        HealthKitManager.shared.getThisWeekStatistic { dayDrink in
            for (date, vol) in dayDrink {
                print("\(date): \(vol) mL")
            }
        }
    }
    
    private func getThisMonthStatistic() {
        HealthKitManager.shared.getThisMonthStatistic { dayDrink in
            for (date, vol) in dayDrink {
                print("\(date): \(vol) mL")
            }
        }
    }
    private func getThisYearStatistic() {
        HealthKitManager.shared.getThisYearStatistic { dayDrink in
            for (date, vol) in dayDrink {
                print("\(date): \(vol) mL")
            }
        }
    }
}

#Preview {
    StatisticView()
}
