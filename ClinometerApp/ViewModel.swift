//
//  ViewModel.swift
//  ClinometerApp
//
//  Created by Emily Louie on 2023-03-04.
//

import Foundation
import CoreMotion
import CoreLocation
import HealthKit

enum HeightUnit {
    case cm
    case inch
}

class ClinometerModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    let pedometer = CMPedometer()
    let motionManager = CMMotionManager()
    
    @Published var stepCount: Double = 0
    @Published var distanceWalked: Double = 0
    @Published var finalPitch: Double = 0
    @Published var heightInMetres: Double = 0
    @Published var heightUnits: HeightUnit = .cm
    @Published var treeHeightInMetres: Double = 0
    
    func calculateTreeHeight() {
        let heightOfTreeAboveEye = tan(finalPitch) * distanceWalked
        let heightOfEyeAboveGround = heightInMetres - Constants.averageDifferenceBetweenHeightAndEyeLevel
        treeHeightInMetres = heightOfTreeAboveEye + heightOfEyeAboveGround

        // print("Final pitch is \(finalPitch) and tan is \(tan(finalPitch)), height of tree is \(heightOfTreeAboveEye)")
        // print("heightOfEyeAboveGround \(heightOfEyeAboveGround), tree height before rounding is \(treeHeightInMetres)")
    }

    func resetMeasurements() {
        stepCount = 0
        distanceWalked = 0
        finalPitch = 0
        treeHeightInMetres = 0
    }
    
    // MARK: CoreMotion Pedometer -
    
    func isPedometerAuthorized() -> Bool {
        return CMPedometer.authorizationStatus() == .authorized
    }
    
    func startPedometer() {
        if CMPedometer.isDistanceAvailable() {
            pedometer.startUpdates(from: Date(), withHandler: { (pedometerData, error) in
                if let data = pedometerData,
                   let pedometerDistance = data.distance {
                    self.distanceWalked = pedometerDistance.doubleValue
                    self.stepCount = data.numberOfSteps.doubleValue
                } else {
                    // handle the error
                }
                
            })
        }
    }
    
    func stopPedometer() {
        pedometer.stopUpdates()
    }
    
    // MARK: Device Motion -
    
    func startAngleMeasurement() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(
                to: OperationQueue.current!, withHandler: {
                    (deviceMotion, error) -> Void in
                    if(error == nil) {
                        self.handleDeviceMotionUpdate(deviceMotion: deviceMotion)
                    } else {
                        //handle the error
                    }
                })
        }
    }
    
    func stopAngleMeasurement() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion?) {
        guard let deviceMotion = deviceMotion else {
            return
        }
        
        let attitude = deviceMotion.attitude
        let pitch = attitude.pitch
        let convertedPitch = (1/2) * Double.pi - pitch
        finalPitch = convertedPitch
        
        // print("pitch: \(pitch), converted pitch: \(convertedPitch)")
    }
}

