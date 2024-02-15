//
//  PadelProApp.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct PadelProApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showNetworkAlert = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: NetworkMonitor.State()) {
                    NetworkMonitor()
                        ._printChanges()
                }
            )
        }
    }
}
import FirebaseAnalytics

struct ContentView: View {
    @Bindable var store: StoreOf<NetworkMonitor>
    @AppStorage("showOnBoarding") private var showOnBoarding: Bool = true
    var data = OnboardingDataModel.data
    
    var body: some View {
        Group {
            if showOnBoarding {
                OnBoardingView(data: data, doneFunction: {
                    showOnBoarding = false
                })
//                .onAppear {
//                    Analytics.logEvent(
//                        AnalyticsEventScreenView,
//                        parameters: [
//                            AnalyticsParameterScreenName: "OnBoardingView",
//                        ]
//                    )
//                }
//                Analytics.logEvent(AnalyticsEventScreenView,
//                                           parameters: [AnalyticsParameterScreenName: "\(ContentView.self)",
//                                                        AnalyticsParameterScreenClass: "\(ContentView.self)"])
            } else {
                TabView {
                    EventsView(
                        store: Store(initialState: Events.State()) {
                          Events()
                            ._printChanges()
                        }
                    )
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text(FilterEventType.all.rawValue)
                    }
                    
                    EventsView(
                        store: Store(
                            initialState: Events.State(
                                filterEventType: .competition
                            )
                        ) {
                            Events()
                                ._printChanges()
                        }
                    )
                    .tabItem {
                        Image(systemName: "figure.tennis")
                        Text(FilterEventType.competition.rawValue)
                    }
                    
                    EventsView(
                        store: Store(
                            initialState: Events.State(
                                filterEventType: .league
                            )
                        ) {
                            Events()
                                ._printChanges()
                        }
                    )
                    .tabItem {
                        Image(systemName: "figure.run.square.stack.fill")
                        Text(FilterEventType.league.rawValue)
                    }
                    
                    EventsView(
                        store: Store(
                            initialState: Events.State(
                                filterEventType: .trainning
                            )
                        ) {
                            Events()
                                ._printChanges()
                        }
                    )
                    .tabItem {
                        Image(systemName: "graduationcap.fill")
                        Text(FilterEventType.trainning.rawValue)
                    }
                    
                    FavouritesView(
                        store: Store(
                            initialState: Favourites.State(
                                filterEventType: .favourites
                            )
                        ) {
                            Favourites()
                                ._printChanges()
                        }
                    )
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text(FilterEventType.favourites.rawValue)
                    }
                }
            }
        }
        .onAppear { store.send(.startLinteningConnectivityChanges) }
        .alert(
            "Parece que estás sem internet!",
            isPresented: $store.state.isDisconnected
        ) {
            
        }
    }
}
