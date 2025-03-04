import SwiftUI
import Charts
import AppKit

struct ChartView: View {
    @Binding var weightEntries: [WeightEntry]
    let patient: Patient

    var body: some View {
        VStack {
            VStack {
            Text("Significant Weight History")
                .font(.title2)
                .bold()
            if !patient.name.isEmpty {
                Text("(Patient: \(patient.name))")
                    .font(.headline)
            }
        }
            .padding(.bottom, 20)

            ZStack {
                GeometryReader { geometry in
                    ChartDesign(weightEntries: weightEntries, patient: patient)
                        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
                        .padding()
                }
            }
            .frame(minWidth: 900, minHeight: 400) // Ensures a minimum frame size
            .overlay(exportButtons, alignment: .bottomTrailing)
            .padding(.bottom)
        }
    }

    // Export and Copy Buttons
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

    // ✅ Function to Export Chart as JPEG
    private func exportChart() {
        let chartOnlyView = ChartOnlyView(weightEntries: $weightEntries, patient: patient)
        let renderer = ImageRenderer(content: chartOnlyView)
        renderer.scale = 2.0
        renderer.proposedSize = .init(width: 800, height: 600)

        if let image = renderer.nsImage {
            saveAsJPEG(image: image)
        } else {
            print("Error: Failed to generate image for export.")
        }
    }

    // ✅ Function to Copy Chart to Clipboard
    private func copyChartToClipboard() {
        let chartOnlyView = ChartOnlyView(weightEntries: $weightEntries, patient: patient)
        let renderer = ImageRenderer(content: chartOnlyView)
        renderer.scale = 2.0
        renderer.proposedSize = .init(width: 800, height: 600)

        if let image = renderer.nsImage {
            copyImageToClipboard(image)
        } else {
            print("Error: Failed to generate image for clipboard.")
        }
    }

    // ✅ Save Chart as JPEG
    private func saveAsJPEG(image: NSImage) {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
            print("Error: Failed to generate JPEG data.")
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.jpeg]
        savePanel.nameFieldStringValue = "WeightChart.jpg"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try jpegData.write(to: url)
                    print("✅ Image saved successfully at: \(url.path)")
                } catch {
                    print("❌ Error saving image: \(error)")
                }
            } else {
                print("User canceled save operation.")
            }
        }
    }

    // ✅ Copy Chart as JPEG to Clipboard
    private func copyImageToClipboard(_ image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(image.tiffRepresentation, forType: .tiff)
        print("✅ Image copied to clipboard!")
    }
}

#Preview {
    ChartView(weightEntries: .constant([]), patient: Patient())
}
