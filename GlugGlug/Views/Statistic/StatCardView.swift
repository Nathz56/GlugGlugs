//
//  StatCardView.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 08/04/25.
//


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
                    .foregroundColor(.black)
            }

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    StatCardView(iconName: "person.circle", title: "Name", value: "John Doe", backgroundColor: .yellow)
}
