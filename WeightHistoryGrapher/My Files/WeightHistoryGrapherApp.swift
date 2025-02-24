import SwiftUI

@main
struct WeightHistoryGrapherApp: App {
    @StateObject private var weightData = WeightData()
        @State private var showDemographicsWindow = false

    var body: some Scene {
        WindowGroup {
            ContentView(weightData: weightData, showDemographicsWindow: $showDemographicsWindow)
        }
        .windowToolbarStyle(.expanded)
        .commands {
            CommandMenu("WeightGrapher") {
                Button("Add Demographics") {
                    showDemographicsWindow.toggle() 
                }
                .keyboardShortcut("D", modifiers: [.command])

                Button("Export Chart") {
                    exportChart(view: ChartView(weightEntries: $weightData.patient.weightEntries, patient: weightData.patient))
                }
                .keyboardShortcut("E", modifiers: [.command])

                Button("Copy Chart to Clipboard") {
                    copyChartToClipboard(view: ChartView(weightEntries: $weightData.patient.weightEntries, patient: weightData.patient))
                }
                .keyboardShortcut("C", modifiers: [.command])

                Divider()

                Button("Reset All Data") {
                    weightData.resetAll()
                }
                .keyboardShortcut("R", modifiers: [.command, .shift])

                Divider()

                Button("Quit WeightGrapher") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("Q", modifiers: [.command])
            }
        }
    }

    /// ✅ Function to Export Chart
    private func exportChart(view: some View) {
        let renderer = ImageRenderer(content: view) // ✅ Use a SwiftUI view
        renderer.scale = 2.0

        if let image = renderer.nsImage {
            saveAsJPEG(image: image)
        } else {
            print("❌ Error: Failed to generate image for export.")
        }
    }

    /// ✅ Function to Copy Chart to Clipboard
    private func copyChartToClipboard(view: some View) {
        let renderer = ImageRenderer(content: view) // ✅ Use a SwiftUI view
        renderer.scale = 2.0

        if let image = renderer.nsImage {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setData(image.tiffRepresentation, forType: .tiff)
            print("✅ Image copied to clipboard!")
        } else {
            print("❌ Error: Failed to generate image for clipboard.")
        }
    }

    /// ✅ Function to Save Chart as JPEG
    private func saveAsJPEG(image: NSImage) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.jpeg]
        savePanel.nameFieldStringValue = "WeightChart.jpg"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    if let tiffData = image.tiffRepresentation,
                       let bitmap = NSBitmapImageRep(data: tiffData),
                       let jpegData = bitmap.representation(using: .jpeg, properties: [:]) {
                        try jpegData.write(to: url)
                        print("✅ Image saved successfully at: \(url.path)")
                    }
                } catch {
                    print("❌ Error saving image: \(error)")
                }
            } else {
                print("User canceled save operation.")
            }
        }
    }
}
