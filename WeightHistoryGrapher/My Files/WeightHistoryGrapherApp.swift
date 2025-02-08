//
//  WeightHistoryGrapherApp.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//

import SwiftUI

//
//  WeightHistoryGrapherApp.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//

import SwiftUI

@main
struct WeightHistoryGrapherApp: App {
    @StateObject private var weightData = WeightData() // Stores weight entries

    var body: some Scene {
        WindowGroup {
            ContentView(weightData: weightData) // Pass a binding to allow modification
        }
    }
}

// ObservableObject to manage weight history
class WeightData: ObservableObject {
    @Published var entries: [WeightHistoryModel] = []
}
