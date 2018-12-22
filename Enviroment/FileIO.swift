//
//  FileIO.swift
//  Deploy
//
//  Created by Justin Smith on 11/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import Graphe


struct ThumbnailIO {
  var generateCacheURL : (String)->URL? = getCacheURL(dirName: "Thumbnails")
  var imageFromCacheName : (String)->Result<UIImage, LoadError> = _loadFromCache
  var addToCache = _addToCache
  var rewriteToCache = _writeToCache
}

func getCacheURL(dirName:String) -> (String) -> URL?{
  return {
    do {
      let documentDirectory = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
      let folderURL = documentDirectory.appendingPathComponent(dirName)
      if !FileManager.default.fileExists(atPath: folderURL.path) {
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
      }
      let fileURL = folderURL.appendingPathComponent($0)
      print(fileURL)
      return fileURL
    }
    catch let error {
      fatalError(error.localizedDescription)
    }
  }
}

func _loadFromCache(lastPathComponent: String) -> Result<UIImage, LoadError>{
  print("Loading from the last compenent", lastPathComponent)
  
  let cacheUrl = Current.thumbnails.generateCacheURL(lastPathComponent)
    
  print("loading from the generated URL", cacheUrl ?? "NONE" )
  
  guard let url = cacheUrl else {
    return .error( LoadError.badURL )
  }
  do {
    let data = try Data(contentsOf: url)
    guard let image = UIImage(data: data) else {
      return .error( LoadError.badData)
    }
    return .success(image)
    }
  catch let err {
      print(err)
      return .error(.noData)
    }
  
}

func _addToCache(image: UIImage, previousName: String?) -> Result<String, LoadError> {
  if let name = previousName {
    return _writeToCache(image: image, url: Current.thumbnails.generateCacheURL(name) )
  }
  else {
    let uid = UUID().uuidString.lowercased()
    return _writeToCache(image: image, url: Current.thumbnails.generateCacheURL(uid) )
  }
}

func _writeToCache(image: UIImage, url: URL?) -> Result<String, LoadError> {
  guard let newURL = url?.appendingPathExtension("png") else {
    return .error (.badURL)
  }
  guard let data = image.pngData() else {
    return .error( .noData )
  }
  do {
    print(newURL)
    try data.write(to: newURL, options: .atomic)
  } catch let error {
    print(error)
    return .error( .couldntWrite)
  }
  return .success(newURL.lastPathComponent)
}

typealias TypResult = Result<ItemList<ScaffGraph>, LoadError>

struct FileIO {
  var persistenceURL : URL? = getDocumentsURL()
  var load : () -> TypResult = loadProgression
  var loadFromBundle : () -> TypResult = _loadFromBundle
  var loadFromDocuments : () -> TypResult = _loadFromDocuments
  var save : (ItemList<ScaffGraph>) -> () = saveItems
}

enum LoadError : Error {
  case noData
  case badData
  case noJson
  case badURL
  case badDocumentsURL
  case couldntWrite
}


func getDocumentsURL() -> URL?{
  do {
    let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
    let fileURL = documentDirectory.appendingPathComponent("Items.json")
    print(fileURL)
    return fileURL
  }
  catch {
    return nil
  }
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
  
  static var mock : FileIO = FileIO(persistenceURL: getDocumentsURL(),
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


func getBundleURL() -> URL {
  let path = Bundle.main.bundleURL
  let fileURL = path.appendingPathComponent("Items.json")
  return fileURL
}
