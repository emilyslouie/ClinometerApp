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
        }
        .padding()
        
        VStack() {
            // This app uses your device motion to determine distance walked away from the base of the tree.
            
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
        .padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: ClinometerModel())
    }
}
