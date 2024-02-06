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
        let id: UUID
        var name: String
        var month: String
        var days: String
        var division: String
        var type: String?
        var location: String?
        var isFavourite: Bool = false
    }
    
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> { 
        BindingReducer()
    }
}

struct EventView: View {
    let event: EventsModel.EventModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.red)
                Text("\(event.month.lowercased().capitalized) - \(event.days)")
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
            }
            
            if let classe = event.class {
                HStack {
                    Image(systemName: "gauge.high")
                    Text(classe)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                }
            }
            
            if let category = event.category {
                HStack {
                    Image(systemName: "scope")
                    Text(category)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                }
            }
            
            if let location = event.location {
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
