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
        Text("Uh oh! Please allow us to use Motion Services so we can determine the distance you walk away from the tree!")
            .font(.title)
            .padding(.horizontal, 16)
        
        Button(action: {
            Task {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    await UIApplication.shared.open(url)
                }
            }
        }, label: {
            Text("Take me to Settings!")
        })
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
