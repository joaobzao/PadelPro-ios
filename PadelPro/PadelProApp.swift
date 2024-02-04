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
            EventsView(
                store: Store(initialState: Events.State()) {
                  Events()
                    ._printChanges()
                }
            )
        }
    }
}
