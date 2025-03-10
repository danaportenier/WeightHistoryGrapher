import SwiftUI
import Charts

struct ChartDesign: View {
    let weightEntries: [WeightEntry]
    let patient: Patient
    
    // Allow toggles to show/hide these fields in chart annotations
    let showDate: Bool
    let showDescription: Bool
    let showAge: Bool
    let showBMI: Bool
    let showWeight: Bool
    
    // Sort entries so the chart lines and points go in ascending date order
    private var sortedEntries: [WeightEntry] {
        weightEntries.sorted { $0.date < $1.date }
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
                .annotation {
                            annotationContent(for: entry, index: index)
                                }
            }
        }
        
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                    AxisValueLabel(format:.dateTime.year())
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
    
   
    
    // MARK: - Building the Annotation View
    
    @ViewBuilder
    private func annotationContent(for entry: WeightEntry, index: Int) -> some View {
        let formattedDate = entry.date.formatted(.dateTime.year())
        let age = entry.ageAtEntry(dob: patient.dateOfBirth) ?? 0
        let bmi = entry.bmiAtEntry(heightMeters: patient.heightMeters) ?? 0.0
        let weightString = String(format: "%.0f", entry.weight)
        let bmiString = String(format: "%.0f", bmi)
        let correctedindex = index + 1
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 2) {
                // Always show index
                Text("\(correctedindex).")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
                
                // Show year only if "Show Year" is toggled
                if showDate {
                    Text("\(formattedDate)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                }
                if showAge {
                    Text("Age: \(age)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.black)
                }
            }
            
            
            // Pair the dropdown category with the typed label if "Show Description"
            if showDescription {
                VStack(alignment: .leading) {
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
                if showWeight {
                    Text("Weight: \(weightString) lbs")
                        .font(.caption2)
                        .foregroundColor(.black.opacity(0.8))
                }
                
                if showBMI {
                    Text("BMI: \(bmiString)")
                }
            }
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
