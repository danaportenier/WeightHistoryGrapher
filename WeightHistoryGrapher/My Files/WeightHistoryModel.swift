import SwiftUI


enum LifeEventCategory: String, CaseIterable, Codable {
    case pickOne = "Pick One"
    case graduatedHighSchool = "Graduated High School"
    case graduatedCollege = "Graduated College"
    case gotMarried = "Got Married"
    case hadBaby = "Had a Baby"
    case gotDivorced = "Got Divorced"
    case moved = "Moved to a New City"
    case changedCareers = "Changed Job/Careers"
    case lifeStress = "New Stress"
    case lostLovedOne = "Lost a Loved One"
    case startedWorkout = "Started a New Workout Program"
    case startedDiet = "Started a Diet/Nutrition Plan"
    case startedMedication = "Started/Stopped Medication"
    case startedWeigthLossMedication = "Started/Stopped a Weight Loss Medication"
    case surgery = "Underwent Surgery"
    case bariatricSurgery = "Underwent Bariatric Surgery"
    case quitSmoking = "Quit Smoking"
    case stoppedDrinking = "Stopped Drinking Alcohol"
    case chronicIllness = "Diagnosed with a Chronic Illness"
    case mentalHealthTreatment = "Began Mental Health Treatment"
    case majorStress = "Experienced Major Stress/Depression"
    case menopause = "Menopause"
    case retirement = "Retirement"
    case other = "Other"
}

// Represents a single weight entry at a specific time point
struct WeightEntry: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var date: Int
    var weight: Double
    var label: String
    var category: LifeEventCategory
    
    init(id: UUID = UUID(), date: Int, weight: Double, label: String, category: LifeEventCategory) {
            self.id = id
            self.date = date
            self.weight = weight
            self.label = label
            self.category = category
        }
    
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

struct Patient: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var heightFeet: String = ""
    var heightInches: String = ""
    var dobDay: String = ""
    var dobMonth: String = ""
    var dobYear: String = ""
    var weightEntries: [WeightEntry] = []

    mutating func resetAll() {
            name = ""
            heightFeet = ""
            heightInches = ""
            dobDay = ""
            dobMonth = ""
            dobYear = ""
        }
    
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
