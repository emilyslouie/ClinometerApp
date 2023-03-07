//
//  Constants.swift
//  ClinometerApp
//
//  Created by Matthew Kee on 2023-03-07.
//

enum Constants {
    // Calculated by subtracting median eye height from median stature for men and women, then averaging the two differences together
    // Source: https://dacowits.defense.gov/LinkClick.aspx?fileticket=EbsKcm6A10U%3D&portalid=48
    static let averageDifferenceBetweenHeightAndEyeLevel = 11.2

    static let footToMetreConversion = 0.3048
    static let metreToFootConversion = 3.28084

    static let inchToFootConversion = 1/12
}