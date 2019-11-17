//
//  EditViewController.swift
//  MaterialSMJ
//
//  Created by Justin Smith on 6/5/16.
//  Copyright © 2016 Justin Smith. All rights reserved.
//

import UIKit

struct UndoHistory<Item> {
    let initialValue: [Item]
    var history: [[Item]] = []
    
    init(_ initialValue: [Item]) {
        self.initialValue = initialValue
    }
    
    var currentValue: [Item] {
        get { return history.last ?? initialValue }
        set { history.append(newValue) }
    }
    
    var canUndo: Bool {
        return !history.isEmpty
    }
    
    mutating func undo() {
        _ = history.popLast()
    }
}


struct BarButtonConfiguration {
    enum ButtonType {
      case system(UIBarButtonItem.SystemItem)
        case custom(String)
    }
    let type : ButtonType
    let block : ()->()
}

public struct EditViewContConfiguration<A, Cell: UITableViewCell> {
  let style : UITableView.Style
    var initialValue : [A]
    
    let navTitle : String
    
    let configure : (A, Cell) -> Cell

}
extension EditViewContConfiguration
{
    public init (initialValue : [A],  configure : @escaping (A, Cell) -> Cell)
    {
        self.init(
            style: .plain,
            initialValue: initialValue,
            navTitle: "", configure:  configure)
    }
}

public class EditViewController<A : Equatable, Cell: UITableViewCell> : SimpleBarButtonViewController
{
    
  var undoHistory : UndoHistory<A> {
    didSet {
      print("DID SET UNDO HISTORY")

      let set = Changeset<[A]>(source: oldValue.currentValue, target: undoHistory.currentValue)
      
      tableView.beginUpdates()
      for edit in set.edits
      {
        let ip = IndexPath(row:edit.destination, section:0)
        
        switch edit.operation
        {
        case .deletion:
          print("UHDS-Deletion")
          tableView.deleteRows(at: [ip], with: UITableView.RowAnimation.none)
          didDelete(ip.row, oldValue.currentValue[ip.row])
        case .insertion:
          print("UHDS-insertion")
          tableView.insertRows(at: [ip], with: UITableView.RowAnimation.left)
        case let .move(origin: origin):
          print("UHDS-Move")
          tableView.moveRow(at:  IndexPath(row: origin, section: 0), to:ip)
        case .substitution:
          print("UHDS-Substituion")
          tableView.reloadRows(at: [ip], with: UITableView.RowAnimation.left)
        }
      }
      tableView.endUpdates()
      //tableView.reloadData()
      itemsUpdated(undoHistory.currentValue)
    }
  }
  var items :[A]  { get { return undoHistory.currentValue } }
  var itemsUpdated : ([A]) -> ()  = { _ in }
  var configure : (A, Cell) -> Cell
  var didSelect : (Int,A) -> () = { _, _ in }
  var didSelectAccessory : (Int,A) -> ()  = { _, _ in }
  var willAppear : ()->() = { }

  var didDelete : (Int, A) -> () = { _, _ in }
    
  var didSelectWhileEditing : ((Int,A) -> ())?
  var didSelectAccessoryWhileEditing : ((Int,A) -> ())?
    
    // SHAKE TO UNDO
    override public func viewDidAppear(_ animated: Bool) {
      print("List View Did Appear")

        becomeFirstResponder()
        super.viewDidAppear(animated)
        
    }
    
  override public func viewWillAppear(_ animated: Bool) {
    print("List View Will Appear")
    
    willAppear()
    super.viewWillAppear(true)
    
    // Workaround. clearsSelectionOnViewWillAppear is unreliable for user-driven (swipe) VC dismiss
    let selectedRowIndexPath = self.tableView.indexPathForSelectedRow
    if ((selectedRowIndexPath) != nil) {
      self.tableView.deselectRow(at: selectedRowIndexPath!, animated: true)
      self.transitionCoordinator?.notifyWhenInteractionChanges{
        context in
        if (context.isCancelled) {
          self.tableView.selectRow(at: selectedRowIndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
      }
    }
  }
    
    override public func viewWillDisappear(_ animated: Bool) {
      print("List View Will Disappear")
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }
    
    override public var canBecomeFirstResponder : Bool {
        return true
    }
  override public func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake && self.undoHistory.canUndo {
          let undoPrompt = UIAlertController(title: "Undo", message: nil, preferredStyle: UIAlertController.Style.alert)
          undoPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: ({ (ui:UIAlertAction) -> Void in
            })))
            undoPrompt.addAction(UIAlertAction(title: "Undo", style: UIAlertAction.Style.default, handler: ({ (ui:UIAlertAction) -> Void in
                    self.undoHistory.undo()
            })))
            
            self.present(undoPrompt, animated: true, completion: nil)
        }
    }


    
    override public var isEditing : Bool {
        didSet {
            self.tableView.setEditing(isEditing, animated: true)
        }
    }
  
    public init (config: EditViewContConfiguration<A, Cell>) {
        undoHistory = UndoHistory(config.initialValue)
        configure = config.configure
        super.init(style: config.style)
        tableView.register(Cell.self, forCellReuseIdentifier: "item")
        
        self.navigationItem.title = config.navTitle
        tableView.allowsSelectionDuringEditing = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! Cell
        let item =  items[(indexPath as NSIndexPath).row]
        return configure(item, cell)
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[(indexPath as NSIndexPath).row]
        isEditing ? didSelectWhileEditing?((indexPath as NSIndexPath).row,item) : didSelect((indexPath as NSIndexPath).row,item)
    }
  
  public override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    let item = items[(indexPath as NSIndexPath).row]
    isEditing ? didSelectAccessoryWhileEditing?((indexPath as NSIndexPath).row,item) : didSelectAccessory((indexPath as NSIndexPath).row,item)
  }
    
    override public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
          UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Delete") { (UITableViewRowAction, NSIndexPath) in
            
                self.undoHistory.currentValue.remove(at: indexPath.row)
            }
        ]
    }
    
    
    override public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        var withMovedItems = self.items
        let itemToMove = self.items[(sourceIndexPath as NSIndexPath).row]
        withMovedItems.remove(at: (sourceIndexPath as NSIndexPath).row)
        withMovedItems.insert(itemToMove, at: (destinationIndexPath as NSIndexPath).row)
        self.undoHistory.currentValue = withMovedItems
        
    }
  
  
}

// Alternative Workaround
//var savedSelectedIndexPath: NSIndexPath?
//Then you can put the code in an extension for clarity:
//
//extension MasterViewController {
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        self.savedSelectedIndexPath = nil
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        if let indexPath = self.savedSelectedIndexPath {
//            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
//        }
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        self.savedSelectedIndexPath = tableView.indexPathForSelectedRow
//        if let indexPath = self.savedSelectedIndexPath {
//            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//    }
//}
