import SwiftUI
import Charts
import AppKit

struct ChartOnlyView: View {
    @Binding var weightEntries: [WeightEntry]
    let patient: Patient

    // The same toggles as in ChartView
    let showYear: Bool
    let showDescription: Bool
    let showAge: Bool
    let showBMI: Bool
    let showWeight: Bool

    let showAnnotationList: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            VStack(spacing: 0) {
                Text("Significant Weight History")
                    .font(.title2)
                    .bold()
                if !patient.name.isEmpty {
                    Text("Patient: \(patient.name)")
                        .font(.headline)
                }
            }
            .padding(.bottom, 8)

            // Same layout: chart + optional annotation list
            HStack(alignment: .top, spacing: 0) {
                ChartDesign(
                    weightEntries: weightEntries,
                    patient: patient,
                    showYear: showYear,
                    showDescription: showDescription,
                    showAge: showAge,
                    showBMI: showBMI,
                    showWeight: showWeight
                )
                .frame(minWidth: 800, minHeight: 400)

                if showAnnotationList {
                    CompleteAnnotationListView(
                        weightEntries: weightEntries,
                        patient: patient
                    )
                    .font(.caption2)
                    .frame(width: 250)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                }
            }
            .frame(width: 1000, height: 700)
            .padding()
        }
        .background(Color.white)
    }
}
