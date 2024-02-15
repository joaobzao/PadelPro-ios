//
//  NetworkMonitor.swift
//  PadelPro
//
//  Created by Joao Zao on 14/02/2024.
//

import Foundation
import ComposableArchitecture
import Network

@Reducer
struct NetworkMonitor {
    @ObservableState
    struct State: Equatable {
        var isDisconnected: Bool = false
    }
    
    enum Action: BindableAction ,Sendable {
        case binding(BindingAction<State>)
        case connectivityChanged(Bool)
        case startLinteningConnectivityChanges
    }
    
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    private enum CancelID {
        case retrieveEvents
        case searchQuerySubmit
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            
            switch action {
            case let .connectivityChanged(isDisconnected):
                state.isDisconnected = isDisconnected
                return .none
                
            case .startLinteningConnectivityChanges:
                return .run { send in
                    for await data in networkMonitor {
                        await send(
                            .connectivityChanged(data.status != .satisfied)
                        )
                    }
                    networkMonitor.start(queue: workerQueue)
                }
                .cancellable(id: CancelID.retrieveEvents, cancelInFlight: true)
            case .binding(_):
                return .none
            }
        }
    }
}
