//
//  FileIO.swift
//  Deploy
//
//  Created by Justin Smith on 11/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Graphe


struct FileIO {
  var persistenceURL : URL? = getPersistenceURL()
  var load = loadProgression
  var loadFromBundle = _loadFromBundle
  var loadFromDocuments = _loadFromDocuments
  var save = saveItems
}

enum LoadError : Error {
  case noData
  case noJson
  case badURL
  case badDocumentsURL
}

func loadProgression() -> Result<ItemList<ScaffGraph>, LoadError>{
  
  let documentsResult = Current.file.loadFromDocuments()
  if case .success = documentsResult {
    return documentsResult
  }
  let bundleResult = Current.file.loadFromBundle()
  if case let .success(itemList) = bundleResult {
    Current.file.save(itemList)
    return documentsResult
  }
  
  return bundleResult
}

func _loadFromBundle() -> Result<ItemList<ScaffGraph>, LoadError>{
  
  guard let url = Bundle.main.url(forResource: "Items", withExtension: "json") else {
    return .error( LoadError.badURL )
  }
  guard let data = try? Data(contentsOf: url) else {
    return .error( LoadError.noData )
  }
  do {
    let decoder = JSONDecoder()
    let jsonData = try decoder.decode(ItemList<ScaffGraph>.self, from: data)
    return .success(jsonData)
  } catch  {
    return .error( .noJson )
  }
}

func _loadFromDocuments() -> Result<ItemList<ScaffGraph>, LoadError>{
  
  
  
  guard let url = Current.file.persistenceURL else {
    return .error( LoadError.badURL )
  }
  guard let data = try? Data(contentsOf: url) else {
    return .error( LoadError.noData )
  }
  do {
    let decoder = JSONDecoder()
    let jsonData = try decoder.decode(ItemList<ScaffGraph>.self, from: data)
    return .success(jsonData)
  } catch  {
    return .error( .noJson )
  }
}

func saveItems(item: ItemList<ScaffGraph>) {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .prettyPrinted
  let data = try! encoder.encode(item)
  do {
    if let url = Current.file.persistenceURL {
      try data.write(to: url)
      print("Saved")
    }else {
      fatalError()
    }
  } catch {
    print ( error)
    fatalError()
  }
}

extension FileIO {
  
  static var mock : FileIO = FileIO(persistenceURL: getPersistenceURL(),
                                    load: { .success(.mock) },
                                    loadFromBundle: {.success(.mock)},
                                    loadFromDocuments: {.success(.mock)},
                                    save: {
                                      let encoder = JSONEncoder()
                                      encoder.outputFormatting = .prettyPrinted
                                      let data = try! encoder.encode($0)
                                      //print(String(data: data, encoding: .utf8)!)
  })
}

class DummyClass {
  
}

func getPersistenceURL() -> URL?{
  do {
    let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
    let fileURL = documentDirectory.appendingPathComponent("Items.json")
    return fileURL
  }
  catch {
    return nil
  }
}

func getBundleURL() -> URL {
  let path = Bundle.main.bundleURL
  let fileURL = path.appendingPathComponent("Items.json")
  return fileURL
}
