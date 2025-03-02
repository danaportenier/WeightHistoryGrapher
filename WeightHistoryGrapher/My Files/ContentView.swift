//
//  ContentView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var weightData: WeightData
    @State private var patient = Patient()
    @Binding var showDemographicsWindow: Bool
    var body: some View {
        NavigationStack {
            
        VStack {
            
            
            HStack {
                WeightEnteryView(weightData: weightData, patient: $patient)
                    .frame(width: 800)
                Divider()
                EventListView(weightData: weightData)
                Spacer()
            }
            
            Divider()
            ChartView(weightEntries: $weightData.patient.weightEntries, patient: weightData.patient)
            
            
        }
        .background(Color.white) // White background
                    .ignoresSafeArea()
                    .navigationTitle("")
                    .sheet(isPresented: $showDemographicsWindow) { // ✅ Make sure this is here!
                        DemographicsEnteryView(
                            weightData: weightData,
                            name: $patient.name,
                            heightFeet: $patient.heightFeet,
                            heightInches: $patient.heightInches,
                            dobDay: $patient.dobDay,
                            dobMonth: $patient.dobMonth,
                            dobYear: $patient.dobYear
                        )
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                               
                            }
                    }
                    .toolbarBackground(Color(red: 0.000, green: 0.325, blue: 0.608, opacity: 1.000), for: .automatic) // Set toolbar color
                    
        }
    }
}

#Preview {
    ContentView(weightData: WeightData(), showDemographicsWindow: .constant(false))
}
