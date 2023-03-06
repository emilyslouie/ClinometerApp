//
//  ContentView.swift
//  ClinometerApp
//
//  Created by Emily Louie on 2023-03-04.
//

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
    @State private var showAuthView = false
    @State private var step: Step = .landingPage // TODO: CHANGE THIS BACK
    @State private var metresFeetString: String = ""
    @State private var inchesString: String = ""
    @State var showHeightPrompt = false
    
    
    func text() -> String {
        switch step {
        case .landingPage:
            return "Measure a tree!"
        case .startAtTree:
            return "Stand at the base of the tree you want to measure.\n\nWhen you are ready, press the button below!"
        case .measureDistance:
            return "Walk in a straight line away from the tree until you can see the top of the tree.\n\nWhen you are done, wait 10 seconds for the step count to update, then press the button below!"
        case .measureAngle:
            return "Put your eye to the eyepiece. Tilt your phone as you tilt your neck to see the top of the tree.\n\nPress the button when you see it!"
        case .inputHeight:
            return "Input your height into the field below:"
        case .results:
            let roundedHeight = model.treeHeightInMetres.truncate(places: 3)
            return "Your tree is \(roundedHeight) metres tall!"
        }
    }
    
    func buttonTitle() -> String {
        switch step {
        case .landingPage:
            return "Start"
        case .startAtTree:
            return "Ready!"
        case .measureDistance:
            return "Done!"
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
            model.startPedometer()
            
            if model.isPedometerAuthorized() {
                step = .measureDistance
            } else {
                showAuthView = true
            }
        case .measureDistance:
            model.stopPedometer()
            model.startAngleMeasurement()
            step = .measureAngle
        case .measureAngle:
            model.stopAngleMeasurement()
            step = .inputHeight
        case .inputHeight:
            
            switch model.heightUnits {
            case .cm:
                if let height = Double(metresFeetString) {
                    model.heightInMetres = height
                    showHeightPrompt = false
                    step = .results
                } else {
                    showHeightPrompt = true
                }
            case .inch:
                if let feet = Double(metresFeetString),
                   let inches = Double(inchesString) {
                    model.heightInMetres = (feet + inches * 1/12) * 0.305
                    showHeightPrompt = false
                    step = .results
                } else {
                    showHeightPrompt = true
                }
            }
            model.calculateTreeHeight()
        case .results:
            step = .startAtTree
            model.treeHeightInMetres = 0
        }
    }
    
    var body: some View {
        
        VStack(alignment: .center) {
            Spacer()
            
            Text(text())
                .font(.title2)
                .padding(.bottom, 48)
            
            
            if step == .measureDistance {
                Text("Step count: \(model.stepCount)\nDistance walked: \(model.distanceWalked)")
                    .font(.title2)
            } else if step == .measureAngle {
                Text("Angle in radians: \(model.finalPitch)")
                    .font(.title2)
                
            } else if step == .inputHeight {
                
                HStack() {
                    TextField(model.heightUnits == .cm ? "Meters" : "Feet", text: $metresFeetString)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                    if model.heightUnits == .inch {
                        TextField("Inches", text: $inchesString)
                            .textFieldStyle(.roundedBorder)
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
                    .padding(.vertical, 24)
            })
            .buttonStyle(.borderedProminent)
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .padding(.bottom, 32)
        .fullScreenCover(isPresented: $showAuthView) {
            AuthView()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: ClinometerModel())
    }
}
