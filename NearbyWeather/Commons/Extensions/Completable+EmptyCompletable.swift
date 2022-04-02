//
//  Completable+EmptyCompletable.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 18.03.22.
//  Copyright © 2022 Erik Maximilian Martens. All rights reserved.
//

import RxSwift

extension Completable {
  static var emptyCompletable: Completable {
    Completable.create { handler in
      handler(.completed)
      return Disposables.create()
    }
  }
}
