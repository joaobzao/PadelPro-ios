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
        var events: [EventsModel.EventModel] = []
        var filter: Filter = .all
        
        var filteredEvents: [EventsModel.EventModel] {
            switch filter {
            case .all: return events
            case .trainning: return events.filter { $0.type == "FOR" }
            case .competition: return events.filter { $0.type == "CIR" }
            case .league: return events.filter { $0.type == "EQU" }
            }
        }
        
        var eventsByDiv: [String: [EventsModel.EventModel]] {
            Dictionary(grouping: events, by: { $0.division })
        }
        
        var uniqueEventDivs: [String] {
            eventsByDiv.map({ $0.key }).sorted()
        }
    }
    
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case eventsResponse(Result<EventsModel, Error>)
        case events
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
                state.events = response.events
                return .none
                
            case .events:
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
            }
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
                    ForEach(store.uniqueEventDivs, id: \.self) { division in
                        Section(header: Text(division)) {
                            ForEach(self.store.eventsByDiv[division]!, id: \.self) { event in
                                EventView(event: event)
                            }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .onAppear { store.send(.events) }
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
