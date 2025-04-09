//
//  StreakView.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 08/04/25.
//


import SwiftUI

struct StreakView: View {
    var streakCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundColor(.blue)
                .font(.system(size: 16))

            Text("\(streakCount) day\(streakCount != 1 ? "s" : "")")
                .font(.subheadline)
                .foregroundColor(.blue)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}
