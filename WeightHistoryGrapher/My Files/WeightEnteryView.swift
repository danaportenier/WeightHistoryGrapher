import SwiftUI

struct WeightEnteryView: View {
    
    @ObservedObject var weightData: WeightData
    @Binding var patient: Patient
    @State private var label: String = ""
    @State private var weightText: String = "" // Holds raw input as String
    @State private var dateText: String = ""   // Holds raw input as String
    @State private var selectedCategory: LifeEventCategory = .pickOne
    @State private var showDemographicsWindow = false

    // Focus
    @FocusState private var focusedField: Field?
    
    enum Field {
        case demographics, category, label, weight, date, addButton
    }
    
    /// ✅ Computed property to check if entry is valid
    var isValidEntry: Bool {
        if let weight = Double(weightText), let date = Int(dateText) {
            return (90...1500).contains(weight) && (1915...3000).contains(date) && selectedCategory != .pickOne
        }
        return false
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    HStack {
                        VStack {
                            HStack(alignment: .bottom) {
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
                                
                                Text("Command + D (⌘ D)")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.gray.opacity(0.8))
                                
                            }
                            
                                Button("Demographics") {
                                    showDemographicsWindow = true
                                }
                                .focused($focusedField, equals: .demographics)
                                .focusable(true)
                                .padding(
                                    (patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                                     patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty) ? 20 : 10
                                )
                                .buttonStyle(.borderedProminent)
                                .controlSize(
                                    (patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                                     patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty) ? .large : .regular
                                )
                                .tint(
                                    (patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                                     patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty) ? .red : .blue
                                )
                                
                            
                        }
                        .padding(10)
                        .overlay((patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                                  patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty) ? Rectangle().stroke(Color.gray, lineWidth: 1) : nil)
                    }
                    if (!patient.heightFeet.isEmpty && !patient.heightInches.isEmpty &&
                        !patient.dobMonth.isEmpty && !patient.dobDay.isEmpty && !patient.dobYear.isEmpty) {
                        DemographicsView(weightData: weightData)
                            .padding(5)
                            .border(Color.gray.opacity(0.3), width: 2)
                    } else {
                        EmptyView()
                    }
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom) {
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
                            
                            Text("Reset All: Shift + Command + R (⇧⌘ R)")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.6))
                            
                        }
                        
                        HStack {
                            Text("Life Event:")
                                .frame(width: 120, alignment: .leading)
                            Picker("", selection: $selectedCategory) {
                                ForEach(LifeEventCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
//                            .pickerStyle(PopUpButtonPickerStyle())
                            .focusable(true)
                            .focused($focusedField, equals: .category) // ✅ Make Picker focusable
                            .onSubmit { focusedField = .label }
                        }
                        
                        HStack {
                            
                            
                            
                            Text("Description:")
                                .frame(width: 120, alignment: .leading)
                            TextField("Enter Significant Weight Time Point Description", text: $label)
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
                        // FIXME: working on focus to include drop down menu
                        HStack {
                            Button("Add") {
                                guard let weight = Double(weightText), let date = Int(dateText) else { return }
                                weightData.addWeightEntry(date: date, weight: weight, label: label, category: selectedCategory) // ✅ Pass selectedCategory
                                resetFields()
                                DispatchQueue.main.async {
                                    focusedField = .category
                                }
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
                                resetFields()
                                DispatchQueue.main.async {
                                    focusedField = .demographics // Re-focus to dropdown after reset
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            .buttonStyle(.borderedProminent)
                            
                        
                        }
                        .padding(.bottom)
                    }
                    .padding()
                    .overlay((!patient.heightFeet.isEmpty && !patient.heightInches.isEmpty &&
                              !patient.dobMonth.isEmpty && !patient.dobDay.isEmpty && !patient.dobYear.isEmpty) ? Rectangle().stroke(Color.gray, lineWidth: 1) : nil)
                }
                
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
            DispatchQueue.main.async {
                if patient.heightFeet.isEmpty && patient.heightInches.isEmpty &&
                    patient.dobMonth.isEmpty && patient.dobDay.isEmpty && patient.dobYear.isEmpty {
                    if focusedField != .addButton {
                        focusedField = .demographics
                    }
                } else {
                    focusedField = .category
                }
            }
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
        selectedCategory = .pickOne
    }
}

#Preview {
    WeightEnteryView(weightData: WeightData(), patient: .constant(Patient()))
}
