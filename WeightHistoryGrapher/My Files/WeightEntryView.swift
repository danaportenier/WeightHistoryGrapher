import Foundation
import SwiftUI

struct WeightEntryView: View {
    
    @ObservedObject var weightData: WeightData
    @Binding var patient: Patient
    @State private var label: String = ""
    @State private var weightText: String = "" // Holds raw input as String
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedCategory: LifeEventCategory = .pickOne
    @State private var showDemographicsWindow = false
    @State private var demographicsUpdated = false

    // Focus
    @FocusState private var focusedField: Field?
    
    enum Field {
        case demographics, category, label, weight, date, addButton
    }
    
    /// ✅ Computed property to check if entry is valid
    var isValid: Bool {
        guard let weight = Double(weightText),
              selectedCategory != .pickOne
        else { return false }
        return (90...1500).contains(weight)
    }
    
    // Add this computed property to simplify demographic checks
    private var isDemographicsEmpty: Bool {
        let isEmpty = patient.heightFeet.isEmpty ||
                      patient.heightInches.isEmpty ||
                      patient.dateOfBirth == nil
        
        print("Height Feet Empty: \(patient.heightFeet.isEmpty)")
        print("Height Inches Empty: \(patient.heightInches.isEmpty)")
        print("Date of Birth Nil: \(patient.dateOfBirth == nil)")
        print("isDemographicsEmpty: \(isEmpty)")
        
        return isEmpty
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
                                    .foregroundColor(isDemographicsEmpty ? .red : .black)
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
                            .padding(isDemographicsEmpty ? 20 : 10)
                            .buttonStyle(.borderedProminent)
                            .controlSize(isDemographicsEmpty ? .large : .regular)
                            .tint(isDemographicsEmpty ? .red : .blue)
                            
                        }
                        .padding(10)
                        .overlay(isDemographicsEmpty ? Rectangle().stroke(Color.gray, lineWidth: 1) : nil)
                    }
                    if !isDemographicsEmpty {
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
                                .foregroundColor(isDemographicsEmpty ? .black : .red)
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
                            Text("Select a Year:")
                                .frame(width: 120, alignment: .leading)
                            YearTextField(selectedYear: $selectedYear)
                                .frame(width: 80)
                            .focused($focusedField, equals: .date)
                            .submitLabel(.next)
                            .onSubmit { validateDate() } // ✅ Validate when leaving field
                        }
                        // FIXME: working on focus to include drop down menu
                        HStack {
                            Button("Add") {
                                guard let weight = Double(weightText) else { return }
                                let calendar = Calendar.current
                                let selectedDate = calendar.date(from: DateComponents(year: selectedYear)) ?? Date()
                                weightData.addWeightEntry(date: selectedDate, weight: weight, label: label, category: selectedCategory)
                                resetFields()
                                DispatchQueue.main.async {
                                    focusedField = .category
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!isValid) // ✅ Disable button if invalid input
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
                    .overlay(!isDemographicsEmpty ? Rectangle().stroke(Color.gray, lineWidth: 1) : nil)
                }
                
            }
        }
        .sheet(isPresented: $showDemographicsWindow, onDismiss: {
            demographicsUpdated.toggle()
        }) {
            DemographicsEntryView(
                weightData: weightData,
                name: $patient.name,
                heightFeet: $patient.heightFeet,
                heightInches: $patient.heightInches,
                dateOfBirth: $patient.dateOfBirth
            )
        }
        .onChange(of: demographicsUpdated) { _ in
            DispatchQueue.main.async {
                if patient.heightFeet.isEmpty || patient.heightInches.isEmpty || patient.dateOfBirth == nil {
                    focusedField = .demographics
                } else {
                    focusedField = .category
                }
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.async {
                if patient.heightFeet.isEmpty || patient.heightInches.isEmpty || patient.dateOfBirth == nil {
                    if focusedField != .addButton {
                        focusedField = .demographics
                    }
                } else {
                    focusedField = .category
                }
            }
            weightText = "0"
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
    
    private func validateDate() {
        let minYear = 1915
        let maxYear = 3000
        
        if selectedYear < minYear {
            selectedYear = minYear
        } else if selectedYear > maxYear {
            selectedYear = maxYear
        }
    }
    
    /// ✅ Resets fields after adding an entry
    private func resetFields() {
        label = ""
        weightText = "0"
        selectedYear = Calendar.current.component(.year, from: Date()) // Reset to current year
        selectedCategory = .pickOne
    }
}

#Preview {
    WeightEntryView(weightData: WeightData(), patient: .constant(Patient()))
}
