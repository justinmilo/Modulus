//
//  TypedNotifications.swift
//  HandlesRound1
//
//  Created by Justin Smith on 7/9/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation

class Box<T> {
  let unbox: T
  init(_ value: T) { self.unbox = value }
}

struct Notification<A> {
  let name: String
}

func postNotification<A>(note: Notification<A>, value: A) {
  let userInfo = ["value": Box(value)]
  NotificationCenter.default.post(
    name: NSNotification.Name(rawValue:note.name),
    object: nil,
    userInfo: userInfo
  )
}

class NotificationObserver {
  let observer: NSObjectProtocol
  
  init<A>(notification: Notification<A>, block aBlock: @escaping (A) -> ()) {
    observer = NotificationCenter.default.addObserver(
      forName: NSNotification.Name(rawValue:notification.name),
      object: nil,
      queue: nil) { note in
        if let value = (note.userInfo?["value"] as? Box<A>)?.unbox {
          aBlock(value)
        } else {
          assert(false, "Couldn't understand user info")
      }
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(observer)
  }
}

