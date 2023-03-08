//
//  ContentView.swift
//  ClinometerApp
//
//  Created by Emily Louie on 2023-03-04.
//

/*
TODOs:
Add instruction which slider to change in Settings, then to return to the app (done)

Add instruction about walking a minimum amount (done)

Add instruction about holding as close as possible to eye (done)
Add instruction about starting looking straight ahead (done)
Update description of eyepiece as it goes out of view of the eyepiece (done)

Make sure we clear steps in between measurements (done)

Print out in feet on results page (done)
Print out final values on results page (done)
*/

import SwiftUI
import CoreMotion

enum Step {
    case landingPage
    case startAtTree
    case measureDistance
    case measureAngle
    case inputHeight
    case results
}

struct ContentView: View {
    @ObservedObject var model: ClinometerModel
    
    @State private var step: Step = .landingPage // can change this to different pages for testing

    @State private var metresOrFeetString: String = ""
    @State private var inchesString: String = ""

    @State private var showAuthView = false
    @State private var showHeightPrompt = false
    @State private var showProgressView = false
    
    func text() -> String {
        switch step {
        case .landingPage:
            return "Measure a tree!"
        case .startAtTree:
            return "Stand at the base of the tree you want to measure.\n\nWhen you are ready, press the button below!"
        case .measureDistance:
            return "Walk 10 steps in a straight line away from the tree. Ensure that when you turn around, you can see the top of the tree, otherwise, keep walking.\n\nWhen you are done walking, press the button below!"
        case .measureAngle:
            return "Look straight in front of you, and bring the eyepiece very close to your eye so you can see through it.\n\nTilt your phone as you tilt your neck back until the top of the tree is at the bottom of the eyepiece, then press the button below!"
        case .inputHeight:
            return "Input your height into the field below:"
        case .results:
            let treeHeightInFeetRounded = (model.treeHeightInMetres * Constants.metreToFootConversion).truncate(places: 4)
            let treeHeightInMetresRounded = model.treeHeightInMetres.truncate(places: 4)
            
            return "Your tree is \(treeHeightInMetresRounded) metres or \(treeHeightInFeetRounded) feet tall!"
            // \n\nYou walked \(model.distanceWalked) metres and measured an angle of \(model.finalPitch) radians above eye-level!\nWe estimated your eye-level based on your height, by subtracting the median distance from top of head to eyes (Gordon, Claire C. et. al (2014)).
        }
    }
    
    func buttonTitle() -> String {
        switch step {
        case .landingPage:
            return "Start!"
        case .startAtTree:
            return "Ready!"
        case .measureDistance:
            return "I have finished walking!"
        case .measureAngle:
            return "I see it!"
        case .inputHeight:
            return "Done!"
        case .results:
            return "Measure another tree!"
        }
    }
    
    func buttonAction() {
        switch step {
        case .landingPage:
            step = .startAtTree
        case .startAtTree:
            model.resetMeasurements()
            model.startPedometer()
            if model.isPedometerAuthorized() {
                step = .measureDistance
            } else {
                showAuthView = true
            }
        case .measureDistance:
            showProgressView = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                showProgressView = false
                model.stopPedometer()
                model.startAngleMeasurement()
                step = .measureAngle
            }
            
        case .measureAngle:
            model.stopAngleMeasurement()
            step = .inputHeight
        case .inputHeight:
            switch model.heightUnits {
            case .cm:
                if let height = Double(metresOrFeetString) {
                    model.heightInMetres = height
                    showHeightPrompt = false
                    step = .results
                } else {
                    showHeightPrompt = true
                }
            case .inch:
                if let feet = Double(metresOrFeetString),
                   let inches = Double(inchesString) {
                    model.heightInMetres = (feet + inches * Constants.inchToFootConversion) * Constants.footToMetreConversion
                    showHeightPrompt = false
                    model.calculateTreeHeight()
                    step = .results
                } else {
                    showHeightPrompt = true
                }
            }
        case .results:
            step = .startAtTree
        }
    }
    
    var body: some View {
        ZStack() {
            VStack(alignment: .center) {
                Spacer()
                
                Text(text())
                    .font(.title2)
                    .padding(.bottom, 48)
                
                // if step == .measureDistance {
                //     Text("Step count: \(model.stepCount)\nDistance walked: \(model.distanceWalked)")
                //         .font(.title2)
                // } else if step == .measureAngle {
                //     Text("Angle in radians: \(model.finalPitch)")
                //         .font(.title2)
                // } else 
                if step == .inputHeight {
                    HStack() {
                        TextField(model.heightUnits == .cm ? "Meters" : "Feet", text: $metresOrFeetString)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        if model.heightUnits == .inch {
                            TextField("Inches", text: $inchesString)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    HStack(alignment: .center) {
                        Button(action: {
                            model.heightUnits = .cm
                        }, label: {
                            Text("Meters (m)")
                        })
                        .padding()
                        .background(model.heightUnits == .cm ? Color.blue : Color.clear)
                        .foregroundColor(model.heightUnits == .cm ? Color.white : Color(UIColor.label))
                        .border(model.heightUnits == .cm ? Color.clear : Color(UIColor.label))
                        
                        Button(action: {
                            model.heightUnits = .inch
                        }, label: {
                            Text("Feet (ft)")
                        })
                        .padding()
                        .background(model.heightUnits == .inch ? Color.blue : Color.clear)
                        .foregroundColor(model.heightUnits == .inch ? Color.white : Color(UIColor.label))
                        .border(model.heightUnits == .inch ? Color.clear : Color(UIColor.label))
                    }
                    
                    if showHeightPrompt {
                        Text("Please input a valid number for height!")
                            .foregroundColor(.red)
                            .bold()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    buttonAction()
                }, label: {
                    Text(buttonTitle())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, step == .measureAngle ? 48 : 24)
                })
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, 32)
            .fullScreenCover(isPresented: $showAuthView, onDismiss: { step = .startAtTree }) {
                AuthView()
            }

            if showProgressView {
                ProgressView("Determining distance walked...")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: ClinometerModel())
    }
}
