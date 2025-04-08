//
//  DuolingoButtonStyle.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 08/04/25.
//


import SwiftUI

struct CustomButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .textCase(.uppercase)
      .fontWeight(.bold)
      .fontDesign(.rounded)
      .frame(maxWidth: .infinity)
      .padding()
      .background(Color.blue)
      .clipShape(.rect(cornerRadius: 12))
      .foregroundStyle(.white)
      .shadow(color: Color(#colorLiteral(red: 0, green: 0.3580456972, blue: 0.7642293572, alpha: 1)), radius: 0, y: configuration.isPressed ? 0 : 4)
      .offset(y: configuration.isPressed ? 4 : 0)
      .animation(.bouncy(duration: 0.2), value: configuration.isPressed)
      .sensoryFeedback(
        configuration.isPressed
        ? .impact(flexibility: .soft, intensity: 0.75)
        : .impact(flexibility: .solid),
        trigger: configuration.isPressed
      )
  }
}
