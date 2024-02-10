//
//  OnBoardingStepView.swift
//  PadelPro
//
//  Created by Joao Zao on 09/02/2024.
//

import SwiftUI

struct OnBoardingStepView: View {
    var data: OnboardingDataModel
    
    var body: some View {
        VStack {
            Image(data.image)
                .resizable()
                .scaledToFit()
                .padding(.bottom, 50)
            
            Text(data.heading)
                .font(.system(size: 25, design: .rounded))
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            Text(data.text)
                .font(.system(size: 17, design: .rounded))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct OnBoardingStepView_Previews: PreviewProvider {
    static var data = OnboardingDataModel.data[0]
    static var previews: some View {
        OnBoardingStepView(data: data)
    }
}
