//
//  EventsClient.swift
//  PadelPro
//
//  Created by Joao Zao on 04/02/2024.
//

import ComposableArchitecture
import Foundation

// MARK: - API models

struct EventsModel: Decodable, Equatable, Sendable {
    let events: [EventModel]
}

struct EventModel: Decodable, Equatable, Sendable {
    let name: String
    let month: String
    let days: String
    let type: String?
    let division: String?
    let location: String?
    let organization: String?
}
