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
        NavigationStack {
            
        VStack {
            
            
            HStack {
                WeightEnteryView(weightData: weightData)
                Divider()
                VStack {
                    EventListView(weightData: weightData)
                }
            }
            
            Divider()
            ChartView(weightEntries: $weightData.patient.weightEntries)
            
            
        }
        .background(Color.white) // White background
                    .ignoresSafeArea()
                    .navigationTitle("")
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                               
                            }
                    }
                    .toolbarBackground(Color(red: 0.000, green: 0.325, blue: 0.608, opacity: 1.000), for: .automatic) // Set toolbar color
                    
        }
    }
}

#Preview {
    ContentView(weightData: WeightData())
}
