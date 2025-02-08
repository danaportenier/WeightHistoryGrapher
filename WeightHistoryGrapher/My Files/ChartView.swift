//
//  ChartView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//
import SwiftUI
import Charts

struct ChartView: View {
    
    @Binding var weightEntries: [WeightHistoryModel]
    var body: some View {
        Chart(weightEntries) { weightEntry in
                    LineMark(
                        x: .value("Date", weightEntry.date ?? 2000),
                        y: .value("Weight", weightEntry.weight)
                            
                    )
                    .foregroundStyle(.blue)
            PointMark(
                                x: .value("Date", weightEntry.date ?? 2000),
                                y: .value("Weight", weightEntry.weight)
                            )
            .foregroundStyle(.blue)
            .annotation(position: .top) {
                                Text(weightEntry.label)
                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.blue)
                                    .padding()
                
                            }
                    
                    
                }
                .frame(height: 300)
                .padding()
    }
}
#Preview {
    ChartView(weightEntries: .constant([]))
}
