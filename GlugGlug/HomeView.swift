//
//  HomeView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home")
                .font(.largeTitle)
        }
        .tabItem {
            Image(systemName: "house.fill")
            Text("Home")
        }
        
    }
}

#Preview {
    HomeView()
}

