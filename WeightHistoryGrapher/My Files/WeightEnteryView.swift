//
//  WeightEnteryView.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//

import SwiftUI

struct WeightEnteryView: View {
    
    @ObservedObject var weightData: WeightData
    @State private var label: String = ""
    @State private var weight: Double = 0
    @State private var date: Int = 2025
    
    @State private var name: String = ""
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    @State private var dobDay: String = ""
    @State private var dobMonth: String = ""
    @State private var dobYear: String = ""
    
    @State private var showDemographicsWindow = false

    
    //Focus
    @FocusState private var focusedField: Field?
    
    enum Field {
        case label, weight, date, addButton
    }
    var body: some View {
        
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Time Point:")
                        .frame(width: 120, alignment: .leading) // Set a fixed width for labels
                    TextField("Enter Significant Weight Time Point", text: $label)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .label) // Track focus
                        .submitLabel(.next)
                        .onSubmit { focusedField = .weight }
                }
                
                HStack {
                Text("Weight (lbs):")
                    .frame(width: 120, alignment: .leading)
                TextField("Enter Weight in Pounds", value: $weight, formatter: integerFormatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150) // Consistent field width
                    .focused($focusedField, equals: .weight)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .date }
            }
            
            HStack {
                Text("Year:")
                    .frame(width: 120, alignment: .leading)
                TextField("Enter Year", value: $date, formatter: integerFormatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                    .focused($focusedField, equals: .date)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .addButton }
            }
            HStack {
                Button("Add") {
                    weightData.addWeightEntry(date: date, weight: weight, label: label)
                    date = 2025
                    weight = 0
                    label = ""
                }
                    .buttonStyle(.borderedProminent)
                    .focused($focusedField, equals: .addButton) // Make button focusable
                    .focusable(true)
                    .keyboardShortcut(.defaultAction)
                    
                    .padding(.top)
                    .padding(.horizontal)
                Button("Reset All") {
                    weightData.resetAll()
                }
                    .padding(.top)
                    .padding(.horizontal)
                    .buttonStyle(.borderedProminent)
                Button("Demographics") {
                    showDemographicsWindow = true
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
                weightData: weightData, // Pass the required argument
                name: $name,
                heightFeet: $heightFeet,
                heightInches: $heightInches,
                dobDay: $dobDay,
                dobMonth: $dobMonth,
                dobYear: $dobYear
            )
        }
        .padding()
            
        
    
            
        
        
    }
    
    
    
   
    
        
    
    private var integerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        return formatter
    }
}

#Preview {
    WeightEnteryView(weightData: WeightData())
}
