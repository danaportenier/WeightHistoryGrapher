//
//  Untitled.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 3/9/25.
//
import SwiftUI
import AppKit

struct YearTextField: NSViewRepresentable {
    @Binding var selectedYear: Int

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: YearTextField

        init(parent: YearTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField,
               let year = Int(textField.stringValue), (1915...3000).contains(year) {
                parent.selectedYear = year
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(string: "\(selectedYear)")
        textField.delegate = context.coordinator
        textField.alignment = .center
        textField.font = NSFont.systemFont(ofSize: 14)
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = "\(selectedYear)"
    }
}

struct YearPickerView: View {
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        YearTextField(selectedYear: $selectedYear)
            .frame(width: 80)
            .padding()
    }
}
