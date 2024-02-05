//
//  Events.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture
import SwiftUI

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
    case all = "Todos"
    case trainning = "Formação"
    case competition = "Competição"
    case league = "Ligas"
}

@Reducer
struct Events {
    @ObservableState
    struct State: Equatable {
        var events: IdentifiedArrayOf<Event.State> = []
        var filter: Filter = .all
        
        var filteredEvents: IdentifiedArrayOf<Event.State> {
            switch filter {
            case .all: return events
            case .trainning: return events.filter { $0.type == "FOR" }
            case .competition: return events.filter { $0.type == "CIR" }
            case .league: return events.filter { $0.type == "EQU" }
            }
        }
    }
    
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case eventsResponse(Result<EventsModel, Error>)
        case events(IdentifiedActionOf<Event>)
        case retrieveEvents
    }
    
    @Dependency(\.eventsClient) var eventsClient
    @Dependency(\.uuid) var uuid
    private enum CancelID { case events }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .eventsResponse(.failure):
                state.events = []
                return .none
            case let .eventsResponse(.success(response)):
                let events = response.events.map { event in
                    Event.State(
                        id: UUID(),
                        name: event.name,
                        month: event.month,
                        days: event.days,
                        type: event.type,
                        location: event.location
                    )
                }
                
                state.events.insert(contentsOf: events, at: 0)
                return .none
                
            case .retrieveEvents:
                return .run { send in
                    await send(
                        .eventsResponse(
                            Result { try await self.eventsClient.events() }
                        )
                    )
                }
                .cancellable(id: CancelID.events, cancelInFlight: true)
            
            case .binding:
                return .none
                
            case .events(_):
                return .none
            }
        }
        .forEach(\.events, action: \.events) {
            Event()
        }
    }
}

struct EventsView: View {
    @Bindable var store: StoreOf<Events>
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Picker("Filter", selection: $store.filter) {
                  ForEach(Filter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                  }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    ForEach(store.scope(state: \.filteredEvents, action: \.events)) { store in
                        EventView(store: store)
                    }
                }
            }
            .onAppear { store.send(.retrieveEvents) }
            .navigationTitle("FPPadel 2024")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
  EventsView(
    store: Store(initialState: Events.State()) {
      Events()
    }
  )
}
