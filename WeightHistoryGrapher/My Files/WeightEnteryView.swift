//
//  WeightEnteryView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//

import SwiftUI

struct WeightEnteryView: View {
    
    @ObservedObject var weightData: WeightData
    @State private var label: String = ""
    @State private var weight: Double = 0
    @State private var date: Int = 2025
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Time Point:")
                    .frame(width: 120, alignment: .leading) // Set a fixed width for labels
                TextField("Enter Significant Weight Time Point", text: $label)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Text("Weight (lbs):")
                    .frame(width: 120, alignment: .leading)
                TextField("Enter Weight in Pounds", value: $weight, formatter: integerFormatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150) // Consistent field width
            }
            
            HStack {
                Text("Year:")
                    .frame(width: 120, alignment: .leading)
                TextField("Enter Year", value: $date, formatter: integerFormatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
            }
        }
        .padding()
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button("Add", action: addWeightEntry)
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                    .padding(.horizontal)
                Button("Reset All", action: resetAll)
                    .padding(.bottom)
                    .padding(.horizontal)
                    .buttonStyle(.borderedProminent)
                    
               
            }
            .padding(.trailing, 30)
            
        }
        
    }
    func resetAll() {
        weightData.entries = []
    }
    
    func addWeightEntry() {
        let newEntry = WeightHistoryModel(date: date, weight: weight, label: label)
        weightData.entries.append(newEntry)
        label = ""
        weight = 0
        // date = 2025
    }
    
    private var integerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        return formatter
    }
}

#Preview {
    WeightEnteryView(weightData: WeightData())
}
