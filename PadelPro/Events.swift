//
//  Events.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture

@Reducer
struct Events {
    @ObservableState
    struct State {
        var events: [Event] = []
    }
    
    enum Action {
        case events
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .events:
                state.events = [.init()]
                return .none
            }
        }
    }
}
