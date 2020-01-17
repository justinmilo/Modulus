//
//  FileIO.swift
//  Deploy
//
//  Created by Justin Smith on 11/22/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import Foundation
import GrapheNaked


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
      return fileURL
    }
    catch let error {
      fatalError(error.localizedDescription)
    }
  }
}

func _loadFromCache(lastPathComponent: String) -> Result<UIImage, LoadError>{
  
  let cacheUrl = Current.thumbnails.generateCacheURL(lastPathComponent)
    
  
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
  catch {
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
  guard var newURL = url else {
    return .error (.badURL)
  }
  if newURL.pathExtension != "png" {
    newURL.appendPathExtension("png")
  }
  guard let data = image.pngData() else {
    return .error( .noData )
  }
  do {
    try data.write(to: newURL, options: .atomic)
  } catch {
    return .error( .couldntWrite)
  }
  return .success(newURL.lastPathComponent)
}

typealias TypResult = Result<ItemList<ScaffGraph>, LoadError>

struct FileIO {
  var persistenceURL : URL? = getDocumentsURL()
  var load : () -> TypResult = loadProgression
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
  
  
  return documentsResult
}



func addIDToScaffGraph(itemList : inout ItemList<ScaffGraph>) {
  for (offset, element) in itemList.contents.enumerated() {
    let scaffGraph = itemList.contents[offset].content
    print("was", scaffGraph.id, "will be", element.id)
    scaffGraph.id = element.id
    itemList.addOrReplace(item: Item(content: scaffGraph, id: element.id, name: element.name, sizePreferences: element.sizePreferences, isEnabled: element.isEnabled, thumbnailFileName: element.thumbnailFileName))
  }
}

func _loadFromDocuments() -> Result<ItemList<ScaffGraph>, LoadError>{
  
  print("Loading from Load Documents")
  
  
  guard let url = Current.file.persistenceURL else {
    return .error( LoadError.badURL )
  }
  guard let data = try? Data(contentsOf: url) else {
    return .error( LoadError.noData )
  }
  do {
    print("Loading from Load Documents DOOOO")

    let decoder = JSONDecoder()
    var jsonData = try decoder.decode(ItemList<ScaffGraph>.self, from: data)
    #warning("Begin Should remove crutch")
    addIDToScaffGraph(itemList: &jsonData)
    #warning("Begin Should remove crutch")
    
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
    }else {
      fatalError()
    }
  } catch {
    fatalError()
  }
}

extension FileIO {
  
  static var mock : FileIO = FileIO(persistenceURL: getDocumentsURL(),
                                    load: { .success(.mock) },
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
