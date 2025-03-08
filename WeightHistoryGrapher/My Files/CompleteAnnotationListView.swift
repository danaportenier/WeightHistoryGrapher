import SwiftUI

struct CompleteAnnotationListView: View {
    let weightEntries: [WeightEntry]
    let patient: Patient

    private var sortedEntries: [WeightEntry] {
        weightEntries.sorted { $0.date < $1.date }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Signifigant Weight Events")
                    .font(.headline)
                    .padding(.bottom, 4)

                // Enumerate sorted entries
                ForEach(sortedEntries.indices, id: \.self) { i in
                    let entry = sortedEntries[i]
                    let age = entry.ageAtEntry(dobYear: patient.dobYearInt ?? 0) ?? 0
                    let bmi = entry.bmiAtEntry(heightMeters: patient.heightMeters) ?? 0.0
                    let weightString = String(format: "%.0f", entry.weight)

                    // Display a compact layout:
                    VStack(alignment: .leading, spacing: 3) {
                        // Top line: index #, year, category
                        HStack(spacing: 6) {
                            Text("\(i + 1).") // E.g. "1." with no "Index:"
                                .fontWeight(.bold)
                            Text("\(entry.date.formatted(.number.grouping(.never)))")
                            HStack(spacing: 0) {
                            Text("\(entry.category.rawValue)")
                            // Label (if any)
                            if !entry.label.isEmpty {
                                Text(": \(entry.label)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            }
//                            Spacer()
                        }

                        // Middle line: age, BMI, weight
                        HStack(spacing: 8) {
                            Text("Age: \(age)")
                            Text("BMI: \(String(format: "%.0f", bmi))")
                            Text("Wt: \(weightString) lbs")
                        }

                        
                    }
                    .padding(.vertical, 4)

                    Divider()
                }
            }
            .padding(.horizontal, 6)
        }
    }
}
