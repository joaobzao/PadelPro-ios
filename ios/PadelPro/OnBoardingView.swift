//
//  OnBoardingCoreView.swift
//  PadelPro
//
//  Created by Joao Zao on 09/02/2024.
//

import SwiftUI

struct OnBoardingView: View {
    var data: [OnboardingDataModel]
    var doneFunction: () -> ()
    @State var animateSymbol: Bool = true
    
    @State var slideGesture: CGSize = CGSize.zero
    @State var curSlideIndex = 0
    var distance: CGFloat = UIScreen.main.bounds.size.width
    
    
    func nextButton() {
        if self.curSlideIndex == self.data.count - 1 {
            doneFunction()
            return
        }
        
        if self.curSlideIndex < self.data.count - 1 {
            withAnimation {
                self.curSlideIndex += 1
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: .center) {
                ForEach(0..<data.count) { i in
                    OnBoardingStepView(
                        data: self.data[i],
                        animateSymbol: $animateSymbol
                    )
                        .offset(x: CGFloat(i) * self.distance)
                        .offset(x: self.slideGesture.width - CGFloat(self.curSlideIndex) * self.distance)
                        .animation(.spring())
                        .gesture(DragGesture().onChanged{ value in
                            self.slideGesture = value.translation
                        }
                        .onEnded{ value in
                            if self.slideGesture.width < -50 {
                                if self.curSlideIndex < self.data.count - 1 {
                                    withAnimation {
                                        self.curSlideIndex += 1
                                        self.animateSymbol.toggle()
                                    }
                                }
                            }
                            if self.slideGesture.width > 50 {
                                if self.curSlideIndex > 0 {
                                    withAnimation {
                                        self.curSlideIndex -= 1
                                        self.animateSymbol.toggle()
                                    }
                                }
                            }
                            self.slideGesture = .zero
                        })
                }
            }
            
            
            VStack {
                Spacer()
                HStack {
                    self.progressView()
                    Spacer()
                    Button {
                        nextButton()
                        self.animateSymbol.toggle()
                    } label: {
                        self.arrowView()
                    }
                }
            }
            .padding(20)
        }
    }
    
    func arrowView() -> some View {
        Group {
            if self.curSlideIndex == self.data.count - 1 {
                HStack {
                    Text("Entrar")
                        .font(.system(size: 25, weight: .medium, design: .rounded))
                        .foregroundColor(Color(.systemBackground))
                    
                    Image(systemName: "tennisball.fill")
                        .foregroundStyle(.yellow)
                }
                .frame(width: 120, height: 50)
                .background(.accent)
                .cornerRadius(25)
            } else {
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .foregroundColor(.accent)
                    .scaledToFit()
                    .frame(width: 50)
            }
        }
    }
    
    func progressView() -> some View {
        HStack {
            ForEach(0..<data.count) { i in
                Circle()
                    .scaledToFit()
                    .frame(width: 10)
                    .foregroundColor(self.curSlideIndex >= i ? Color(Color.accentColor) : Color(.systemGray))
            }
        }
    }
    
}

struct OnBoardingView_Previews: PreviewProvider {
    static let sample = OnboardingDataModel.data
    static var previews: some View {
        OnBoardingView(data: sample, doneFunction: { print("done") })
    }
}

struct OnboardingDataModel {
    var image: String
    var heading: String
    var text: String
}

extension OnboardingDataModel {
    static var data: [OnboardingDataModel] = [
        OnboardingDataModel(image: "figure.tennis", heading: "Bem-vindo à Padel Tuga", text: "Calendário de todas as actividades da federação de padel em Portugal."),
        OnboardingDataModel(image: "book.pages.fill", heading: "Acede de forma rápida e organizada", text: "A tua próxima actividade de padel na ponta dos dedos. Todas as actividades centralizadas num só sitio."),
        OnboardingDataModel(image: "bolt.heart.fill", heading: "Actividades favoritas", text: "Adiciona as tuas actividades favoritas para um acesso ainda mais imediato")
    ]
}
