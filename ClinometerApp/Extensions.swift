//
//  Extensions.swift
//  ClinometerApp
//
//  Created by Matthew Kee on 2023-03-07.
//

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
