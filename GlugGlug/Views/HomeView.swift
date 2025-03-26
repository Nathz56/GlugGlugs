//
//  HomeView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI

struct HomeView: View {
    
    @State var progress: CGFloat = 0.5
    @State var startAnimation: CGFloat = 0.0
    
    var body: some View {
        NavigationStack {
            VStack () {
                Text("⏰ No reminders set! Add one to stay on track! 💧")
                    .font(.subheadline)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                AlertBanner(message: "Welcome! 🚀 Set your reminder, target, and tumbler size to stay hydrated! 💧", iconName: "lightbulb.fill", backgroundColor: .yellow.opacity(0.2), foregroundColor: .yellow, textColor: .black)
                    .padding(.bottom, 8)
                
                Text("0 ml")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.bottom, 2)
                
                Text("0% of your target")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                
                WaterIndicator(progress: $progress, startAnimation: $startAnimation)
            }
            .padding()
            .navigationTitle("GlugGlug!")
            
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


