//
//  Lenses.swift
//  RxMultiCounter
//
//  Created by Ibrahim on 6/12/19.
//  Copyright © 2019 Daniel Tartaglia. All rights reserved.
//

import Foundation

struct Lens<A, B> {
  let view: (A) -> B
  let mutatingSet: (inout A, B) -> Void

  func set(_ whole: A, part: B) -> A {
    var result = whole
    self.mutatingSet(&result, part)
    return result
  }
}

func lens<A, B>(_ keyPath: WritableKeyPath<A, B>) -> Lens<A, B> {
  return Lens<A, B>.init(view: { $0[keyPath: keyPath]},
                         mutatingSet: { (whole, part) in whole[keyPath:keyPath] = part  })
}

func both<A, B, C>(_ lhs: Lens<A, B>, _ rhs: Lens<A, C>) -> Lens<A, (B, C)> {
  return Lens<A, (B, C)>.init(view: { (lhs.view($0), rhs.view($0)) },
                              mutatingSet: { (whole, part) in
                                lhs.mutatingSet(&whole, part.0)
                                rhs.mutatingSet(&whole, part.1)
  })
}

extension Reducer {
  func lift<T, B>(state: Lens<T, S>, action: Prism<B, A>) -> Reducer<T, B> {
    return Reducer<T, B>.init{ stateT, actionB in
      guard let actionA = action.preview(actionB) else { return }
      var stateS = state.view(stateT)
      self.reduce(&stateS, actionA)
      state.mutatingSet(&stateT, stateS)
    }
  }
}

enum Either<A, B> {
  case left(A)
  case right(B)
}

func either<A, B, C>(_ lhs: Prism<A, B>, _ rhs: Prism<A, C>) -> Prism<A, Either<B, C>> {
  return Prism<A, Either<B, C>>.init(preview: { lhs.preview($0).map { Either.left($0) } ?? rhs.preview($0).map { Either.right($0) } },
                                     review: {
                                      switch $0 {
                                      case let .left(b):
                                        return lhs.review(b)
                                      case let .right(c):
                                        return rhs.review(c)
                                      }
  })
}

