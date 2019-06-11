//
//  DetailViewActions.swift
//  RxMultiCounter
//
//  Created by Daniel Tartaglia on 9/18/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift

extension ObservableType where Element == Void {
  func incrementSelected(state: Observable<AppState>) -> Observable<AppAction> {
		return withLatestFrom(state).map { state in AppAction.rootAction(.increment(state.selected!)) }
	}

  func decrementSelected(state: Observable<AppState>) -> Observable<AppAction> {
    return withLatestFrom(state).map { state in AppAction.rootAction(.decrement(state.selected!)) }
	}
}

extension ObservableType where Element == [Any] {
	func selectNil() -> Observable<AppAction> {
    return map { _ in AppAction.rootAction(.select(nil))} //.select(nil) }
	}
}
