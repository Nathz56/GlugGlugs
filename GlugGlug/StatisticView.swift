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
        NavigationStack{
            VStack {
                Picker("", selection: $selectedMode) {
                    Text("Week").tag(StatisticMode.weekly)
                    Text("Month").tag(StatisticMode.monthly)
                    Text("Year").tag(StatisticMode.yearly)
                }
                .pickerStyle(.segmented)
                .padding(20)
                
                ChartView(selectedMode: $selectedMode)
                Spacer()
                HStack {
                    Spacer()
                    StatisticInformationView(title: "Streak", value: "7 Days", imageName: "drop.fill")
                    Spacer()
                    StatisticInformationView(title: "Goal Achieved", value: "3", imageName: "target")
                    Spacer()
                }
                Spacer()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    VStack(alignment: .leading) {
                        Text("Statistics")
                            .font(.title)
                            .bold()

                        switch selectedMode {
                        case .weekly:
                            Text("This Week")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        case .monthly:
                            Text("This Month")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        case .yearly:
                            Text("This Year")
                                .font(.title2)
                                .foregroundStyle(.gray)
                        }
                    
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.top, 20)
        }
        .tabItem {
            Image(systemName: "chart.bar.fill")
            Text("Statistic")
        }
    }
}

struct StatisticInformationView: View {
    let title: String
    let value: String
    let imageName: String
    
    var body: some View {
        HStack {
            VStack {
                Text(title)
                Text(value)
            }
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
                .foregroundColor(.blue)
            
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 2).foregroundColor(.blue))

        
    }
}

#Preview {
    StatisticView()
}
