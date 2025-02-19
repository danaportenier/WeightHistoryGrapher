import SwiftUI

struct DemographicsEnteryView: View {
    @ObservedObject var weightData: WeightData
    @Binding var name: String
    @Binding var heightFeet: String
    @Binding var heightInches: String
    @Binding var dobDay: String
    @Binding var dobMonth: String
    @Binding var dobYear: String
    @Environment(\.dismiss) var dismiss

    // Define focus states
    @FocusState private var focusedField: Field?

    enum Field {
        case name, heightFeet, heightInches, dobDay, dobMonth, dobYear, saveButton
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Enter Demographics")
                .font(.headline)
                .padding(.bottom)

            Text("Patient Name")
                .bold()
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .heightFeet }

            VStack(alignment: .leading, spacing: 10) {
                Text("Height")
                    .bold()
                HStack {
                    TextField("Feet", text: $heightFeet)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .focused($focusedField, equals: .heightFeet)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .heightInches }

                    TextField("Inches", text: $heightInches)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .focused($focusedField, equals: .heightInches)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .dobDay }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Date of Birth")
                    .bold()
                HStack {
                    TextField("Month", text: $dobMonth)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .focused($focusedField, equals: .dobMonth)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .dobYear }
                    
                    TextField("Day", text: $dobDay)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .focused($focusedField, equals: .dobDay)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .dobMonth }

                    TextField("Year", text: $dobYear)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .focused($focusedField, equals: .dobYear)
                        .submitLabel(.next)
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
                .focused($focusedField, equals: .saveButton) // Ensure focus moves to this button
                .focusable(true) // Make sure macOS allows the button to receive keyboard focus
                .keyboardShortcut(.defaultAction) // Allows pressing Return to trigger Save
                .onSubmit { dismiss() } // Ensures pressing Return also dismisses the window

                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            
        }
        .padding()
        .frame(width: 300, height: 250)
        .onAppear {
            focusedField = .name // Start focus at the Name field
        }
    }
}
