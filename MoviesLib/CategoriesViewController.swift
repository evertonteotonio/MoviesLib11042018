//
//  CategoriesViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 09/04/18.
//  Copyright © 2018 EricBrito. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var categories: [Category] = []
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadsCategories()
        
    }
    
    func loadsCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            categories = try context.fetch(fetchRequest)
            tableView.reloadData()
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    func showAlert(category: Category?) {
        
        let title = category == nil ? "Adicionar": "Editar"
        let alert = UIAlertController(title: "\(title)", message: "Preencha abaixo o nome da categoria", preferredStyle: .alert)
        
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome da categoria"
            textField.text = category?.name
        }
        
        let addEditAction = UIAlertAction(title: title, style: .default) { (action) in
            
            let category = category ?? Category(context: self.context)
            category.name = alert.textFields!.first!.text
            try? self.context.save()
            self.loadsCategories()
        }
        
        alert.addAction(addEditAction)
        
        let cancalAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancalAction)
        
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        
        showAlert(category: nil)
        
    }
    
    
}



extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let category = categories[indexPath.row]
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        if let movieCategories = movie?.categories {
            if movieCategories.contains(category){
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        
        return cell
    }
    
    
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category = categories[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            movie?.addToCategories(category)
        } else {
            cell.accessoryType = .none
            movie?.removeFromCategories(category)
        }
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (actions, indexPath) in
            
            let category = self.categories[indexPath.row]
            self.context.delete(category)
            do {
                try self.context.save()
                self.categories.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                
            }
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "✏️") { (action, indexPath) in
            let category = self.categories[indexPath.row]
            self.showAlert(category: category)
            tableView.setEditing(false, animated: true)
        }
        
        editAction.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
        return [editAction, deleteAction]
        
    }
    
    
}
