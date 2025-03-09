//
//  ContentView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var weightData: WeightData
    @Binding var showDemographicsWindow: Bool
    
    var body: some View {
        NavigationStack {
            
        VStack {
            
            
            HStack {
                WeightEntryView(weightData: weightData, patient: $weightData.patient)
                    .frame(width: 800)
                Divider()
                Spacer()
                EventListView(weightData: weightData)
                Spacer()
            }
            
            Divider()
            ChartView(weightEntries: $weightData.patient.weightEntries, patient: weightData.patient)
            
            
        }
        .background(Color.white) // White background
                    .ignoresSafeArea()
                    .sheet(isPresented: $showDemographicsWindow) { 
                        DemographicsEntryView(
                            weightData: weightData,
                            name: $weightData.patient.name,
                            heightFeet: $weightData.patient.heightFeet,
                            heightInches: $weightData.patient.heightInches,
                            dateOfBirth: $weightData.patient.dateOfBirth)
                    }
                    .toolbarBackground(Color(red: 0.000, green: 0.325, blue: 0.608, opacity: 1.000), for: .automatic) // Set toolbar color
                    
        }
    }
}

#Preview {
    ContentView(weightData: WeightData(), showDemographicsWindow: .constant(false))
}
