//
//  EventListView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/9/25.
//

import SwiftUI

struct EventListView: View {
    
    @ObservedObject var weightData: WeightData
    
    var body: some View {
        VStack {
            Text("Weight Events")
                .font(.title2)
                .padding(.top, 2)
            
            if !weightData.patient.weightEntries.isEmpty {
                ForEach(weightData.patient.weightEntries, id: \.self) { entry in
                    let age = entry.ageAtEntry(dobYear: weightData.patient.dobYearInt ?? 0)
                        let bmi = entry.bmiAtEntry(heightMeters: weightData.patient.heightMeters)
                    HStack {
                        Text("Year: \(String(describing: entry.date)) || Lbs: \(formattedWeight(entry.weight))")
                            .lineLimit(1)
                        Text("Weight: \(String(format: "%.1f", entry.weight)) lbs")
                        if let age = age {
                                    Text("Age: \(age)")
                                } else {
                                    Text("Age: N/A")
                                }

                                if let bmi = bmi {
                                    Text("BMI: \(String(format: "%.1f", bmi))")
                                } else {
                                    Text("BMI: N/A")
                                }
                        
                       
                        
                        Button(action: {
                            deleteEntry(entry)
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .resizable()
                                .frame(width: 15, height: 15) // Resize the trash icon
                                .foregroundColor(.green)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 4) // Add spacing between rows
                }
            } else {
                Text("Add Weight History")
            }
        }
        .padding()
    }
    
    func deleteEntry(_ entry: WeightEntry) {
        if let index = weightData.patient.weightEntries.firstIndex(where: { $0.id == entry.id }) {
                    weightData.patient.weightEntries.remove(at: index)
                }
            }
    
    func formattedWeight(_ weight: Double) -> String {
        return String(format: "%.0f", weight) // Example: 150 instead of 150.5
    }
}

#Preview {
    EventListView(weightData: WeightData())
}
