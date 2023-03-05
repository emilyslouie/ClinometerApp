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
    let locationManager = CLLocationManager()
    let pedometer = CMPedometer()
    
    var locations = [CLLocation]()
    var timer: Timer?
    @Published var distance = CLLocationDistance()
    @Published var testval = 0
    @Published var stepCount: Double = 0
    @Published var errorMessage = "No error"
    @Published var distanceWalked: Double = 0
    
    // MARK: CoreMotion Pedometer -
    
    func startPedometer() {
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
    
    func stopPedometer() {
        pedometer.stopUpdates()
    }
    
    // MARK: Core Location -
    
    func startCoreLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let auth = CLLocationManager.authorizationStatus()
        
        switch auth {
        case .authorizedWhenInUse:
            errorMessage = ("Auth'd when in use")
        default:
            errorMessage = ("Not auth'd")
            // call method on view to prompt them to auth please
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        testval += 1
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.locations.append(location)
            print("appending location")
        } else {
            errorMessage = ("error appending")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = ("Location manager did fail with error")
    }
    
    func stopCoreLocation() {
        locationManager.stopUpdatingLocation()
        if !locations.isEmpty,
           let first = locations.first,
           let last = locations.last {
            print("Count of locations is \(locations.count)")
            print("First: \(first.coordinate.longitude), \(first.coordinate.latitude)")
            print("Last: \(last.coordinate.longitude), \(last.coordinate.latitude)")
            
            let distance = last.distance(from: first)
            let accuracy = first.horizontalAccuracy
            print("Hi! Distance is \(distance) and accuracy is \(accuracy)")
        } else {
            errorMessage = ("No locations in locations array")
        }
        
        
        testval += 1
        
    }
    
    // MARK: HealthKit -
    
    private let healthStore = HKHealthStore()
    
    /// This function provides to authorize the _HealthKit_.
    func authorizeHealthKit() {
        let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)! ] // We want to access the step count.
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (success, error) in  // We will check the authorization.
            if success {} // Authorization is successful.
        }
    }
    
    /// This function provides to get the step count of the users.
    /// - Parameter completion: This parameter contains the step count of the users.
    func gettingStepCount(completion: @escaping (Double) -> Void) {
        guard let type = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            fatalError("Something went wrong retrieving quantity type distanceWalkingRunning")
        }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        var interval = DateComponents()
        interval.day = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .minute, value: -5, to: now as Date), end: now, options: .strictEndDate)
        
        let queryStepCount = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startOfDay, intervalComponents: interval)
        
        queryStepCount.initialResultsHandler = { _, result, error in
            var sumStepCount = 0.0
            result?.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
                if let sumQuantity = statistics.sumQuantity() {
                    sumStepCount = sumQuantity.doubleValue(for: HKUnit.count()) // Get the step count as Double.
                    print("Step count in sumQuantity is \(String(sumStepCount))")
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Couldn't get sumQuantity, with code \(String(describing: error))"
                    }
                }
                
                
                DispatchQueue.main.async {
                    completion(sumStepCount) // Return the step count.
                }
            }
        }
        
        healthStore.execute(queryStepCount)
    }
    
//    let now =  Date()
//    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
//    let startDate = cal.date(byAdding: .second, value: -30, to: now)
//
//    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
    //            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: [.cumulativeSum]) { (query, statistics, error) in
    //                var value: Double = 0
    //
    //                if error != nil {
    //                    print("something went wrong, with code \(String(describing: error))")
    //                } else if let quantity = statistics?.sumQuantity() {
    //                    value = quantity.doubleValue(for: HKUnit.inch())
    //                }
    //                DispatchQueue.main.async {
    //                    completion(value)
    //                    self.errorMessage = "Query completed"
    //                }
    //            }
    //            healthStore.execute(query)
    //        let startOfDay = Calendar.current.startOfDay(for: now)
    //        var interval = DateComponents()
    //        interval.minute = 1
    //
    //
    //        let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: predicate, anchorDate: startDate!, intervalComponents: interval)
    //
    //        query.initialResultsHandler = {
    //            query, results, error in
    //            results?.enumerateStatistics(from: startDate!,
    //                                         to: Date(), with: { (result, stop) in
    //                if let sumQuantity = result.sumQuantity() {
    //                    var sumDistance = sumQuantity.doubleValue(for: HKUnit.inch())
    //                    DispatchQueue.main.async {
    //                        completion(sumDistance) // Return the step count.
    //                    }
    //                } else {
    //                    DispatchQueue.main.async {
    //                        self.errorMessage = "Couldn't get sumQuantity, with code \(String(describing: error))"
    //                    }
    //                }
    //
    
    
    
    //                if let sumQuantity = statistics.sumQuantity() {
    //                    sumDistance = sumQuantity.doubleValue(for: HKUnit.inch()) // Get the step count as Double.
    //                    print("Step count in sumQuantity is \(String(sumDistance))")
    //                } else {
    //                    DispatchQueue.main.async {
    //                        self.errorMessage = "Couldn't get sumQuantity, with code \(String(describing: error))"
    //                    }
    //                }
    //
    //
    //            })
    //        }
    
    //        query.initialResultsHandler = { _, result, error in
    //            var sumDistance = 0.0
    //            result?.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
    //                if let sumQuantity = statistics.sumQuantity() {
    //                    sumDistance = sumQuantity.doubleValue(for: HKUnit.inch()) // Get the step count as Double.
    //                    print("Step count in sumQuantity is \(String(sumDistance))")
    //                } else {
    //                    DispatchQueue.main.async {
    //                        self.errorMessage = "Couldn't get sumQuantity, with code \(String(describing: error))"
    //                    }
    //                }
    //
    //
    //                DispatchQueue.main.async {
    //                    completion(sumDistance) // Return the step count.
    //                }
    //            }
    //        healthStore.execute(query)
    //    }
    //
    //
    //                var value: Double = 0
    //
    //                if error != nil {
    //                    print("something went wrong, with code \(String(describing: error))")
    //                } else if let quantity = statistics?.sumQuantity() {
    //                    value = quantity.doubleValue(for: HKUnit.inch())
    //                }
    //                DispatchQueue.main.async {
    //                    completion(value)
    //                    self.errorMessage = "Query completed"
    //                }
    //            }
    //    healthStore.execute(query)
    
    
    
    // MARK: Device Motion -
    
    func startDeviceMotion() {
        if motionManager.isDeviceMotionAvailable {
            //            manager.startDeviceMotionUpdates()
            //            var data = manager.deviceMotion
            //
            //            if let attitude = data?.attitude {
            //               // Get the pitch (in radians) and convert to degrees.
            //               print(attitude.pitch * 180.0/Double.pi)
            //            } else {
            //               print("fuck")
            //            }
            
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
        
        var attitude = deviceMotion.attitude
        //        var roll = degrees(radians: attitude.roll)
        var pitch = degrees(radians: attitude.pitch)
        print(Double(round(1000 * pitch)/1000))
        //        var yaw = degrees(radians: attitude.yaw)
        //        print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
    }
    
    // MARK: Helpers
    
    func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }
    
    
    
    // MARK: Gyro -
    
    func startGyros() {
        if motionManager.isGyroAvailable {
            self.motionManager.gyroUpdateInterval = 1.0 / 60.0
            self.motionManager.startGyroUpdates()
            
            // Configure a timer to fetch the accelerometer data.
            self.timer = Timer(fire: Date(), interval: (1.0/60.0), repeats: true, block: { (timer) in
                //               Get the gyro data.
                if let data = self.motionManager.gyroData {
                    let x = data.rotationRate.x
                    let y = data.rotationRate.y
                    let z = data.rotationRate.z
                    
                    // Use the gyroscope data in your app.
                    print("Hi! X is \(x), y is \(y), z is \(z)")
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: .default)
        }
    }
    
    func stopGyros() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            
            self.motionManager.stopGyroUpdates()
        }
    }
}



