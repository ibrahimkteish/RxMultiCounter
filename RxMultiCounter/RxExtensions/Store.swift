//
//  Store.swift
//
//  Created by Daniel Tartaglia on 3/11/17.
//  Copyright © 2017 Haneke Design. MIT License
//

import Foundation
import RxSwift


class Store<State, Action> {

	init(initialState: State, reducer: Reducer<State, Action>) {
		state = actions
      .scan(into: initialState, accumulator: reducer.reduce)
			.startWith(initialState)
			.share(replay: 1)
	}

	let state: Observable<State>

	private let actions = PublishSubject<Action>()
}

extension Store: ObserverType {

	typealias E = Action

	func on(_ event: Event<E>) {
		if let element = event.element {
			actions.onNext(element)
		}
	}
}
