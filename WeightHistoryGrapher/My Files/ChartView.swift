import SwiftUI
import Charts
import AppKit

struct ChartView: View {
    
    @Binding var weightEntries: [WeightEntry]
    let patient: Patient

    var body: some View {
        VStack {
            Text("Significant Weight History")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            

            let sortedEntries = weightEntries.sorted { ($0.date) < ($1.date) }
            let minYear = sortedEntries.compactMap({ $0.date }).min() ?? 1935
            let maxYear = sortedEntries.compactMap({ $0.date }).max() ?? 2060
            let minWeight = sortedEntries.compactMap({ $0.weight }).min() ?? 100
            let maxWeight = sortedEntries.compactMap({ $0.weight }).max() ?? 800

            ZStack {
                    Chart(sortedEntries.indices, id: \.self) { index in
                        let currentEntry = sortedEntries[index]
                        let previousEntry = index > 0 ? sortedEntries[index - 1] : nil
                       
                        
                        LineMark(
                            x: .value("Date", currentEntry.date),
                            y: .value("Weight", currentEntry.weight)
                        )
                        .foregroundStyle(.blue)
                        
                        let isNearTop = currentEntry.weight >= maxWeight - 20
                        let isNearBottom = currentEntry.weight <= minWeight + 20
                        let isNearRight = currentEntry.date >= maxYear - 5
                        let isNearLeft = currentEntry.date <= minYear + 5
                        
                        PointMark(
                            x: .value("Date", currentEntry.date),
                            y: .value("Weight", currentEntry.weight)
                        )
                        .foregroundStyle(.blue)
                        .annotation(position: isNearTop ? .bottom : .top) {
                            let age = currentEntry.ageAtEntry(dobYear: patient.dobYearInt ?? 0) ?? 0
                            let bmi = currentEntry.bmiAtEntry(heightMeters: patient.heightMeters) ?? 0.0
                            let weightString = String(format: "%.0f", currentEntry.weight)
                            let bmiString = String(format: "%.0f", bmi)

                            VStack(alignment: .leading, spacing: 0.5) {
                                
                                Text("\(index + 1). \(currentEntry.label)")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                Text("Age: \(age)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.8))
                                HStack {
                                    
                                    Text("Weight: \(weightString) lbs")
                                    Text("BMI: \(bmiString)")
                                }
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.blue.opacity(0.8))
                                    .shadow(radius: 2)
                            )
                            .offset(
                                x: isNearRight ? -90 : (isNearLeft ? 50 : 0),
                                y: isNearTop ? -70 : (isNearBottom ? 30 : (index % 2 == 0) ? -50 : 30) // Adjust placement
                            )
                        }
                    }
                    .chartXScale(domain: (minYear - 5)...(maxYear + 5))
                    .chartYScale(domain: (minWeight - 20)...(maxWeight + 40))
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
                    .frame(width: 900, height: 400) // Ensure the chart is properly sized
                
            }
            .overlay(exportButtons, alignment: .bottomTrailing) // Fix overlay placement
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
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(image.tiffRepresentation, forType: .tiff)
        print("Image copied to clipboard!")
    }
}

#Preview {
    ChartView(weightEntries: .constant([]), patient: Patient())
}
