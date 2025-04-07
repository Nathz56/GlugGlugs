//
//  AlertBanner.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 20/03/25.
//

import SwiftUI

struct AlertBanner: View {
    var message: String
    var iconName: String
    var backgroundColor: Color
    var foregroundColor: Color
    var textColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(foregroundColor)
                .imageScale(.large)
            
            Text(message)
                .font(.caption)
                .foregroundColor(textColor)
            
            Spacer() // Untuk mendorong elemen ke kiri dan kanan
        }
        .padding(12)
        .background(backgroundColor)
    }
}

#Preview {
    AlertBanner(message: "This is an alert!", iconName: "exclamationmark.triangle.fill", backgroundColor: .red, foregroundColor: .red, textColor: .white)
}
