//
//  Result.swift
//  Deploy
//
//  Created by Justin Smith on 11/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation


enum Result<Value, Error> {
  case success(Value)
  case error(Error)
}

