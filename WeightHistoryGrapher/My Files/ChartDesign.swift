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
                        // Show no decimals; add "lbs"
                        Text("\(val, specifier: "%.0f") lbs")
                    }
                }
            }
        }
    }

    // MARK: - Mark Builders

    private func lineMark(for entry: WeightEntry) -> some ChartContent {
        LineMark(
            x: .value("Date", entry.date),
            y: .value("Weight", entry.weight)
        )
        .foregroundStyle(.blue)
    }

    private func pointMark(for entry: WeightEntry, index: Int) -> some ChartContent {
        PointMark(
            x: .value("Date", entry.date),
            y: .value("Weight", entry.weight)
        )
        .foregroundStyle(.blue)
        .annotation(position: .top) {
            annotationContent(for: entry, index: index)
        }
    }

    // MARK: - Annotation Builder

    @ViewBuilder
    private func annotationContent(for entry: WeightEntry, index: Int) -> some View {
        // Fix this line:
        let formattedDate = entry.date.formatted(.number.grouping(.never))
        
        let age = entry.ageAtEntry(dobYear: patient.dobYearInt ?? 0) ?? 0
        let bmi = entry.bmiAtEntry(heightMeters: patient.heightMeters) ?? 0.0
        let weightString = String(format: "%.0f", entry.weight)
        let bmiString = String(format: "%.0f", bmi)

        VStack(alignment: .leading, spacing: 4) {
            Text("\(formattedDate) \(entry.label)")
                .font(.caption)
                .bold()
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Text("Age: \(age)")
                Text("Weight: \(weightString) lbs")
                Text("BMI: \(bmiString)")
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.8))
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.blue.opacity(0.8))
                .shadow(radius: 2)
        )
    }
}
