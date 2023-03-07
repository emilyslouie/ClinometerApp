//
//  AuthView.swift
//  ClinometerApp
//
//  Created by Emily Louie on 2023-03-05.
//

import SwiftUI

struct AuthView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Text("Uh oh!")
                .font(.title)
                .bold()
                .padding(.bottom, 16)
            
            Text("Please allow us to use Motion & Fitness so we can determine the distance that you walk away from the tree!\n\nTap the button below, then toggle Motion & Fitness, then return to this app!")
                .font(.title)
                .padding(.horizontal, 16)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                Task {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        await UIApplication.shared.open(url)
                    }
                }
            }, label: {
                Text("Take me to Settings!")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            })
            .padding(.bottom, 32)
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
