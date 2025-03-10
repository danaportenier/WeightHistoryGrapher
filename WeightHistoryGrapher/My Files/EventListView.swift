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
        VStack(alignment: .center) {
            Text("Delete Weight Events")
                .font(.title2)
                .padding(.top)
                .underline()
            
            if !weightData.patient.weightEntries.isEmpty {
                VStack {
                ForEach(weightData.patient.weightEntries, id: \.self) { entry in
                    let age = entry.ageAtEntry(dob: weightData.patient.dateOfBirth)
                    let bmi = entry.bmiAtEntry(heightMeters: weightData.patient.heightMeters)
                    HStack {
                        Text("Year: \(entry.date.formatted(.dateTime.year()))")
                            .lineLimit(1)
                        if let age = age {
                            Text("Age: \(age)")
                        } else {
                            Text("Age: N/A")
                        }
                        
                        Text("Weight: \(String(format: "%.1f", entry.weight)) lbs")
                        
                        
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
                Spacer()
            }
                .animation(.easeInOut(duration: 0.4), value: weightData.patient.weightEntries.count)
            } else {
                VStack {
                    Text("Add Weight History")
                        .padding(.top)
                    Spacer()
                    
                    Image("Chart")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .transition(.opacity.combined(with: .scale)) // Smooth fade-out and scale effect
                        .animation(.easeInOut(duration: 0.8), value: weightData.patient.weightEntries.count)
                    
                    Spacer()
                }
            }
        }
        .padding(.top, 20)
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
