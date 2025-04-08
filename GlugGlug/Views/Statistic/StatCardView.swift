//
//  StatCardView.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 08/04/25.
//

import SwiftUI

struct StatCardView: View {
    let iconName: String
    let title: String
    let value: String
    let backgroundColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 2)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    StatCardView(iconName: "person.circle", title: "Name", value: "John Doe", backgroundColor: .blue.opacity(0.1))
}
