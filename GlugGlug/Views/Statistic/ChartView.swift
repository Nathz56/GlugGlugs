//
//  WeeklyStatisticView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 26/03/25.
//

import SwiftUI
import Charts

enum StatisticMode: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

struct ChartView: View {
    @Binding var selectedMode: StatisticMode
    @State private var dayDrink: [(String, Int)] = []

    var body: some View {
        VStack {
            if dayDrink.isEmpty {
                Text("Loading...")
            } else {
                Chart(dayDrink, id: \.0) { (date, vol) in
                    BarMark(
                        x: .value("Day", date),
                        y: .value("Volume (mL)", vol)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 300)
                .padding()
            }
        }
        .onAppear {
            loadStatistics()
        }.onChange(of: selectedMode) {
            loadStatistics()
        }
    }

    private func loadStatistics() {
        if selectedMode == .weekly {
            HealthKitManager.shared.getThisWeekStatistic { data in
                DispatchQueue.main.async {
                    self.dayDrink = data
                }
            }
        } else if selectedMode == .monthly {
            HealthKitManager.shared.getThisMonthStatistic { data in
                DispatchQueue.main.async {
                    self.dayDrink = data
                }
            }
        } else if selectedMode == .yearly {
            HealthKitManager.shared.getThisYearStatistic { data in
                DispatchQueue.main.async {
                    self.dayDrink = data
                }
            }
        }
        
    }
}
