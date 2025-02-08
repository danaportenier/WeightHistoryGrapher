//
//  Untitled.swift
//  WeightHistoryGrapher
//
//  Created by Dana Portenier on 2/7/25.
//
import SwiftUI


struct WeightHistoryModel: Identifiable {
    let id: UUID = UUID()
    var date: Int?
    var weight: Double
    var label: String
}
