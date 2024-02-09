//
//  Favourites.swift
//  PadelPro
//
//  Created by Joao Zao on 09/02/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Favourites {
    @ObservableState
    struct State: Equatable {
        var events: IdentifiedArrayOf<Event.State> = []
        var filterEventType: FilterEventType = .all
        var filterEventDivision: FilterEventDivision = .abs
        var searchText = ""
    }
    
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case eventsResponse(Result<EventsModel, Error>)
        case searchQuerySubmit(String)
        case retrieveEvents
        case events(IdentifiedActionOf<Event>)
    }
    
    @Dependency(\.eventsClient) var eventsClient
    private enum CancelID {
        case retrieveEvents
        case searchQuerySubmit
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .eventsResponse(.failure):
                state.events = []
                return .none
            case let .eventsResponse(.success(response)):
                state.events = IdentifiedArrayOf(
                    uniqueElements: response.events.map {
                        Event.State(
                            id: $0.id,
                            name: $0.name,
                            month: $0.month,
                            days: $0.days,
                            division: $0.division,
                            classe: $0.class,
                            category: $0.category,
                            type: $0.type,
                            location: $0.location,
                            isFavourite: UserDefaults.standard.bool(forKey: "\($0.id)")
                        )
                    }
                ).filter(\.isFavourite)
                return .none
                
            case .events:
                return .none
                
            case .retrieveEvents:
                return .run { send in
                    await send(
                        .eventsResponse(
                            Result { try await self.eventsClient.events() }
                        )
                    )
                }
                .cancellable(id: CancelID.retrieveEvents, cancelInFlight: true)
            
            case .binding:
                return .none
                
            case let .searchQuerySubmit(query):
                guard !query.isEmpty
                else {
                    return .run { send in
                        await send(.retrieveEvents)
                    }
                    .cancellable(id: CancelID.searchQuerySubmit, cancelInFlight: true)
                }
                
                state.events = state.events.filter { $0.name.contains(query) }
                return .none
            }
        }
        .forEach(\.events, action: \.events) {
              Event()
            }
    }
}

struct FavouritesView: View {
    @Bindable var store: StoreOf<Favourites>
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    ForEach(store.scope(state: \.events, action: \.events)) { store in
                        EventView(store: store)
                            .swipeActions(allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.send(.toggleFavourite(false, "\(store.state.id)"))
                                    self.store.send(.retrieveEvents)
                                } label: {
                                    Image(systemName: "trash.fill")
                                        .tint(Color.red)
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
            .onAppear { store.send(.retrieveEvents) }
            .navigationTitle("Actividades Padel 2024")
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
    FavouritesView(
        store: Store(initialState: Favourites.State()) {
            Favourites()
        }
    )
}
