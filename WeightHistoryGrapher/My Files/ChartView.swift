import SwiftUI
import Charts
import AppKit

struct ChartView: View {
    
    @Binding var weightEntries: [WeightHistoryModel]
    var body: some View {
        VStack {
            Text("Significant Weight History")
                .font(.title2)
                .bold()
                .padding(.bottom)
            
            let sortedEntries = weightEntries.sorted { ($0.date ?? 0) < ($1.date ?? 0) }
            let minYear = sortedEntries.compactMap({ $0.date }).min() ?? 1935
            let maxYear = sortedEntries.compactMap({ $0.date }).max() ?? 2060
            let minWeight = sortedEntries.compactMap({ $0.weight }).min() ?? 100
            let maxWeight = sortedEntries.compactMap({ $0.weight }).max() ?? 800
            ZStack {
            Chart(sortedEntries.indices, id: \.self) { index in
                let currentEntry = sortedEntries[index]
                let previousEntry = index > 0 ? sortedEntries[index - 1] : nil
                let isRising = (previousEntry?.weight ?? currentEntry.weight) <= currentEntry.weight
                
                LineMark(
                    x: .value("Date", currentEntry.date ?? 2000),
                    y: .value("Weight", currentEntry.weight)
                )
                .foregroundStyle(.blue)
                
                PointMark(
                    x: .value("Date", currentEntry.date ?? 2000),
                    y: .value("Weight", currentEntry.weight)
                )
                .foregroundStyle(.blue)
                .annotation(position: isRising ? .top : .bottom) {
                    Text(currentEntry.label)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .chartXScale(domain: minYear...maxYear)
            .chartYScale(domain: minWeight...maxWeight)
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue.formatted(.number.grouping(.never)))") // Prevents commas
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisValueLabel()
                    AxisGridLine()
                    AxisTick()
                }
            }
            // X-Axis Title
            .chartXAxisLabel("Year", position: .bottom, alignment: .center)
            
            // Y-Axis Title
            .chartYAxisLabel("Weight (lbs)", position: .leading, alignment: .center)
            .frame(height: 300)
            .padding()
        }
            .overlay(exportButtons, alignment: .bottomTrailing)
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
        let chartOnlyView = ChartOnlyView(weightEntries: $weightEntries)
        
        let renderer = ImageRenderer(content: chartOnlyView)
        renderer.scale = 2.0
        renderer.proposedSize = .init(width: 800, height: 600)
        
        if let image = renderer.nsImage {
            saveAsJPEG(image: image)
        }
    }
        
        // ✅ Function to Copy Chart to Clipboard
    private func copyChartToClipboard() {
        let chartOnlyView = ChartOnlyView(weightEntries: $weightEntries)
        
        let renderer = ImageRenderer(content: chartOnlyView)
        renderer.scale = 2.0
        renderer.proposedSize = .init(width: 800, height: 600)
        
        if let image = renderer.nsImage {
            copyImageToClipboard(image)
        }
    }
        
        // ✅ Function to Render Only the Chart (No Buttons)
        private func createChartOnlyView() -> some View {
            ChartView(weightEntries: $weightEntries)
                .padding()
                .frame(width: 800, height: 600)
        }
        
        // ✅ Save Chart as JPEG
        private func saveAsJPEG(image: NSImage) {
            guard let tiffData = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
                print("Failed to generate JPEG data")
                return
            }

            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.jpeg]
            savePanel.nameFieldStringValue = "WeightChart.jpg"

            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    do {
                        try jpegData.write(to: url)
                        print("Image saved successfully at: \(url.path)")
                    } catch {
                        print("Failed to save image: \(error)")
                    }
                } else {
                    print("User canceled save operation")
                }
            }
        }
        
        // ✅ Copy Chart as JPEG to Clipboard
    private func copyImageToClipboard(_ image: NSImage) {
        let finalImage = NSImage(size: image.size)
        finalImage.lockFocus()
        
        // ✅ Use NSBezierPath to fill background instead of deprecated NSRectFill
        NSColor.white.set()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height)).fill()
        
        // Draw the chart image on top
        image.draw(at: .zero, from: NSRect(origin: .zero, size: image.size), operation: .sourceOver, fraction: 1.0)
        
        finalImage.unlockFocus()

        guard let tiffData = finalImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
            print("Failed to generate JPEG data")
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(jpegData, forType: .tiff) // Use .tiff since .jpeg is not native to NSPasteboard
        print("Image copied to clipboard!")
    }
      
}

#Preview {
    ChartView(weightEntries: .constant([]))
}
