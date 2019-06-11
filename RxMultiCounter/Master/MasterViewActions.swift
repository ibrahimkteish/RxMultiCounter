//
//  MasterViewActions.swift
//  RxMultiCounter
//
//  Created by Daniel Tartaglia on 9/18/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import Foundation
import RxSwift

extension ObservableType where Element == Void {
	func add() -> Observable<AppAction> {
		return map { AppAction.rootAction(.add) }
	}
}

extension ObservableType where Element == IndexPath {
  
  func selectedObject(state: Observable<AppState>) -> Observable<UUID?> {
   return withLatestFrom(state.map { $0.rootState.order }) { $1[$0.row] }
  }
  
	func select(state: Observable<AppState>) -> Observable<AppAction> {
		return selectedObject(state: state)
			.map { AppAction.rootAction(.select($0)) }
	}

  func select2(state: Observable<AppState>) -> Observable<AppAction> {
    return selectedObject(state: state)
      .map { AppAction.detailAction(.select($0)) }
  }
	
  func delete(state: Observable<AppState>) -> Observable<AppAction> {
		return withLatestFrom(state.map { $0.rootState.order }) { $1[$0.row] }
			.map { AppAction.rootAction(.remove($0)) }
	}
}
