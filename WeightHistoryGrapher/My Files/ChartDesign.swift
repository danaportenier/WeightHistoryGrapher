import SwiftUI
import Charts

struct ChartDesign: View {
    let weightEntries: [WeightEntry]
    let patient: Patient
    
    // Allow toggles to show/hide these fields in chart annotations
    let showYear: Bool
    let showDescription: Bool
    let showAge: Bool
    let showBMI: Bool
    let showWeight: Bool
    
    // Sort entries so the chart lines and points go in ascending date order
    private var sortedEntries: [WeightEntry] {
        weightEntries.sorted { $0.date < $1.date }
    }
    
    // Compute the min/max year, min/max weight for chart scaling
    private var minYear: Int {
        sortedEntries.map(\.date).min() ?? 1930
    }
    private var maxYear: Int {
        sortedEntries.map(\.date).max() ?? 2050
    }
    private var minWeight: Double {
        sortedEntries.map(\.weight).min() ?? 90
    }
    private var maxWeight: Double {
        sortedEntries.map(\.weight).max() ?? 500
    }
    
    var body: some View {
        Chart {
            ForEach(sortedEntries.indices, id: \.self) { index in
                let entry = sortedEntries[index]
                
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(.blue)
                
                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(.blue)
                .annotation(position: smartAnnotationPosition(for: index)) {
                    annotationContent(for: entry, index: index)
                }
            }
        }
        .chartXScale(domain: (minYear - 5)...(maxYear + 5))
        .chartYScale(domain: (minWeight - 20)...(maxWeight + 40))
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        // Prevent commas for years
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
    
    // MARK: - Customizing Annotation Position
    
    private func smartAnnotationPosition(for index: Int) -> AnnotationPosition {
        // If this is the first data point, just put annotation on top
        guard index > 0 else { return .top }
        
        let currentX = sortedEntries[index].date
        let previousX = sortedEntries[index - 1].date
        
        // If points are too close in X, alternate top/bottom to avoid overlap
        let isTooClose = abs(currentX - previousX) < 5
        if isTooClose {
            return index.isMultiple(of: 2) ? .bottom : .top
        } else {
            return index.isMultiple(of: 2) ? .top : .bottom
        }
    }
    
    // MARK: - Building the Annotation View
    
    @ViewBuilder
    private func annotationContent(for entry: WeightEntry, index: Int) -> some View {
        let formattedDate = entry.date.formatted(.number.grouping(.never))
        let age = entry.ageAtEntry(dobYear: patient.dobYearInt ?? 0) ?? 0
        let bmi = entry.bmiAtEntry(heightMeters: patient.heightMeters) ?? 0.0
        let weightString = String(format: "%.0f", entry.weight)
        let bmiString = String(format: "%.0f", bmi)
        let correctedindex = index + 1
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                // Always show index
                Text("\(correctedindex).")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
                
                // Show year only if "Show Year" is toggled
                if showYear {
                    Text("\(formattedDate)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                }
            }
            
            
            // Pair the dropdown category with the typed label if "Show Description"
            if showDescription {
                VStack {
                Text("\(entry.category.rawValue)")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
                
                    if !entry.label.isEmpty {Text("\(entry.label)")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.gray.opacity(0.8))
                    }
            }
            }
            
            HStack(spacing: 6) {
                if showAge {
                    Text("Age: \(age)")
                }
                if showBMI {
                    Text("BMI: \(bmiString)")
                }
            }
            .font(.caption2)
            .foregroundColor(.black.opacity(0.8))
            
            if showWeight {
                Text("Weight: \(weightString) lbs")
                    .font(.caption2)
                    .foregroundColor(.black.opacity(0.8))
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.8))
                .shadow(radius: 2)
        )
    }
}
