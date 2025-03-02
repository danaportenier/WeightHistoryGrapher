import SwiftUI
import Charts
import AppKit

struct ChartOnlyView: View {
    @Binding var weightEntries: [WeightEntry]
    let patient: Patient

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                Text("Significant Weight History")
                    .font(.title2)
                    .bold()
                    if !patient.name.isEmpty {
                    Text("Patient: \(patient.name)")
                        .font(.headline)
                        Spacer()
                }
            }
            .padding(.bottom, 20)


            ZStack {
                ChartDesign(weightEntries: weightEntries, patient: patient)
                    .frame(height: 300)
                    .padding()
                    .frame(width: 900, height: 400)
            }
        }
    }
}
