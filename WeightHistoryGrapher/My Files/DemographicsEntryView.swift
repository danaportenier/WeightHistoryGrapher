import SwiftUI

struct DemographicsEntryView: View {
    @ObservedObject var weightData: WeightData
    @Binding var name: String
    @Binding var heightFeet: String
    @Binding var heightInches: String
    @Binding var dateOfBirth: Date?
    @Environment(\.dismiss) var dismiss

    @FocusState private var focusedField: Field?

    enum Field {
        case name, heightFeet, heightInches, saveButton
    }

    var isValid: Bool {
        guard let feet = Int(heightFeet), (3...8).contains(feet),
              let inches = Int(heightInches), (0...12).contains(inches),
              dateOfBirth != nil else {
            return false
        }
        return true
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
                        .onSubmit { focusedField = .saveButton }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Date of Birth")
                    .bold()
                DatePicker("Date of Birth", selection: Binding(
                    get: { dateOfBirth ?? Date() },
                    set: { dateOfBirth = $0 }
                ), displayedComponents: .date)
                .datePickerStyle(.compact)
            }

            HStack {
                Button("Save") {
                    weightData.patient.name = name
                    weightData.patient.heightFeet = heightFeet
                    weightData.patient.heightInches = heightInches
                    weightData.patient.dateOfBirth = dateOfBirth
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
