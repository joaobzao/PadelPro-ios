//
//  Event.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Event {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: Int
        var name: String
        var month: String
        var days: String
        var division: String
        var classe: String?
        var category: String?
        var type: String?
        var location: String?
        var isFavourite: Bool
    }
    
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case toggleFavourite(Bool, String)
    }
    
    var body: some Reducer<State, Action> { 
        BindingReducer()
        Reduce { state, action in
            
            switch action {
            case let .toggleFavourite(toggle, itemId):
                if toggle {
                    UserDefaults.standard.set(toggle, forKey: itemId)
                } else {
                    UserDefaults.standard.removeObject(forKey: itemId)
                }

                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct EventView: View {
    @Bindable var store: StoreOf<Event>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.red)
                Text("\(store.month.lowercased().capitalized) - \(store.days)")
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
            }
            
            if let classe = store.classe {
                HStack {
                    Image(systemName: "gauge.high")
                    Text(classe)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                }
            }
            
            if let category = store.category {
                HStack {
                    Image(systemName: "scope")
                    Text(category)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                }
            }
            
            if let location = store.location {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundStyle(Color.accentColor)
                    Text(location)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
