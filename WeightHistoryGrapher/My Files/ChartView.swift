import SwiftUI
import Charts
import AppKit

struct ChartView: View {
    @Binding var weightEntries: [WeightEntry]
    let patient: Patient

    // Toggles for chart annotation fields
    @State private var showYear = true
    @State private var showDescription = true
    @State private var showAge = true
    @State private var showBMI = true
    @State private var showWeight = true

    // Toggle for annotation list
    @State private var showAnnotationList = true

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 12) {

                // Title & Toggles
                VStack(spacing: 2) {
                    Text("Significant Weight History")
                        .font(.title2)
                        .bold()

                    if !patient.name.isEmpty {
                        Text("(Patient: \(patient.name))")
                            .font(.headline)
                    }
                }
                .padding(.bottom, 6)

                // Row of toggles
                HStack(spacing: 16) {
                    Toggle("Show Year", isOn: $showYear)
                        .toggleStyle(.checkbox)
                    Toggle("Show Description", isOn: $showDescription)
                        .toggleStyle(.checkbox)
                    Toggle("Show Age", isOn: $showAge)
                        .toggleStyle(.checkbox)
                    Toggle("Show BMI", isOn: $showBMI)
                        .toggleStyle(.checkbox)
                    Toggle("Show Weight", isOn: $showWeight)
                        .toggleStyle(.checkbox)
                    Toggle("Show Weight Event List", isOn: $showAnnotationList)
                        .toggleStyle(.checkbox)
                }

                // Chart + annotation list side by side
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
                    .overlay(exportButtons, alignment: .bottomTrailing)
                    .border(.gray.opacity(0.3), width: 1)

                    // If toggled on, show annotation list
                    if showAnnotationList {
                        CompleteAnnotationListView(
                            weightEntries: weightEntries,
                            patient: patient
                        )
                        .font(.caption2)
                        .frame(width: 250)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .transition(.move(edge: .trailing))
                    }
                }
                .animation(.default, value: showAnnotationList)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.white)
    }

    // MARK: - Export & Copy Buttons
    private var exportButtons: some View {
        HStack {
            Button(action: exportChart) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)

            Button(action: copyChartToClipboard) {
                Label("Copy", systemImage: "doc.on.clipboard")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Export Chart
    private func exportChart() {
        DispatchQueue.main.async {
            // Create a ChartOnlyView that matches user toggles
            let content = ChartOnlyView(
                weightEntries: $weightEntries,
                patient: patient,
                showYear: showYear,
                showDescription: showDescription,
                showAge: showAge,
                showBMI: showBMI,
                showWeight: showWeight,
                showAnnotationList: showAnnotationList
            )

            let renderer = ImageRenderer(content: content)
            renderer.scale = 2.0
            renderer.proposedSize = .init(width: 1000, height: 700)

            guard let image = renderer.nsImage else {
                print("❌ Error: Could not generate nsImage.")
                return
            }
            saveImageAsJPEG(image)
        }
    }

    // MARK: - Copy Chart
    private func copyChartToClipboard() {
        DispatchQueue.main.async {
            // Same toggles used here
            let content = ChartOnlyView(
                weightEntries: $weightEntries,
                patient: patient,
                showYear: showYear,
                showDescription: showDescription,
                showAge: showAge,
                showBMI: showBMI,
                showWeight: showWeight,
                showAnnotationList: showAnnotationList
            )

            let renderer = ImageRenderer(content: content)
            renderer.scale = 2.0
            renderer.proposedSize = .init(width: 1000, height: 700)

            guard let image = renderer.nsImage else {
                print("❌ Error: Could not generate nsImage for clipboard.")
                return
            }
            copyImageToClipboard(image)
        }
    }

    // MARK: - Save as JPEG
    private func saveImageAsJPEG(_ image: NSImage) {
        guard
            let tiffData = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData),
            let jpegData = bitmap.representation(using: .jpeg, properties: [:])
        else {
            print("❌ Error: Could not create JPEG data.")
            return
        }
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.jpeg]
        savePanel.nameFieldStringValue = "WeightChart.jpg"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try jpegData.write(to: url)
                    print("✅ Successfully saved at \(url.path)")
                } catch {
                    print("❌ Error saving image: \(error.localizedDescription)")
                }
            } else {
                print("User canceled save operation.")
            }
        }
    }

    // MARK: - Copy Image to Clipboard
    private func copyImageToClipboard(_ image: NSImage) {
        guard let tiff = image.tiffRepresentation else {
            print("❌ Error: no TIFF data found for image.")
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(tiff, forType: .tiff)
        print("✅ Image copied to clipboard!")
    }
}
