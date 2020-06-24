//
//  FilterVC.swift
//  The Cocktail DB
//
//  Created by Vadim Katenin on 22.06.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import UIKit

protocol FilterVCDelegate: class {
    func filterViewController(filter: FilterVC, didSelectCategory category: [Category])
}

class FilterVC: UIViewController {
    
     // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var categories: [Category]?
    var selectedCategory: [Category] = []
    weak var delegate: FilterVCDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        delegate?.filterViewController(filter: self, didSelectCategory: selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: TableViewDelegate, TableViewDataSource
extension FilterVC: UITableViewDelegate, UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let category = categories {
            return category.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        cell.textLabel?.textColor = #colorLiteral(red: 0.5667611957, green: 0.5667749643, blue: 0.5667675734, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Roboto-Regular", size: 16)
        if let category = categories {
        cell.textLabel?.text = category[indexPath.row].category
        }
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
               imgView.image = UIImage(named: "Check")
        if selectedCategory.contains(categories![indexPath.row]) {
            cell.accessoryView = imgView
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
                   return
               }
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        imgView.image = UIImage(named: "Check")
        
        if selectedCategory.contains(categories![indexPath.row]) {
            removeCategory(indexPath: indexPath)
            cell.accessoryView = .none
        } else {
        selectCategory(indexPath: indexPath)
            cell.accessoryView = imgView
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - METHODS
    func selectCategory(indexPath: IndexPath) {
        selectedCategory.append(categories![indexPath.row])
    }
    
    func removeCategory(indexPath: IndexPath) {
        guard let categoryIndexToRemove = selectedCategory.firstIndex(where: { $0 == categories![indexPath.row] }) else { return }
           selectedCategory.remove(at: categoryIndexToRemove)
       }
    
    
}
