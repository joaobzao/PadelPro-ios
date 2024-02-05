//
//  PadelProApp.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture
import SwiftUI

@main
struct PadelProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
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
        }
    }
}
