import SwiftUI

class WeightData: ObservableObject {
    @Published var patient: Patient = Patient() {
        didSet {
            objectWillChange.send()
        }
    }
    
    func resetAll() {
        patient = Patient() // Completely resets the patient
    }
    
    func addWeightEntry(date: Int, weight: Double, label: String) {
        patient.weightEntries.append(WeightEntry(date: date, weight: weight, label: label))
    }
}
