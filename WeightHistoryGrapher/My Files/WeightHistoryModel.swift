import SwiftUI

// Represents a single weight entry at a specific time point
struct WeightEntry: Identifiable, Hashable {
    let id: UUID = UUID()
    var date: Int
    var weight: Double
    var label: String
    
    func ageAtEntry(dobYear: Int) -> Int? {
            guard dobYear > 0 else { return nil }
            return max(0, date - dobYear) // Ensure non-negative age
        }


    func bmiAtEntry(heightMeters: Double) -> Double? {
        guard heightMeters > 0 else { return nil }
        let weightKg = weight * 0.453592  // Convert pounds to kg
        return weightKg / (heightMeters * heightMeters)
    }
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
    
    var dobYearInt: Int? {
            return Int(dobYear)
        }
    
    var currentAge: Int? {
            guard let day = Int(dobDay),
                  let month = Int(dobMonth),
                  let year = Int(dobYear) else {
                return nil  // Return nil if date of birth is not set correctly
            }

            let calendar = Calendar.current
            let birthDateComponents = DateComponents(year: year, month: month, day: day)
            guard let birthDate = calendar.date(from: birthDateComponents) else {
                return nil
            }

            let today = Date()
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: today)
            return ageComponents.year
        }
}
