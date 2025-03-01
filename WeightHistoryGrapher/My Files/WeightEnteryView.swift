import SwiftUI

struct WeightEnteryView: View {
    
    @ObservedObject var weightData: WeightData
    @Binding var patient: Patient
    @State private var label: String = ""
    @State private var weightText: String = "" // Holds raw input as String
    @State private var dateText: String = ""   // Holds raw input as String
    
    @State private var showDemographicsWindow = false

    // Focus
    @FocusState private var focusedField: Field?
    
    enum Field {
        case label, weight, date, addButton
    }
    
    /// ✅ Computed property to check if entry is valid
    var isValidEntry: Bool {
        if let weight = Double(weightText), let date = Int(dateText) {
            return (90...1500).contains(weight) && (1915...3000).contains(date)
        }
        return false
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    HStack {
                        Text("Step 1.")
                            .bold()
                            .font(.title)
                            .foregroundColor(
                                            (patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                                             patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty) ?
                                             .red : .black
                                        )
                        Text("Enter Demographics")
                            .font(.title2)
                            .underline()
                            .foregroundColor(
                                            (patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                                             patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty) ?
                                             .red : .black
                                        )
                    }
                    
                    Button("Demographics") {
                        showDemographicsWindow = true
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    
                    HStack {
                        Text("Step 2.")
                            .bold()
                            .font(.title)
                            .foregroundColor(
                                            (patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                                             patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty) ?
                                                .black : .red
                                        )
                        Text("Enter Weight History")
                            .font(.title2)
                            .underline()
                            .foregroundColor(
                                            (patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                                             patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty) ?
                                             .black : .red
                                        )
                    }
                }
                
                HStack {
                    
                    
                    Text("Time Point:")
                        .frame(width: 120, alignment: .leading)
                    TextField("Enter Significant Weight Time Point", text: $label)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .label)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .weight }
                }
                
                HStack {
                    Text("Weight (lbs):")
                        .frame(width: 120, alignment: .leading)
                    TextField("Enter Weight in Pounds", text: $weightText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                        .focused($focusedField, equals: .weight)
                        .submitLabel(.next)
                        .onSubmit { validateWeight() } // ✅ Validate when leaving field
                }
                
                HStack {
                    Text("Year:")
                        .frame(width: 120, alignment: .leading)
                    TextField("Enter Year", text: $dateText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                        .focused($focusedField, equals: .date)
                        .submitLabel(.next)
                        .onSubmit { validateDate() } // ✅ Validate when leaving field
                }
                
                HStack {
                    Button("Add") {
                        guard let weight = Double(weightText), let date = Int(dateText) else { return }
                        weightData.addWeightEntry(date: date, weight: weight, label: label)
                        resetFields()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidEntry) // ✅ Disable button if invalid input
                    .focused($focusedField, equals: .addButton)
                    .focusable(true)
                    .keyboardShortcut(.defaultAction)
                    .padding(.top)
                    .padding(.horizontal)
                    
                    Button("Reset All") {
                        weightData.resetAll()
                        patient.resetAll()
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    .buttonStyle(.borderedProminent)
                    
                    
                }
                .padding(.bottom)
                
                DemographicsView(weightData: weightData)
                    .padding()
                    .border(Color.gray.opacity(0.3), width: 2)
            }
        }
        .sheet(isPresented: $showDemographicsWindow) {
            DemographicsEnteryView(
                weightData: weightData,
                name: $patient.name,
                heightFeet: $patient.heightFeet,
                heightInches: $patient.heightInches,
                dobDay: $patient.dobDay,
                dobMonth: $patient.dobMonth,
                dobYear: $patient.dobYear
            )
        }
        .padding()
        .onAppear {
            // ✅ Populate text fields with default values
            weightText = "0"
            dateText = "2025"
        }
    }
    
    /// ✅ Validates weight when the user finishes typing
    private func validateWeight() {
        if let weight = Double(weightText) {
            if weight < 90 {
                weightText = "90"
            } else if weight > 1500 {
                weightText = "1500"
            }
        } else {
            weightText = "90" // Default to valid value if input is non-numeric
        }
    }
    
    /// ✅ Validates date when the user finishes typing
    private func validateDate() {
        if let date = Int(dateText) {
            if date < 1915 {
                dateText = "1915"
            } else if date > 3000 {
                dateText = "3000"
            }
        } else {
            dateText = "2025" // Default to valid value if input is non-numeric
        }
    }
    
    /// ✅ Resets fields after adding an entry
    private func resetFields() {
        label = ""
        weightText = "0"
        dateText = "2025"
    }
}

#Preview {
    WeightEnteryView(weightData: WeightData(), patient: .constant(Patient()))
}
