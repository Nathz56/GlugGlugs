//
//  HomeView.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI

struct HomeView: View {
    
    @State var startAnimation: CGFloat = 0.0
    @State var progress: Int = 1000
    @State var goal: Int = 2500
    @State var progressPercentage: CGFloat = 0.0
    @State var isShowEditGoal: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack () {
                Text("⏰ No reminders set! Add one to stay on track! 💧")
                    .font(.subheadline)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                AlertBanner(message: "Welcome! 🚀 Set your reminder, target, and tumbler size to stay hydrated! 💧", iconName: "lightbulb.fill", backgroundColor: .yellow.opacity(0.2), foregroundColor: .yellow, textColor: .black)
                    .padding(.bottom, 8)
                
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
                    Text("\(goal) ml ")
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
                    .padding(.bottom)
                
                
                Button {
                    progress += 100
                } label: {
                    Image(systemName: "plus")
                    Text("Add Water")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
            }
            .padding()
            .navigationTitle("GlugGlug!")
            
        }
        .onAppear {
            progressPercentage = CGFloat(progress) / CGFloat(goal)
        }
        .onChange(of: progress) {
            progressPercentage = CGFloat(progress) / CGFloat(goal)
        }
        .onChange(of: goal) {
            progressPercentage = CGFloat(progress) / CGFloat(goal)
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
    
}



#Preview {
    HomeView()
}


