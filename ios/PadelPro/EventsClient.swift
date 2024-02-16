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
    
    struct EventModel: Decodable, Hashable, Equatable, Sendable {
        let id: Int
        let name: String
        let month: String
        let days: String
        let type: String?
        let category: String?
        let `class`: String?
        let prizeMoney: String?
        let division: String
        let location: String?
        let organization: String?
    }
}

// MARK: - API client interface

@DependencyClient
struct EventsClient {
  var events: @Sendable () async throws -> EventsModel
}

extension EventsClient: TestDependencyKey {
  static let previewValue = Self(
    events: { .mock }
  )

  static let testValue = Self()
}

extension DependencyValues {
  var eventsClient: EventsClient {
    get { self[EventsClient.self] }
    set { self[EventsClient.self] = newValue }
  }
}

// MARK: - Live API implementation

extension EventsClient: DependencyKey {
  static let liveValue = EventsClient(
    events: {
      var url = URL(string: "https://joaobzao.github.io/api/fppadel/2024.json")!

      let (data, _) = try await URLSession.shared.data(from: url)
      return try jsonDecoder.decode(EventsModel.self, from: data)
    }
  )
}

// MARK: - Mock data

extension EventsModel {
  static let mock = Self(
    events: [
        .init(
            id: 1,
            name: "Open Aveiro Padel Veteranos",
            month: "FEVEREIRO",
            days: "23 a 25",
            type: "CIR",
            category: "F: +35, +40, +45 e +50; M: +35, +40, +45, +50, +55 e +60",
            class: "2.000",
            prizeMoney: "1.000€",
            division: "VET",
            location: "Open Aveiro Padel Veteranos",
            organization: "Aveiro Padel Indoor"
        ),
        .init(
            id: 1,
            name: "Open Aveiro Padel",
            month: "FEVEREIRO",
            days: "23 a 25",
            type: "CIR",
            category: "F1 a F6; M1 a M6",
            class: "2.000",
            prizeMoney: "1.000€",
            division: "ABS",
            location: "Aveiro",
            organization: "Aveiro Padel Indoor"
        ),
        .init(
            id: 1,
            name: "Open Aveiro Padel Veteranos",
            month: "FEVEREIRO",
            days: "23 a 25",
            type: "CIR",
            category: "F: +35, +40, +45 e +50; M: +35, +40, +45, +50, +55 e +60",
            class: "2.000",
            prizeMoney: "1.000€",
            division: "VET",
            location: "Open Aveiro Padel Veteranos",
            organization: "Aveiro Padel Indoor"
        )
    ]
  )
}

// MARK: - Private helpers

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  return decoder
}()
