//
//  ContentView.swift
//  ClinometerApp
//
//  Created by Emily Louie on 2023-03-04.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject var model: ClinometerModel
    
    var body: some View {
        VStack {
            Button(action: {
                model.startDeviceMotion()
            }, label: {
                Text("Start collecting angle")
            })
            
            Button(action: {
                model.stopDeviceMotion()
            }, label: {
                Text("Stop collecting angle")
            })
            
            Button(action: {
                model.startCoreLocation()
            }, label: {
                Text("Start collecting location")
            })
            
            Button(action: {
                model.stopCoreLocation()
            }, label: {
                Text("Stop collecting location")
            })
            
            Text("Distance is: " + String(model.distance))
            Text("Test val is: " + String(model.testval))
            
            Button(action: {
                model.authorizeHealthKit()
            }, label: {
                Text("Authorize health kit")
            })
            
            Button(action: {
                model.gettingStepCount() { myStepCount in
                    model.stepCount = myStepCount
                }
            }, label: {
                Text("Get distance for last min")
            })
            
            Text("Step count is: \(String(model.stepCount))")
        }
        .padding()
        
        VStack() {
            Button(action: {
                model.startPedometer()
            }, label: {
                Text("Start pedometer")
            })

            Button(action: {
                model.stopPedometer()
            }, label: {
                Text("Stop pedometer")
            })
            
            Text("Distance from pedometer: \(String(model.distanceWalked))")

            Text("Error: \(model.errorMessage)")
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: ClinometerModel())
    }
}
