
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//
import SwiftUI


struct WeightHistoryModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var date: Int?
    var weight: Double
    var label: String
    var heighFeet: String = ""
    var heighInches: String = ""
    var name: String?
    
    // MARK: - Date of Birth
    
    var dobComponentDay: String = ""
    var dobComponentMonth: String = ""
    var dobComponentYear: String = ""
    
    var dobComponentDayFiltered: String {
        get { dobComponentDay }
        set {
            let filtered = newValue.filter { "0123456789".contains($0) }
            if let intValue = Int(filtered), intValue >= 1 && intValue <= 31 {
                dobComponentDay = String(intValue)
            }
        }
    }
        var dobComponentMonthFiltered: String {
                get { dobComponentMonth }
                set {
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if let intValue = Int(filtered), intValue >= 1 && intValue <= 12 {
                        dobComponentMonth = String(intValue)
                    }
                }
            }

        var dobComponentYearFiltered: String {
                get { dobComponentYear }
                set {
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if let intValue = Int(filtered), intValue >= 1920 && intValue <= 3000 {
                        dobComponentYear = String(intValue)
                    }
                }
            }

    var dob: Date? {
        guard let day = Int(dobComponentDayFiltered), let month = Int(dobComponentMonthFiltered), let year = Int(dobComponentYearFiltered) else {
            return nil
        }
        
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        
        // Check if the date is valid
        if components.isValidDate(in: Calendar.current) {
            return Calendar.current.date(from: components)
        } else {
                return nil
            }
        }
    
    var heightFeetMeasurement: Measurement<UnitLength> {
            let feetValue = Double(heighFeet) ?? 0
            return Measurement(value: feetValue, unit: UnitLength.feet)
        }
    
    var heightInchesMeasurement: Measurement<UnitLength> {
            let inchesValue = Double(heighInches) ?? 0
        return Measurement(value: inchesValue, unit: UnitLength.inches)
    }
    var totalHeightInches: Double {
        let feetInInches = heightFeetMeasurement.converted(to: .inches).value
        return feetInInches + heightInchesMeasurement.value
    }
    var heightMeters: Double {
        let feetInMeters = heightFeetMeasurement.converted(to: .meters).value
        let inchesInMeters = heightInchesMeasurement.converted(to: .meters).value
        return feetInMeters + inchesInMeters
    }
    
    var currentWeightLbsMeasurement: Measurement<UnitMass> {
        let weightLbsValue = weight
        return Measurement(value: weightLbsValue, unit: UnitMass.pounds)
    }
    
    var heightMetersSquared: Double {
        return pow(heightMeters, 2)
    }
    
    var currentWeightKg: Double {
        return currentWeightLbsMeasurement.converted(to: .kilograms).value
    }
    
    var currentBMI: Double {
        return currentWeightKg / heightMetersSquared
    }
    
}
