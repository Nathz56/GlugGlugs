//
//  HomeView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @State var startAnimation: CGFloat = 0.0
    @State var progressPercentage: CGFloat = 0.0
    @State var isShowEditGoal: Bool = false
    
    @State private var selectedGlassAmount: Int = 100
    
    @State private var selectedIndex: Int = 2
    
    @State private var progress: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack () {
                Text("⏰ No reminders set! Add one to stay on track! 💧")
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                    .padding(.horizontal)
                
                AlertBanner(message: "Welcome! 🚀 Set your reminder, target, and tumbler size to stay hydrated! 💧", iconName: "lightbulb.fill", backgroundColor: .yellow.opacity(0.2), foregroundColor: .yellow, textColor: .black)
                    .padding(.bottom, 8)
                    .padding(.horizontal)
                
                Text("\(progress) ml")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.bottom, 2)
                
                HStack{
                    Text("\(Int(progressPercentage * 100))% of your ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    +
                    Text("\(homeViewModel.goal) ml ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .bold()
                    +
                    Text("goal")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button {
                        isShowEditGoal.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                        
                    }
                }
                .padding(.bottom)
                
                WaterIndicator(progress: $progressPercentage, startAnimation: $startAnimation)
                    .padding(.bottom, 8)
                
                SnapCarousel(items: homeViewModel.glassOptions, selectedIndex: $selectedIndex)
                
                Button {
                    let amount = homeViewModel.glassOptions[selectedIndex].amount
                    HealthKitManager.shared.addWaterAmount(volume: Double(amount))
                    HealthKitManager.shared.getConsumedWaterToday { data in DispatchQueue.main.async {
                        self.progress = data ?? 0
                    }}
                } label: {
                    Image(systemName: "plus")
                    Text("Add \(homeViewModel.glassOptions[selectedIndex].amount) ml")
                }
                .buttonStyle(.borderedProminent)
                Spacer()
                
            }
            .navigationTitle("GlugGlug!")
            
        }
        .onAppear {
            if homeViewModel.goal > 0 {
                progressPercentage = CGFloat(progress) / CGFloat(homeViewModel.goal)
            } else {
                progressPercentage = 0.0
            }
            
            HealthKitManager.shared.getConsumedWaterToday { data in DispatchQueue.main.async {
                self.progress = data ?? 0
            }}
            
        }
        .onChange(of: progress) {
            if homeViewModel.goal > 0 {
                progressPercentage = CGFloat(progress) / CGFloat(homeViewModel.goal)
            } else {
                progressPercentage = 0.0
            }
        }
        .onChange(of: homeViewModel.goal) {
            if homeViewModel.goal > 0 {
                progressPercentage = CGFloat(progress) / CGFloat(homeViewModel.goal)
            } else {
                progressPercentage = 0.0
            }
        }
        
        .tabItem {
            Image(systemName: "house.fill")
            Text("Home")
        }
        .sheet(isPresented: $isShowEditGoal,
               onDismiss: didDismiss) {
            EditGoalView()
        }
        
    }
    
    func didDismiss() {
        // Handle the dismissing action.
    }
    
    func getClosestIndex(to center: CGFloat, in geo: GeometryProxy) -> Int {
        var closestIndex = 0
        var minDistance = CGFloat.infinity
        for (i, _) in homeViewModel.glassOptions.enumerated() {
            let itemMid = geo.frame(in: .global).midX
            let distance = abs(itemMid - center)
            if distance < minDistance {
                minDistance = distance
                closestIndex = i
            }
        }
        return closestIndex
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel())
}


