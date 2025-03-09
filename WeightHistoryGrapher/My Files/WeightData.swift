import SwiftUI

class WeightData: ObservableObject {
    @Published var patient: Patient = WeightData.load() {
        didSet {
            save() // Save whenever data changes
        }
    }

    // MARK: - Save Data
    private func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(patient) {
            UserDefaults.standard.set(encoded, forKey: "savedPatientData")
        }
    }

    // MARK: - Load Data
    static func load() -> Patient {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: "savedPatientData"),
           let decoded = try? decoder.decode(Patient.self, from: savedData) {
            return decoded
        }
        return Patient() // Return empty patient if no saved data exists
    }

    func resetAll() {
        patient = Patient() // Reset patient object
        objectWillChange.send() // Force UI update
    }

    func addWeightEntry(date: Date, weight: Double, label: String, category: LifeEventCategory) {
        patient.weightEntries.append(
            WeightEntry(date: date, weight: weight, label: label, category: category)
        )
    }
}
