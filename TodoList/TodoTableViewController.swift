//
//  ViewController.swift
//  TodoList
//
//  Created by karlis.stekels on 04/02/2021.
//

import UIKit
import CoreData

class TodoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Access to Entity "ToDo"
    var todoList = [Todo]()
    
    var context: NSManagedObjectContext?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelTextRight: UILabel!
    @IBOutlet weak var labelTextLeft: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        // Do any additional setup after loading the view.
        labelTextLeft.text = "Task"
        labelTextRight.text = "Label"
        labelTextRight.textColor = UIColor.systemBackground
        labelTextLeft.textColor = UIColor.systemBackground
        view.backgroundColor = UIColor.gray
        
    }
    
    
    @IBAction func addNewItemTapped(_ sender: Any) {
        addNewItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
    
    
    private func addNewItem(){
        let alertController = UIAlertController(title: "Add New task.", message: "What do you want to add", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter the title of your task."
            textField.autocapitalizationType = .sentences
            textField.autocorrectionType = .no
            
        alertController.addTextField { (textField2: UITextField) in
            textField2.placeholder = "Enter the type..."
            textField2.autocapitalizationType = .allCharacters
            textField2.autocorrectionType = .yes
            }
            
            
        }
        
        let addAction = UIAlertAction(title: "Add", style: .cancel) { (action: UIAlertAction) in
            let textField = alertController.textFields?.first
            let textFiled2 = alertController.textFields?.last
            
            
            let entity = NSEntityDescription.entity(forEntityName: "Todo", in: self.context!)
            let item = NSManagedObject(entity: entity!, insertInto: self.context)
            
            item.setValue(textField?.text, forKey: "item")
            item.setValue(textFiled2?.text, forKey: "category")
            
            
            
            // save func
            self.saveData()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true)
        
    }
    
    func loadData() {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        do {
            let result = try context?.fetch(request)
            todoList = result!
        }catch{
            fatalError(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    func saveData() {
        do {
            try self.context?.save()
        }catch{
            fatalError(error.localizedDescription)
        }
        loadData()
    }
    
    
    //MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func getColor() -> UIColor {
        
        let a = [UIColor.systemRed, UIColor.systemGreen, UIColor.blue, UIColor.cyan, UIColor.systemPink, UIColor.systemTeal, UIColor.systemGray, UIColor.systemOrange, UIColor.systemYellow, UIColor.systemPurple, UIColor.systemIndigo]
        
        let randomNumber = Int.random(in: 1..<a.count)
        
        return a[randomNumber]
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell",for: indexPath)
        let item = todoList[indexPath.row]
        cell.textLabel?.text = item.value(forKey: "item") as? String
        cell.detailTextLabel?.text = item.value(forKey: "category") as? String
        
        if cell.backgroundColor == nil && cell.backgroundColor != getColor(){
            cell.backgroundColor = getColor()
        }
        
        
        
        cell.accessoryType = item.completed ? .checkmark : .none
        cell.selectionStyle = .none
        

        return cell
    }
    
    //MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        todoList[indexPath.row].completed = !todoList[indexPath.row].completed
        saveData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {_ in
                let item = self.todoList[indexPath.row]
                
                self.context?.delete(item)
                self.saveData()
                
            }))
            self.present(alert, animated: true)
        }
    }
}

