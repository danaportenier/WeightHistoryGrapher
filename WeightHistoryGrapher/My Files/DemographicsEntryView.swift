import SwiftUI

struct DemographicsEntryView: View {
    @ObservedObject var weightData: WeightData
    @Binding var name: String
    @Binding var heightFeet: String
    @Binding var heightInches: String
    @Binding var dobDay: String
    @Binding var dobMonth: String
    @Binding var dobYear: String
    @Environment(\.dismiss) var dismiss

    @FocusState private var focusedField: Field?

    
    
    enum Field {
        case name, heightFeet, heightInches, dobDay, dobMonth, dobYear, saveButton
    }

    var isValid: Bool {
        guard let feet = Int(heightFeet), (3...8).contains(feet),
              let inches = Int(heightInches), (0...12).contains(inches),
              let month = Int(dobMonth), (1...12).contains(month),
              let day = Int(dobDay), (1...31).contains(day),
              let year = Int(dobYear), (1930...3000).contains(year) else {
            return false
        }
        return true
    }
    
    private func validateYear() {
        if let year = Int(dobYear) {
            if year < 1930 {
                dobYear = "1930"
            } else if year > 3000 {
                dobYear = "3000"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Enter Demographics")
                .font(.headline)
                .padding(.bottom)

            Text("Patient Name")
                .bold()
            TextField("Name", text: $name)
                .textFieldStyle(.plain)
                .focused($focusedField, equals: .name)
                .onSubmit { focusedField = .heightFeet }

            VStack(alignment: .leading, spacing: 10) {
                Text("Height")
                    .bold()
                HStack {
                    TextField("Feet", text: $heightFeet)
                        .textFieldStyle(.plain)
                        .frame(width: 80)
                        .focused($focusedField, equals: .heightFeet)
                        .onChange(of: heightFeet) { newValue in
                            if let feet = Int(newValue), feet < 3 { heightFeet = "3" }
                            if let feet = Int(newValue), feet > 8 { heightFeet = "8" }
                        }
                        .onSubmit { focusedField = .heightInches }

                    TextField("Inches", text: $heightInches)
                        .textFieldStyle(.plain)
                        .frame(width: 80)
                        .focused($focusedField, equals: .heightInches)
                        .onChange(of: heightInches) { newValue in
                            if let inches = Int(newValue), inches < 0 { heightInches = "0" }
                            if let inches = Int(newValue), inches > 12 { heightInches = "12" }
                        }
                        .onSubmit { focusedField = .dobMonth }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Date of Birth")
                    .bold()
                HStack {
                    TextField("Month", text: $dobMonth)
                        .textFieldStyle(.plain)
                        .frame(width: 60)
                        .focused($focusedField, equals: .dobMonth)
                        .onChange(of: dobMonth) { newValue in
                            if let month = Int(newValue), month < 1 { dobMonth = "1" }
                            if let month = Int(newValue), month > 12 { dobMonth = "12" }
                        }
                        .onSubmit { focusedField = .dobDay }

                    TextField("Day", text: $dobDay)
                        .textFieldStyle(.plain)
                        .frame(width: 60)
                        .focused($focusedField, equals: .dobDay)
                        .onChange(of: dobDay) { newValue in
                            if let day = Int(newValue), day < 1 { dobDay = "1" }
                            if let day = Int(newValue), day > 31 { dobDay = "31" }
                        }
                        .onSubmit { focusedField = .dobYear }

                    TextField("Year", text: $dobYear)
                        .textFieldStyle(.plain)
                        .frame(width: 100)
                        .focused($focusedField, equals: .dobYear)
                        .onSubmit { validateYear() } // Validate only on submit
                        .onChange(of: dobYear) { newValue in
                            if let year = Int(newValue), year > 3000 {
                                dobYear = "3000" // Immediate correction if absurdly large
                            }
                        }
                        .onSubmit { focusedField = .saveButton }
                }
            }

            HStack {
                Button("Save") {
                    weightData.patient.name = name
                    weightData.patient.heightFeet = heightFeet
                    weightData.patient.heightInches = heightInches
                    weightData.patient.dobDay = dobDay
                    weightData.patient.dobMonth = dobMonth
                    weightData.patient.dobYear = dobYear
                    weightData.objectWillChange.send()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid)
                .focused($focusedField, equals: .saveButton)
                .focusable(true)
                .keyboardShortcut(.defaultAction)
                .onSubmit { dismiss() }

                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            
        }
        .padding()
        .frame(width: 300, height: 250)
        .onAppear {
            focusedField = .name
        }
    }
}
