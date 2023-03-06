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

enum heightUnit {
    case cm
    case inch
}

class ClinometerModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    let pedometer = CMPedometer()
    let motionManager = CMMotionManager()
    
    @Published var stepCount: Double = 0
    @Published var distanceWalked: Double = 0
    @Published var finalPitch: Double = 0
    @Published var heightInMetres: Double = 0
    @Published var heightUnits: heightUnit = .cm
    @Published var treeHeightInMetres: Double = 0
    
    @Published var errorMessage = "No error"
    
    func calculateTreeHeight() {
        let heightOfTreeAboveEye = tan(finalPitch) * distanceWalked
        print("Final pitch is \(finalPitch) and tan is \(tan(finalPitch)), height of tree is \(heightOfTreeAboveEye)")
        
        // 2.8 inch on average
        let foreheadHeight = 0.0711
        let heightOfEyeAboveGround = heightInMetres - foreheadHeight
        treeHeightInMetres = heightOfTreeAboveEye + heightOfEyeAboveGround
        
        print("heightOfEyeAboveGround \(heightOfEyeAboveGround), tree height before rounding is \(treeHeightInMetres)")
        
        // reset everything
        
        stepCount = 0
        distanceWalked = 0
        finalPitch = 0
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
                    DispatchQueue.main.async {
                        self.errorMessage = "error with pedometer data and distance"
                    }
                    
                    
                }
                
            })
        }
        
        if CMPedometer.authorizationStatus() != .authorized {
            
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
        
        print("pitch: \(pitch), converted pitch: \(convertedPitch)")
    }
    
    // MARK: Helpers
    
    func degrees(radians:Double) -> Double {
        return (180 / Double.pi) * radians
    }
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
