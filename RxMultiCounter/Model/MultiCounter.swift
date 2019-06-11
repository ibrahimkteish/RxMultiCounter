//
//  MultiCounter.swift
//  RxMultiCounter
//
//  Created by Daniel Tartaglia on 9/18/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift
import DifferenceKit

enum RootAction {
  case add
  case remove(UUID)
  case increment(UUID)
  case decrement(UUID)
  case select(UUID?)
}

enum DetailAction {
  case incrementSelected
  case decrementSelected
  case select(UUID?)
}

enum AppAction {
  case rootAction(RootAction)
  case detailAction(DetailAction)
}

struct RootState: Codable, Equatable {
  var order: [UUID] = []
  var counters: [UUID: Int] = [:]
}

struct DetailState: Codable, Equatable {
  var counters: Int = 0
}

struct AppState: Codable, Equatable {
  var rootState: RootState = .init()
  var detailState: DetailState = .init()
  var selected: UUID?
}

extension ObservableType where Element == AppState {
	func deselect() -> Observable<Void> {
		return filter { $0.selected == nil }
			.map { _ in }
	}

	func counterText(for id: UUID) -> Observable<String> {
		return map { $0.rootState.counters[id] }
			.map { $0 != nil ? "\($0!)" : "" }
	}

	func counterTextForSelected() -> Observable<String> {
		return map { state in
			guard let selected = state.selected else { return "" }
			guard let value = state.rootState.counters[selected] else { return "" }
			return "\(value)"
		}
	}

	func showDetail() -> Observable<Void> {
		return map { $0.selected }
			.distinctUntilChanged()
			.compactMap { $0 }
			.map { _ in }
	}

	func lastSelectedID() -> Observable<UUID> {
		return map { $0.selected }
			.compactMap { $0 }
	}
}

typealias CounterStore = Store<AppState, AppAction>

extension UUID: Differentiable { }
