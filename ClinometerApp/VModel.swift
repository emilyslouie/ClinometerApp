//
//  Vswift
//  ClinometerApp
//
//  Created by Emily Louie on 2023-03-04.
//

import Foundation
import CoreMotion
import CoreLocation
import HealthKit

class ClinometerModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    let motionManager = CMMotionManager()
    let pedometer = CMPedometer()
    
    @Published var stepCount: Double = 0
    @Published var distanceWalked: Double = 0
    @Published var errorMessage = "No error"
    
    // MARK: CoreMotion Pedometer -
    
    func startPedometer() {
        if CMPedometer.isDistanceAvailable() {
            pedometer.startUpdates(from: Date(), withHandler: { (pedometerData, error) in
                
                if let data = pedometerData,
                   let pedometerDistance = data.distance {
                    self.distanceWalked = pedometerDistance.doubleValue
                    self.stepCount = data.numberOfSteps.doubleValue
                } else {
                    self.errorMessage = "error with pedometer data and distance"
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
    
    func startDeviceMotion() {
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
    
    func stopDeviceMotion() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion?) {
        guard let deviceMotion = deviceMotion else {
            return
        }
        
        let attitude = deviceMotion.attitude
        let pitch = degrees(radians: attitude.pitch)
        print(Double(round(1000 * pitch)/1000))
    }
    
    // MARK: Helpers
    
    func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }
}



