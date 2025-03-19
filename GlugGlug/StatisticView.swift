//
//  StatisticView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI

struct StatisticView: View {
    var body: some View {
        VStack {
            Text("Statistic")
                .font(.largeTitle)
        }
        .tabItem {
            Image(systemName: "chart.bar.fill")
            Text("Statistic")
        }
    }
}

#Preview {
    StatisticView()
}
