//
//  ContentView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var weightData: WeightData
    var body: some View {
        VStack {
            HStack {
            WeightEnteryView(weightData: weightData)
                Divider()
            VStack {
                EventListView(weightData: weightData)
            }
        }
            Divider()
                ChartView(weightEntries: $weightData.entries)
                
            
        }
        .padding()
    }
}

#Preview {
    ContentView(weightData: WeightData())
}
