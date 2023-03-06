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
    @State private var step: Step = .landingPage
    @State private var metresFeetString: String = ""
    @State private var inchesString: String = ""
    @State var showHeightPrompt = false
    
    
    func text() -> String {
        switch step {
        case .landingPage:
            return "Measure a tree!"
        case .startAtTree:
            return "Stand at the base of the tree you want to measure. \n When you are ready, press the button below!"
        case .measureDistance:
            return "Walk in a straight line away from the tree until you can see the top of the tree. \n When you are done, press the button below!"
        case .measureAngle:
            return "Put your eye to the eyepiece. Tilt your phone as you tilt your neck to see the top of the tree. \n Press the button when you see it!"
        case .inputHeight:
            return "Input your height into the field below:"
        case .results:
            return "Your tree is ___!"
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
                    model.heightDouble = height
                    showHeightPrompt = false
                    step = .results
                } else {
                    showHeightPrompt = true
                }
            case .inch:
                if let feet = Double(metresFeetString),
                   let inches = Double(inchesString) {
                    model.heightDouble = feet + inches * 1/12
                    showHeightPrompt = false
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
        
        VStack(alignment: .center) {
            Text(text())
            
            if step == .inputHeight {
                TextField(model.heightUnits == .cm ? "Meters" : "Feet", text: $metresFeetString)
                    .padding()
                if model.heightUnits == .inch {
                    TextField("Inches", text: $inchesString)
                }
                
                HStack(alignment: .center) {
                    Button(action: {
                        model.heightUnits = .cm
                    }, label: {
                        Text("Centimeters (cm)")
                    })
                    Button(action: {
                        model.heightUnits = .inch
                    }, label: {
                        Text("Inches (inch)")
                    })
                }
                
                if showHeightPrompt {
                    Text("Please input a valid number for height!")
                        .foregroundColor(.red)
                        .bold()
                }
                    
            }
            
            Button(action: {
                buttonAction()
            }, label: {
                Text(buttonTitle())
            })
        }
        .padding(.horizontal, 16)
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
