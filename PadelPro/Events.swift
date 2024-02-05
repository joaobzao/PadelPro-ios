//
//  Events.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture
import SwiftUI

enum FilterEventType: LocalizedStringKey, CaseIterable, Hashable {
    case all = "Tudo"
    case trainning = "Formação"
    case competition = "Torneios"
    case league = "Ligas"
}

enum FilterEventDivision: LocalizedStringKey, CaseIterable, Hashable {
    case all = "Tudo"
    case abs = "Absolutos"
    case jov = "Jovens"
    case vet = "Veteranos"
    case adaptado = "Adaptado"
    case vetJov = "Vet & Jov"
}

@Reducer
struct Events {
    @ObservableState
    struct State: Equatable {
        var events: [EventsModel.EventModel] = []
        var filterEventType: FilterEventType = .all
        var filterEventDivision: FilterEventDivision = .abs
        var searchText = ""
        
        var filteredEventsType: [EventsModel.EventModel] {
            switch filterEventType {
            case .all: return events
            case .trainning: return events.filter { $0.type == "FOR" }
            case .competition: return events.filter { $0.type == "CIR" }
            case .league: return events.filter { $0.type == "EQU" }
            }
        }
        
        var eventsByDiv: [String: [EventsModel.EventModel]] {
            Dictionary(grouping: filteredEventsType, by: { $0.division })
        }
        
        var uniqueEventDivs: [String] {
            eventsByDiv.map({ $0.key }).sorted()
        }
    }
    
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case eventsResponse(Result<EventsModel, Error>)
        case searchQuerySubmit(String)
        case events
    }
    
    @Dependency(\.eventsClient) var eventsClient
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
                
            case let .searchQuerySubmit(query):
                guard !query.isEmpty
                else {
                    return .run { send in
                        await send(.events)
                    }
                    .cancellable(id: CancelID.events, cancelInFlight: true)
                }
                
                state.events = state.events.filter { $0.name.contains(query) }
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
                List {
                    ForEach(store.uniqueEventDivs, id: \.self) { division in
                        Section(header: Text(division)) {
                            ForEach(self.store.eventsByDiv[division] ?? [], id: \.self) { event in
                                EventView(event: event)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .onAppear { store.send(.events) }
            .navigationTitle("FPPadel 2024")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $store.searchText, prompt: "Pesquisa")
        .onSubmit(of: .search) { store.send(.searchQuerySubmit(store.searchText)) }
        .onChange(of: store.searchText) {
            guard store.searchText.isEmpty else { return }
            
            store.send(.searchQuerySubmit(store.searchText))
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
