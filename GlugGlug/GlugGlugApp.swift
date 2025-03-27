//
//  GlugGlugApp.swift
//  GlugGlug
//
//  Created by Frengky Gunawan on 19/03/25.
//

import SwiftUI

@main
struct GlugGlugApp: App {
    
    @StateObject var homeViewModel: HomeViewModel = HomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(homeViewModel)
        }
    }
}
