extension Effect where A == (Data?, URLResponse?, Error?) {
  public func decode<M: Decodable>(as type: M.Type) -> Effect<M?> {
    return self.map { data, _, _ in
      data
        .flatMap { try? JSONDecoder().decode(M.self, from: $0) }
    }
  }
}

extension Effect {
  public func receive(on queue: DispatchQueue) -> Effect {
    return Effect { callback in
      self.run { a in
        queue.async {
          callback(a)
        }
      }
    }
  }
}

public func dataTask(with url: URL) -> Effect<(Data?, URLResponse?, Error?)> {
  return Effect { callback in
    URLSession.shared.dataTask(with: url) { data, response, error in
      callback((data, response, error))
    }
    .resume()
  }
}

extension Effect {
  public func run(on queue: DispatchQueue) -> Effect {
    return Effect { callback in
      queue.async {
        self.run({a in callback(a) })
      }
    }
  }
}


// isPrim Effect work -> Callback
// isPrim.run Effect  Effect work -> Callback

// b.run({ b in print(b) })
// ... b.run( { ... run in background

extension Effect {
  func cancellable(id: String) -> Effect {
    return Effect { callback in
      // if
      if let shouldCancel = _cancelled[id], shouldCancel==true {
        return
      }
      // else
      self.run{ a in
        callback(a)
      }
    }
  }
  static func cancel(id: String) -> Effect {
    return Effect{callback in
      _cancelled[id] = true
    }
  }
  
}

var _cancelled : [String:Bool] = [:]
