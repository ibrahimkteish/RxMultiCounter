//
//  Coordinator.swift
//  RxMultiCounter
//
//  Created by Daniel Tartaglia on 9/18/18.
//  Copyright © 2018 Daniel Tartaglia. MIT License.
//

import UIKit
import RxSwift
import RxCocoa

class Coordinator {
	init(rootViewController: UISplitViewController) {
    
    let rootReducer = Reducer<(RootState, UUID?), RootAction>.init { (state, action) in
      
      var (rootState, selected) = state
      defer { state =  (rootState, selected) }
      
      switch action {
        
      case .add:
        let id = UUID()
        rootState.order.append(id)
        rootState.counters[id] = 0
      case let .remove(id):
        rootState.order = rootState.order.filter { $0 != id }
        rootState.counters.removeValue(forKey: id)
        if selected == id {
          selected = nil
        }
      case let .increment(id):
        guard let value = rootState.counters[id] else { break }
        rootState.counters[id] = value + 1
      case let .decrement(id):
        guard let value = rootState.counters[id] else { break }
        rootState.counters[id] = value - 1
      case let .select(id):
        selected = id
      }
    }
    
    let detailReducer = Reducer<(DetailState, UUID?), DetailAction>.init { (state, action) in
      var (detailState, selected) = state
      defer { state = (detailState, selected) }
      switch action {
        
      case .incrementSelected:
        guard selected != nil else { break }
//        guard let value = state.counters else { break }
        detailState.counters = detailState.counters + 1
      case .decrementSelected:
        guard selected != nil else { break }
//        guard let value = state.counters[id] else { break }
        detailState.counters = detailState.counters - 1
      case let .select(id):
        selected = id
      }
    }
    
  
    let appReducer: Reducer<AppState, AppAction> = rootReducer.lift(state: both(lens(\.rootState), lens(\.selected)),
                                                                    action: AppAction.prism.rootAction)
      <> detailReducer.lift(state: both(lens(\.detailState), lens(\.selected)), action: AppAction.prism.detailAction)
    
    let reducer = appReducer
    
		store = CounterStore(initialState: initialState, reducer: reducer)
		rootViewController.delegate = self
		let masterNav = rootViewController.children[0] as! UINavigationController
		let master = masterNav.topViewController as! MasterTableViewController
		let detail = rootViewController.children[1] as! DetailViewController

		master.store = store
		detail.store = store

		store.state
			.showDetail()
			.subscribe(onNext: { [weak self] in
				guard let this = self else { return }
				rootViewController.showDetailViewController(detail, sender: this)
			})
			.disposed(by: bag)

		store.state
			.map { $0.selected == nil }
			.bind(to: itemSelected)
			.disposed(by: bag)

		store.state
			.distinctUntilChanged()
			.subscribe(onNext: { state in
				guard let data = try? PropertyListEncoder().encode(state) else { return }
				guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
				let url = dir.appendingPathComponent("save.plist")
				try? data.write(to: url)
			})
			.disposed(by: bag)
	}

	private let store: CounterStore
	private let itemSelected = BehaviorRelay<Bool>(value: true)
	private let bag = DisposeBag()
}

extension Coordinator: UISplitViewControllerDelegate {
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return itemSelected.value
	}
}

private var initialState: AppState {
  let defaultState = AppState(rootState: RootState(order: [], counters: [:]), detailState: DetailState(counters: 0), selected: nil)
  
  guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return defaultState }
	let url = dir.appendingPathComponent("save.plist")
	guard let data = try? Data(contentsOf: url) else { return defaultState }
  guard let state = try? PropertyListDecoder().decode(AppState.self, from: data) else { return defaultState }
//  state.selected = nil
	return state
}
