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
        VStack {
            Text("Signifigant Weight History")
                .font(.title2)
                .bold()
        let minYear = weightEntries.compactMap({ $0.date }).min() ?? 1935
        let maxYear = weightEntries.compactMap({ $0.date }).max() ?? 2060
        
        let minWeight = weightEntries.compactMap({ $0.weight }).min() ?? 100
        let maxWeight = weightEntries.compactMap({ $0.weight }).max() ?? 800
        
        
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
        .chartXScale(domain: minYear...maxYear)
        .chartYScale(domain: minWeight...maxWeight)
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisValueLabel()
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
}
#Preview {
    ChartView(weightEntries: .constant([]))
}
