//
//  DemographicsView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/19/25.
//

import SwiftUI

struct DemographicsView: View {
    @ObservedObject var weightData: WeightData
    
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter
        }()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Demographics:")
                .bold()
        HStack {
            
            if weightData.patient.heightFeet.isEmpty ||
                weightData.patient.heightInches.isEmpty ||
                weightData.patient.dateOfBirth == nil
               {
                
                Text("Enter Patient Demographics")
                    .font(.headline)
                    .foregroundColor(.red.opacity(0.6))
                
            } else {
                HStack(spacing: 16) { // Use HStack instead of VStack
                    Text("Height: \(weightData.patient.heightFeet) ft \(weightData.patient.heightInches) in")
                    Text("DOB: \(dateFormatter.string(from: weightData.patient.dateOfBirth ?? Date()))")
                    Text("Patient Name: \(weightData.patient.name)")
                    Text("Age: \(weightData.patient.currentAge ?? 30)")
                }
                .padding()
            }
        }
    }
        .frame(maxHeight: .none)
            }
        
    }

