//
//  DemographicsView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/19/25.
//

import SwiftUI

struct DemographicsView: View {
    @ObservedObject var weightData: WeightData  // <-- Needs to observe the WeightData object

    var body: some View {
        VStack(alignment: .leading) {
            Text("Demographics:")
                .bold()
        HStack {
            
            if weightData.patient.heightFeet.isEmpty ||
                weightData.patient.heightInches.isEmpty ||
                weightData.patient.dobDay.isEmpty ||
                weightData.patient.dobMonth.isEmpty ||
                weightData.patient.dobYear.isEmpty {
                
                Text("Enter Patient Demographics")
                    .font(.headline)
                    .foregroundColor(.red.opacity(0.6))
                
            } else {
                HStack(spacing: 16) { // Use HStack instead of VStack
                    Text("Height: \(weightData.patient.heightFeet) ft \(weightData.patient.heightInches) in")
                    Text("DOB: \(weightData.patient.dobMonth)/\(weightData.patient.dobDay)/\(weightData.patient.dobYear)")
                    Text("Patient Name: \(weightData.patient.name)")
                }
                .padding()
            }
        }
    }
        .frame(maxHeight: .none)
            }
        
    }

