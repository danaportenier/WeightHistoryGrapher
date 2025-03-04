//
//  ChartDesign.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/24/25.
//

import SwiftUI
import Charts

struct ChartDesign: View {
    let weightEntries: [WeightEntry]
    let patient: Patient

    // MARK: - Computed Properties

    private var sortedEntries: [WeightEntry] {
        weightEntries.sorted { $0.date < $1.date }
    }

    private var minYear: Int {
        sortedEntries.map(\.date).min() ?? 1935
    }

    private var maxYear: Int {
        sortedEntries.map(\.date).max() ?? 2060
    }

    private var minWeight: Double {
        sortedEntries.map(\.weight).min() ?? 100
    }

    private var maxWeight: Double {
        sortedEntries.map(\.weight).max() ?? 800
    }

    // MARK: - Body

    var body: some View {
        Chart {
            ForEach(sortedEntries.indices, id: \.self) { index in
                let entry = sortedEntries[index]

                // 1) Build the line mark
                lineMark(for: entry)

                // 2) Build the point mark with annotation
                pointMark(for: entry, index: index)
            }
        }
        .chartXScale(domain: (minYear - 5)...(maxYear + 5))
        .chartYScale(domain: (minWeight - 20)...(maxWeight + 40))
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        // Prevent commas
                        Text("\(intValue.formatted(.number.grouping(.never)))")
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let val = value.as(Double.self) {
                        Text("\(val, specifier: "%.0f") lbs")
                    }
                }
            }
        }
        .chartXAxisLabel("Years", position: .bottom, alignment: .center)
        .chartYAxisLabel("Weight (lbs)", position: .leading, alignment: .center)
    }

    // MARK: - Mark Builders

    private func lineMark(for entry: WeightEntry) -> some ChartContent {
        LineMark(
            x: .value("Date", entry.date),
            y: .value("Weight", entry.weight)
        )
        .foregroundStyle(.blue)
    }

    private func smartAnnotationPosition(for index: Int) -> AnnotationPosition {
        guard index > 0 else { return .top } // Default first annotation to top

        let currentX = sortedEntries[index].date
        let previousX = sortedEntries[index - 1].date
        
        // Determine if the current point is too close to the previous one
        let isTooClose = abs(currentX - previousX) < 5  // Adjust this threshold as needed

        if isTooClose {
            // If too close, flip the annotation position based on the previous entry
            return index.isMultiple(of: 2) ? .bottom : .top
        } else {
            // Otherwise, just alternate as usual
            return index.isMultiple(of: 2) ? .top : .bottom
        }
    }
    
    
    private func pointMark(for entry: WeightEntry, index: Int) -> some ChartContent {
        PointMark(
            x: .value("Date", entry.date),
            y: .value("Weight", entry.weight)
        )
        .foregroundStyle(.blue)
        .annotation(position: smartAnnotationPosition(for: index)) {
                annotationContent(for: entry, index: index)
            }
    }

    // MARK: - Annotation Builder

    @ViewBuilder
    private func annotationContent(for entry: WeightEntry, index: Int) -> some View {
       
        let formattedDate = entry.date.formatted(.number.grouping(.never))
        
        let age = entry.ageAtEntry(dobYear: patient.dobYearInt ?? 0) ?? 0
        let bmi = entry.bmiAtEntry(heightMeters: patient.heightMeters) ?? 0.0
        let weightString = String(format: "%.0f", entry.weight)
        let bmiString = String(format: "%.0f", bmi)

        VStack(alignment: .leading, spacing: 1) {
            Text("\(formattedDate) \(entry.category.rawValue)")
                .font(.caption)
                .bold()
                .foregroundColor(.black)
            Text("\(entry.label)")
                .font(.caption)
                .bold()
                .foregroundColor(.black)

            HStack(spacing: 1) {
                Text("Age: \(age)")
                Text("BMI: \(bmiString)")
            }
            .font(.caption2)
            .foregroundColor(.black.opacity(0.8))
            
            Text("Weight: \(weightString) lbs")
                .font(.caption2)
                .foregroundColor(.black.opacity(0.8))
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.8))
                .shadow(radius: 2)
        )
    }
}
