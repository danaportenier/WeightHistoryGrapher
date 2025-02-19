import SwiftUI

// Represents a single weight entry at a specific time point
struct WeightEntry: Identifiable, Hashable {
    let id: UUID = UUID()
    var date: Int
    var weight: Double
    var label: String
}

struct Patient: Identifiable, Hashable {
    let id: UUID = UUID()
    var name: String = ""
    var heightFeet: String = ""
    var heightInches: String = ""
    var dobDay: String = ""
    var dobMonth: String = ""
    var dobYear: String = ""
    var weightEntries: [WeightEntry] = []

    var heightMeters: Double {
        let feet = Double(heightFeet) ?? 0
        let inches = Double(heightInches) ?? 0
        let totalHeightInches = (feet * 12) + inches
        return totalHeightInches * 0.0254
    }

    var currentBMI: Double? {
        guard let latestWeight = weightEntries.last?.weight else { return nil }
        return latestWeight / (heightMeters * heightMeters)
    }
}
