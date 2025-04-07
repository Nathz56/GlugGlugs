//
//  GlassOptionEditorView.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 07/04/25.
//

import SwiftUI

struct GlassOptionEditorView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @State private var newAmount: String = ""
    @State private var newIcon: String = "drop.fill"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Glass Option")) {
                    TextField("Amount (ml)", text: $newAmount)
                        .keyboardType(.numberPad)

                    TextField("SF Symbol Icon", text: $newIcon)

                    Button("Add") {
                        if let amount = Int(newAmount) {
                            homeViewModel.addGlass(icon: newIcon, amount: amount)
                            newAmount = ""
                            newIcon = "drop.fill"
                        }
                    }
                }

                Section(header: Text("Existing Glass Options")) {
                    ForEach(homeViewModel.glassOptions.indices, id: \.self) { i in
                        HStack {
                            Image(systemName: homeViewModel.glassOptions[i].icon)
                            Text("\(homeViewModel.glassOptions[i].amount) ml")
                            Spacer()
                            Button(role: .destructive) {
                                homeViewModel.removeGlass(at: i)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Glass Options")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    GlassOptionEditorView()
        .environmentObject(HomeViewModel())
}
