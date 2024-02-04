//
//  Events.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Events {
    @ObservableState
    struct State {
        var events: [EventsModel.EventModel] = []
    }
    
    enum Action {
        case eventsResponse(Result<EventsModel, Error>)
        case retrieveEvents
    }
    
    @Dependency(\.eventsClient) var eventsClient
    private enum CancelID { case events }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .eventsResponse(.failure):
                state.events = []
                return .none
            case let .eventsResponse(.success(response)):
                state.events = response.events
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
            }
        }
    }
}

struct EventsView: View {
    @Bindable var store: StoreOf<Events>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.events, id: \.self) { event in
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "calendar")
                            Text("\(event.month.lowercased().capitalized) - \(event.days)")
                                .foregroundStyle(.gray)
                                .fontWeight(.semibold)
                        }
                        
                        if let location = event.location {
                            HStack {
                                Image(systemName: "location.fill")
                                Text(location)
                            }
                        }
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
