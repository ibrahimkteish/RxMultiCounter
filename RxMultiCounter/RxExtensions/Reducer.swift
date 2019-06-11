//
//  Reducer.swift
//  RxMultiCounter
//
//  Created by Ibrahim on 6/2/19.
//  Copyright © 2019 Daniel Tartaglia. All rights reserved.
//

import RxSwift

struct Reducer<S, A> {
  //(S, A) -> S <=> (inout, A) -> Void
  let reduce: (inout S, A) -> Void
}

precedencegroup MonoidAppend {
  associativity: left
}

infix operator <>: MonoidAppend

protocol Monoid {
  static var identity: Self { get }
  static func <> (lhs: Self, rhs: Self) -> Self
}

extension Reducer: Monoid {
  static var identity: Reducer<S, A> {
    return Reducer { s, _ in return }
  }
  
  static func <> (lhs: Reducer<S, A>, rhs: Reducer<S, A>) -> Reducer<S, A> {
    return Reducer<S, A> { s, a in
      lhs.reduce(&s, a)
      rhs.reduce(&s, a)
    }
  }
}

extension Reducer {
  func lift<GlobalState>(state: WritableKeyPath<GlobalState, S>) -> Reducer<GlobalState, A> {
    return Reducer<GlobalState, A> { gs, a in
      self.reduce(&gs[keyPath: state], a)
    }
  }
}

struct Prism<A, B> {
  let preview: (A) -> B?
  let review: (B) -> A
}

extension AppAction {
  enum prism {
    static let rootAction = Prism<AppAction, RootAction>(
      preview: { if case let .rootAction(action) = $0 { return action }; return nil },
      review: AppAction.rootAction
    )
    
    
    static let detailAction = Prism<AppAction, DetailAction>(
      preview: { if case let .detailAction(action) = $0 { return action }; return nil },
      review: AppAction.detailAction
    )
  }
}
