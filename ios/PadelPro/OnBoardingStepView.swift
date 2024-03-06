//
//  OnBoardingStepView.swift
//  PadelPro
//
//  Created by Joao Zao on 09/02/2024.
//

import SwiftUI

struct OnBoardingStepView: View {
    var data: OnboardingDataModel
    @Binding var animateSymbol: Bool
    
    var body: some View {
        VStack {
            Image(systemName: data.image)
                .resizable()
                .frame(maxHeight: 260)
                .scaledToFit()
                .symbolRenderingMode(.palette)
                .foregroundStyle(.brown, .yellow)
                .symbolEffect(.bounce, value: animateSymbol)
                .padding()
                .padding(.bottom, 50)
                .onAppear { animateSymbol.toggle() }
            
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
        OnBoardingStepView(
            data: data,
            animateSymbol: .constant(true)
        )
    }
}
