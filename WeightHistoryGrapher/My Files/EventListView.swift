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
            
            if !weightData.entries.isEmpty {
                ForEach(weightData.entries, id: \.self) { entry in
                    HStack {
                        Text("Year: \(String(describing: entry.date!)) || Lbs: \(formattedWeight(entry.weight))")
                            .lineLimit(1) // Ensure text remains on one line
                        
                       
                        
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
                Text("Enter some Events")
            }
        }
        .padding()
    }
    
    func deleteEntry(_ entry: WeightHistoryModel) {
        if let index = weightData.entries.firstIndex(where: { $0.id == entry.id }) {
            weightData.entries.remove(at: index)
        }
    }
    
    func formattedWeight(_ weight: Double) -> String {
        return String(format: "%.0f", weight) // Example: 150 instead of 150.5
    }
}

#Preview {
    EventListView(weightData: WeightData())
}
