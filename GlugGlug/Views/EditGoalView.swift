//
//  EditGoalView.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 27/03/25.
//

import SwiftUI


struct EditGoalView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedSegment = 0
    
    var body: some View {
        NavigationStack {
            VStack () {
                Picker("Options", selection: $selectedSegment) {
                    Text("Recommendation").tag(0)
                    Text("Custom").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom)
                
                if selectedSegment == 0 {
                    VStack {
                        Text("Halaman 1")
                    }
                } else {
                    VStack {
                        Text("Halaman 2")
                    }
                }
                Spacer()
            }
            .presentationDetents([.fraction(0.5)])
            .toolbar {
                ToolbarItem(placement: .principal) { // Title di tengah
                    Text("Edit Goal")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}
