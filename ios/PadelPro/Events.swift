//
//  Events.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture
import SwiftUI
import FirebaseAnalytics

enum FilterEventType: LocalizedStringKey, CaseIterable, Hashable {
    case all = "Tudo"
    case trainning = "Formação"
    case competition = "Torneios"
    case league = "Ligas"
    case favourites = "Favoritos"
}

enum FilterEventDivision: String, Comparable, CaseIterable, Hashable {
    static func < (lhs: FilterEventDivision, rhs: FilterEventDivision) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
    
    case abs = "ABS"
    case jov = "JOV"
    case vet = "VET"
    case adaptado = "PA"
    case vetJov = "VET e JOV"
    case coach = "TR"
    case ref = "JA"
    case assembleia = "AG"
    case director = "DIR"
    case organization = "AO"
    
    private var sortOrder: Int {
        switch self {
        case .abs: 0
        case .jov: 1
        case .vet: 2
        case .adaptado: 3
        case .vetJov: 4
        case .coach: 5
        case .ref: 6
        case .assembleia: 7
        case .director: 8
        case .organization: 9
        }
    }
    
    var description: String {
        switch self {
        case .abs: "Absolutos"
        case .jov: "Jovens"
        case .vet: "Veteranos"
        case .adaptado: "Adaptado"
        case .vetJov: "Vet & Jov"
        case .coach: "Treinador"
        case .ref: "Juiz Árbitro"
        case .assembleia: "Assembleia Geral"
        case .director: "Formação de Dirigentes"
        case .organization: "FPPadel Organização"
        }
    }
}

@Reducer
struct Events {
    @ObservableState
    struct State: Equatable {
        var modifiedAt: Date = Date()
        var events: IdentifiedArrayOf<Event.State> = []
        var filterEventType: FilterEventType = .all
        var filterEventDivision: FilterEventDivision = .abs
        var searchText = ""
        
        var filteredEventsType: IdentifiedArrayOf<Event.State> {
            switch filterEventType {
            case .all: return events
            case .trainning: return events.filter { $0.type == "FOR" }
            case .competition: return events.filter { $0.type == "CIR" }
            case .league: return events.filter { $0.type == "EQU" }
            case .favourites: return events.filter(\.isFavourite)
            }
        }
        
        var eventsByDiv: [String: IdentifiedArrayOf<Event.State>] {
            Dictionary(grouping: filteredEventsType, by: { $0.division })
                .mapValues { IdentifiedArray(uniqueElements: $0) }
        }
        
        var uniqueEventDivs: [FilterEventDivision] {
            eventsByDiv.map {
                guard let division = FilterEventDivision(rawValue: $0.key)
                else {
                    assertionFailure("division missing:  \($0.key)")
                    
                    return FilterEventDivision.abs
                }
                
                return division
            }.sorted()
        }
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
                state.modifiedAt = response.modifiedAt
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
                )
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

struct EventsView: View {
    @Bindable var store: StoreOf<Events>
    @State private var modifiedAtAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    ForEach(store.uniqueEventDivs, id: \.self) { division in
                        Section(
                            header: Text(division.description)
                                .font(.title2)
                                .fontWeight(.semibold)
                        ) {
                            ForEach(store.scope(state: \.eventsByDiv[safe: division.rawValue], action: \.events)) { store in
                                EventView(store: store)
                                    .swipeActions {
                                        Button {
                                            store.state.isFavourite.toggle()
                                            store.send(.toggleFavourite(store.state.isFavourite, "\(store.state.id)"))
                                        } label: {
                                            VStack {
                                                Image(systemName: store.state.isFavourite ? "heart.slash.fill" : "heart.fill")
                                                    .tint(store.state.isFavourite ? Color.gray : Color.green)
                                                
                                                Text(store.state.isFavourite ? "remove" : "add")
                                            }
                                        }
                                        
                                    }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .onAppear { store.send(.retrieveEvents) }
            .navigationTitle("Actividades Padel 2024")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        modifiedAtAlert.toggle()
                    } label: {
                        // Specify the image here
                        Image(systemName: "info.circle") // Using SF Symbols
                    }
                    .alert(isPresented: $modifiedAtAlert) {
                        Alert(
                            title: Text("Actualização Calendário"),
                            message: Text("O calendário foi actualizado na data: \(store.state.modifiedAt.yearMonthDay)"),
                            dismissButton: .default(
                                Text("OK")
                            )
                        )
                    }
                }
            }
        }
        .searchable(text: $store.searchText, prompt: "Pesquisa")
        .onSubmit(of: .search) { store.send(.searchQuerySubmit(store.searchText)) }
        .onChange(of: store.searchText) {
            guard store.searchText.isEmpty else { return }
            
            store.send(.searchQuerySubmit(store.searchText))
        }
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView,
                                       parameters: [AnalyticsParameterScreenName: "\(EventsView.self)",
                                                    AnalyticsParameterScreenClass: "\(EventsView.self)"])
        }
    }
}

extension Date {
    var yearMonthDay: String {
        let calendar = Calendar.current

        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)

        return "\(day)/\(month)/\(year)"
    }
}

extension Dictionary where Value == IdentifiedArrayOf<Event.State> {
    subscript(safe key: Key) -> Value {
        return self[key] ?? Value()
    }
}

#Preview {
  EventsView(
    store: Store(initialState: Events.State()) {
      Events()
    }
  )
}
