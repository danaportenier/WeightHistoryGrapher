import SwiftUI
import Charts
import AppKit

struct ChartView: View {
    @Binding var weightEntries: [WeightEntry]
    let patient: Patient

    // Toggles for chart annotation fields
    @State private var showDate = true
    @State private var showDescription = true
    @State private var showAge = true
    @State private var showBMI = true
    @State private var showWeight = true

    // Toggle for the side annotation list
    @State private var showAnnotationList = true

    var body: some View {
        // Force a large scroll area so there's room for the side list
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 12) {
                
                // 1) Title + Toggles
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
                
                // 2) Row of Toggles
                HStack(spacing: 16) {
                    Toggle("Show Year", isOn: $showDate)
                    Toggle("Show Description", isOn: $showDescription)
                    Toggle("Show Age", isOn: $showAge)
                    Toggle("Show BMI", isOn: $showBMI)
                    Toggle("Show Weight", isOn: $showWeight)
                    
                    // Toggle controlling the side annotation list:
                    Toggle("Show Weight Event List", isOn: $showAnnotationList)
                }
                .toggleStyle(.checkbox)
                
                // 3) Chart + optional annotation list
                HStack(alignment: .top, spacing: 0) {
                    ChartDesign(
                        weightEntries: weightEntries,
                        patient: patient,
                        showDate: showDate,
                        showDescription: showDescription,
                        showAge: showAge,
                        showBMI: showBMI,
                        showWeight: showWeight
                    )
                    .frame(minWidth: 800, minHeight: 400)
                    .border(.gray.opacity(0.3), width: 1)
                    
                    // Instead of a transition, just conditionally show/hide
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
                // Move the export buttons below the chart
                HStack {
                    Spacer() // Pushes buttons to trailing edge
                    exportButtons
                }
                .padding(.top, 10)
                // No transition(...) => no chance the list is at zero size
                // Also no .animation(...) => we want an immediate layout
                
            }
            .padding()
            // Give the entire container a big, fixed size
            .frame(width: 1200, height: 800)
        }
        .background(Color.white)
    }

    // MARK: - Export/Copy Buttons at bottom-right
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

    // MARK: - Export Chart as an Image
    private func exportChart() {
        // Optional: small delay ensures layout commits
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Construct the ChartOnlyView using the same toggle states
            let content = ChartOnlyView(
                weightEntries: $weightEntries,
                patient: patient,
                showYear: showDate,
                showDescription: showDescription,
                showAge: showAge,
                showBMI: showBMI,
                showWeight: showWeight,
                showAnnotationList: showAnnotationList
            )

            // Render as an NSImage
            let renderer = ImageRenderer(content: content)
            renderer.scale = 2.0
            // Provide enough room for chart + side list if toggled
            renderer.proposedSize = .init(width: 1200, height: 800)

            guard let image = renderer.nsImage else {
                print("❌ Error: Could not generate nsImage for export.")
                return
            }
            saveImageAsJPEG(image)
        }
    }

    // MARK: - Copy Chart to Clipboard
    private func copyChartToClipboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let content = ChartOnlyView(
                weightEntries: $weightEntries,
                patient: patient,
                showYear: showDate,
                showDescription: showDescription,
                showAge: showAge,
                showBMI: showBMI,
                showWeight: showWeight,
                showAnnotationList: showAnnotationList
            )

            let renderer = ImageRenderer(content: content)
            renderer.scale = 2.0
            renderer.proposedSize = .init(width: 1200, height: 800)

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
