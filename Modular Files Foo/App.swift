//
//  App.swift
//  HandlesRound1
//
//  Created by Justin Smith on 3/27/18.
//  Copyright © 2018 Justin Smith. All rights reserved.
//

import UIKit
import Singalong
import GrapheNaked
import Volume
@testable import FormsCopy




extension ScaffGraph {
  var width : Measurement<UnitLength> {
    return (grid.pX.max()! |> Double.init, .centimeters) |> Measurement<UnitLength>.init(value:unit:)
  }
  var depth : Measurement<UnitLength> {
    return (grid.pY.max()! |> Double.init, .centimeters) |> Measurement<UnitLength>.init(value:unit:)
  }
  var height : Measurement<UnitLength> {
    return (grid.pZ.max()! |> Double.init, .centimeters) |> Measurement<UnitLength>.init(value:unit:)
  }
  var ledgers : Int {
    return edges.filtered(by: isLedger).count
  }
  var diags : Int {
    return edges.filtered(by: isDiag).count
  }
  var collars : Int {
    return edges.filtered(by: isPoint).count
  }
  var standards : Int {
    return edges.filtered(by: isVertical).count
  }
}





let showPreviewForm: Form<Item<ScaffGraph>> =
  sections([
    section(
      ScaffoldingGridSizes.eventMetric.map { option in
        optionSetCell(title: option.label, option: option, keyPath: \.sizePreferences)
      }
    ),
    section(
      ScaffoldingGridSizes.us.map { option in
        optionSetCell(title: option.label, option: option, keyPath: \.sizePreferences)
      })
    ])

let aSection : Element<Section, Item<ScaffGraph>> = section([
detailTextCell(title: "Notification", keyPath: \.sizePreferences.text, form: showPreviewForm)
], isVisible: \.isEnabled)



let colorsForm: Form<Item<ScaffGraph>> =
  sections([
    section([
     nestedTextField(title: "Name", keyPath: \.name)
     ]),
    section([
      labelCell(title: "Ledgers", label:  intLabel(keyPath: \.content.ledgers), leftAligned: false),
      labelCell(title: "Diags", label:  intLabel(keyPath: \.content.diags), leftAligned: false),
      labelCell(title: "Collars", label:  intLabel(keyPath: \.content.collars), leftAligned: false),
      labelCell(title: "Standards", label:  intLabel(keyPath: \.content.standards), leftAligned: false)
      ]),
    section([
      labelCell(title: "Width", label:  dimLabel(keyPath: \.content.width, formatter: metricFormatter), leftAligned: false),
      labelCell(title: "Depth", label:  dimLabel(keyPath: \.content.depth, formatter: metricFormatter), leftAligned: false),
      labelCell(title: "Height", label:  dimLabel(keyPath: \.content.height, formatter: metricFormatter), leftAligned: false),
      ]),
    section([
      labelCell(title: "Width", label:  dimLabel(keyPath: \.content.width, formatter: imperialFormatter), leftAligned: false),
      labelCell(title: "Depth", label:  dimLabel(keyPath: \.content.depth, formatter: imperialFormatter), leftAligned: false),
      labelCell(title: "Height", label:  dimLabel(keyPath: \.content.height, formatter: imperialFormatter), leftAligned: false),

      ]),
    section([
      detailTextCell(title: "Bay Sizes", keyPath: \.sizePreferences.text, form: showPreviewForm)
      ], isVisible: \.isEnabled)
    
    ])

final class Cell : UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

func createCell(anItem:Item<ScaffGraph> , cell: Cell) -> Cell {
    if let fileName = anItem.thumbnailFileName {
      switch Current.thumbnails.imageFromCacheName(fileName) {
      case let .success(img):
        cell.imageView?.image = img
        cell.imageView?.frame = CGRect(x: -30, y: 0, width: 106, height: 106)
      default:
        break
      }
    }
  
  cell.textLabel?.text = anItem.name
  let formatter = anItem.sizePreferences.mostlyMetric ? metricFormatter : imperialFormatter
  cell.detailTextLabel?.text = "\(anItem.content.width |> formatter) x \(anItem.content.depth |> formatter) x \(anItem.content.height |> formatter)"
  cell.accessoryType = .detailDisclosureButton
  return cell
  }

import ComposableArchitecture
import Interface



struct AppState {
  var quadState : Item1UpView?
  var items : ItemList<ScaffGraph>
}

enum AppAction {
  case itemSelected(Item<ScaffGraph>)
  
  case addOrReplace(Item<ScaffGraph>)
  
  case setItems(ItemList<ScaffGraph>)
  
  case interfaceAction(QuadAction<ScaffGraph>)
  
  var interfaceAction: QuadAction<ScaffGraph>? {
    get {
      guard case let .interfaceAction(value) = self else { return nil }
      return value
    }
    set {
      guard case .interfaceAction = self, let newValue = newValue else { return }
      self = .interfaceAction(newValue)
    }
  }
}

let appReducer =  combine(
  pullback(quadScaffReducer, value: \AppState.quadState!.quad, action: \AppAction.interfaceAction),
  { (state: inout AppState, action: AppAction) -> [Effect<AppAction>] in
    switch action {
      case let .itemSelected(item):
        state.quadState = Item1UpView(quad: QuadScaffState(graph: item.content, size: Current.screen.size), item: item)
        state.quadState!.quad.sizePreferences = item.sizePreferences.map{CGFloat($0.length.converted(to: .centimeters).value)}
        return []
      case let .addOrReplace(item):
        state.items.addOrReplace(item: item)
        return []
        
      case let .setItems(itemList):
        print("WHat")
        state.items = itemList
        return []
        
      case let .interfaceAction(.plan(intfAction)),
           let .interfaceAction(.rotated(intfAction)),
           let .interfaceAction(.front(intfAction)),
           let .interfaceAction(.side(intfAction)):
        switch intfAction {
        case .sprite : return []
        case .canvasAction: return []
        case .saveData:
          let itemsCopy = state.items
          return [Effect{_ in
            Current.file.save(itemsCopy)
            }
          ]
        case let .addOrReplace(graph):
          let item = state.items.getItem(id: graph.id)!
          let newItem = Item(content: graph, id: item.id, name: item.name, sizePreferences: item.sizePreferences, isEnabled: item.isEnabled, thumbnailFileName: item.thumbnailFileName)
          state.items.addOrReplace(item: newItem)
          return []
          
        case let .thumbnailsAddToCache(img, id):
          let item = state.items.getItem(id: id)!
          return [Effect{ callback in
            let urlResult = Current.thumbnails.addToCache(img, nil)
            switch urlResult {
            case let .success(str):
              let newItem = Item(content: item.content, id: item.id, name: item.name, sizePreferences: item.sizePreferences, isEnabled: item.isEnabled, thumbnailFileName: str)
              callback(.addOrReplace(newItem))
            default:
              return
            }
            }]
        }
        
      case .interfaceAction(.page(_)):
        return []
        }
    }
)






public class App {
  public init() {
  }
  
  public lazy var rootController: UIViewController = loadEntryTable
  
  
  var store: Store<AppState,AppAction> = Store(initialValue: AppState(quadState: nil, items: ItemList([])),
                                               reducer: appReducer)
  
  var editViewController : EditViewController<Item<ScaffGraph>, Cell>?
  var inputTextField : UITextField?

  
  lazy var loadEntryTable : UINavigationController  = {
    let load = Current.file.load()
    
    switch load {
    case let .success(value):
      self.store.send(.setItems(value))
    case let .error(error):
       self.store.send(.setItems(ItemList.mock))
    }
            
    let edit = EditViewController(
      config: EditViewContConfiguration( initialValue: self.store.value.items.contents, configure: createCell)
    )
    edit.willAppear = {
      let a = self.store.value.items.contents
      edit.undoHistory.currentValue = self.store.value.items.contents
    }
    edit.tableView.rowHeight = 88
    edit.didSelect = { (item, cell) in
      self.store.send(.itemSelected(cell))
      self.currentNavigator = GraphNavigator(store: self.store.view(value: {$0.quadState!}, action: { .interfaceAction($0) }))
      self.loadEntryTable.pushViewController(self.currentNavigator.vc, animated: true)
    }
    edit.didSelectAccessory = { (item, cell) in
      let driver = FormDriver(initial: cell, build: colorsForm)
      driver.formViewController.navigationItem.largeTitleDisplayMode = .never
        driver.didUpdate = {
          self.store.send(.addOrReplace($0))
          //Current.model.addOrReplace(item: $0)
        }
        self.loadEntryTable.pushViewController(driver.formViewController, animated: true)
        
      }
    edit.topRightBarButton = BarButtonConfiguration(type: .system(.add)) {
      func addTextField(_ textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Definition"
        self.inputTextField = textField
      }
      
      let listNamePrompt = UIAlertController(title: "Name This Structure", message: nil, preferredStyle: UIAlertController.Style.alert)
      listNamePrompt.addTextField(configurationHandler: addTextField)
      listNamePrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: ({ (ui:UIAlertAction) -> Void in
        
      })))
      listNamePrompt.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.default, handler: ({ (ui:UIAlertAction) -> Void in
        let text = self.inputTextField?.text ?? "Default"
        var new : Item<ScaffGraph> = Item(
          content: (Item.template.map{ s in CGFloat( s.length.converted(to:.centimeters).value) }, (200,200,200) |> CGSize3.init) |> createScaffoldingFrom,
          id: text,
          name: text)
        new.content.id = text
        self.store.send(.addOrReplace(new))
        // self.store.send(.interfaceAction(.saveData))
        edit.undoHistory.currentValue = self.store.value.items.contents
      })))
      
      self.rootController.present(listNamePrompt, animated: true, completion: nil)
    }
    edit.title = "Morpho"
    // Moditive
    // Formosis // Formicate, Formite, Formate, Form Morph, UnitForm, Formunit
    // Morpho, massing, Meccano, mechanized, modulus, Moduform, Modju, Mojuform, Majuform
    // Modulo
    self.editViewController = edit
    let nav = UINavigationController(rootViewController: edit)
    styleNav(nav)
    return nav
  }()
  
  var currentNavigator : GraphNavigator!
}






