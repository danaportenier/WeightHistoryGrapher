//
//  ChartOnlyView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/16/25.
//
import SwiftUI
import Charts
import AppKit

// Chart View Without Buttons for Exporting
struct ChartOnlyView: View {
    @Binding var weightEntries: [WeightHistoryModel]

    var body: some View {
        VStack {
            Text("Significant Weight History")
                .font(.title2)
                .bold()
                .padding(.bottom)
            
            let sortedEntries = weightEntries.sorted { ($0.date ?? 0) < ($1.date ?? 0) }
            let minYear = sortedEntries.compactMap({ $0.date }).min() ?? 1935
            let maxYear = sortedEntries.compactMap({ $0.date }).max() ?? 2060
            let minWeight = sortedEntries.compactMap({ $0.weight }).min() ?? 100
            let maxWeight = sortedEntries.compactMap({ $0.weight }).max() ?? 800
            
            ZStack {
                Chart(sortedEntries.indices, id: \.self) { index in
                    let currentEntry = sortedEntries[index]
                    let previousEntry = index > 0 ? sortedEntries[index - 1] : nil
                    let isRising = (previousEntry?.weight ?? currentEntry.weight) <= currentEntry.weight
                    
                    LineMark(
                        x: .value("Date", currentEntry.date ?? 2000),
                        y: .value("Weight", currentEntry.weight)
                    )
                    .foregroundStyle(.blue)
                    
                    PointMark(
                        x: .value("Date", currentEntry.date ?? 2000),
                        y: .value("Weight", currentEntry.weight)
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: isRising ? .top : .bottom) {
                        Text(currentEntry.label)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .chartXScale(domain: minYear...maxYear)
                .chartYScale(domain: minWeight...maxWeight)
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue.formatted(.number.grouping(.never)))") // Prevents commas
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                        AxisGridLine()
                        AxisTick()
                    }
                }
                // X-Axis Title
                .chartXAxisLabel("Year", position: .bottom, alignment: .center)
                
                // Y-Axis Title
                .chartYAxisLabel("Weight (lbs)", position: .leading, alignment: .center)
                .frame(height: 300)
                .padding()
            }
        }
        .frame(width: 800, height: 600) // Ensure consistent export size
        .background(Color.white) // Prevents transparency issues
    }
}
