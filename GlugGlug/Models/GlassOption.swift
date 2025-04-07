//
//  GlassOption.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 07/04/25.
//

import SwiftUI

struct GlassOption: Identifiable, Codable, Equatable {
    let id: UUID
    let icon: String
    let amount: Int

    init(id: UUID = UUID(), icon: String, amount: Int) {
        self.id = id
        self.icon = icon
        self.amount = amount
    }
}

