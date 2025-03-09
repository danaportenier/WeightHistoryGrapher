import SwiftUI
import Charts
import AppKit

struct ChartOnlyView: View {
    @Binding var weightEntries: [WeightEntry]
    let patient: Patient

    // Same toggles as ChartView
    let showYear: Bool
    let showDescription: Bool
    let showAge: Bool
    let showBMI: Bool
    let showWeight: Bool
    let showAnnotationList: Bool

    var body: some View {
        // Provide a large overall container so that the side list
        // is guaranteed layout space if toggled on:
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

            // HStack for chart + optional annotation side list
            HStack(alignment: .top, spacing: 0) {
                ChartDesign(
                    weightEntries: weightEntries,
                    patient: patient,
                    showDate: showYear,
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
            // Enough space for chart + side list
            .frame(width: 1200, height: 700)
            .padding()
        }
        .background(Color.white)
    }
}
