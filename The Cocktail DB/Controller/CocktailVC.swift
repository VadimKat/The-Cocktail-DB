//
//  CocktailVC.swift
//  The Cocktail DB
//
//  Created by Vadim Katenin on 22.06.2020.
//  Copyright © 2020 Vadim Katenin. All rights reserved.
//

import UIKit

class CocktailVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    
    
    // MARK: - Properties
    private let dataFetcher = CocktailAPI()
    private let group = DispatchGroup()
    private var sectionIndex = 0
    private let segueID = "filterVC"
    private var ableToFetch = true
    private var isLoading: Bool = false {
        didSet {
            loadingTriggered?()
        }
    }
    
    // MARK: - Closures-helpers
       var loadingTriggered: (() -> Void)?
       var showError: ((Error) -> Void)?
    
    //MARK: - Standard
    private var cocktails: [String:[Cocktail]] = [:]
    
    private var categories: [Category] = [] {
        didSet {
            let category = categories[0].category
            group.enter()
            loadCocktails(from: category) { [weak self] cocktails in
                self?.cocktails[category] = cocktails
            }
        }
    }
    
    //MARK: - Filtered
    private var selectedCocktails: [String:[Cocktail]] = [:]
    
    
    private var selectedCategories: [Category] = [] {
        didSet {
            selectedCocktails = [:]
            scrollBeginFetch(from: 0)
        }
    }
    
    private var sortedSelectedCategories: [Category] {
        var indecies: [Int] = []
        for category in selectedCategories {
            indecies.append(categories.firstIndex(of: category)!)
        }
        return zip(selectedCategories, indecies).sorted(by: { $0.1 < $1.1 }).map( {$0.0} )
    }
    
   
  
    // MARK: - viewDidLoad()
    
    private(set) var state: ProgressState = .loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: CellIdentifiers.cocktailCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.cocktailCell)
        cellNib = UINib(nibName: CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.loadingCell)
        cellNib = UINib(nibName: CellIdentifiers.errorCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.errorCell)
        
        startLoadingData()
        loadingTriggered = {
            if !self.isLoading {
                self.state = .results
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - METHODS
    
    private func startLoadingData() {
        isLoading = true
        loadCocktailCategories()
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private func loadCocktailCategories() {
        
        group.enter()
        dataFetcher.fetchCategories { [weak self] result in
            
            switch result {
                
            case .success(let categories):
                self?.categories = categories
                
            case .failure(let error):
                self?.showError?(error)
                self?.showAlert(error: error)
                
            }
            self?.group.leave()
        }
    }
    
    private func showAlert(error: Error) {
        let alert = UIAlertController(title: " \(error.localizedDescription)", message: "Check your internet conncetion", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel) { (_) in
            self.state = .error
            self.tableView.reloadData()
        }

        let tryAgain = UIAlertAction(title: "Try again", style: .default) { (_) in
            self.startLoadingData()
            self.loadingTriggered = {
                if !self.isLoading {
                    self.tableView.reloadData()
                }
            }
        }
        alert.addAction(ok)
        alert.addAction(tryAgain)
        present(alert, animated: true)
    }
    
    private func loadCocktails(from category: String, completion: @escaping ([Cocktail]) -> Void) {
        
        guard !categories.isEmpty else { return }
        
        dataFetcher.fetchCocktails(category: category) { [weak self] result in
            
            switch result {
                
            case .success(let cocktails):
                completion(cocktails)
                
            case .failure(let error):
                self?.showError?(error)
            }
            self?.group.leave()
        }
    }
    
    private func scrollBeginFetch(from section: Int) {
        
        DispatchQueue.global(qos: .background).async(group: group) {
            guard !self.categories.isEmpty else { return }
            var category: String
            if self.selectedCategories.isEmpty == true {
                category = self.categories[section].category
                if self.cocktails.contains(where: { $0.key == category }) == false {
                    self.group.enter()
                    self.loadCocktails(from: category) { [weak self] cocktails in
                        self?.cocktails[category] = cocktails
                    }
                }
            } else {
                category = self.sortedSelectedCategories[section].category
                if self.cocktails.contains(where: { $0.key == category }) == false {
                    self.group.enter()
                    self.loadCocktails(from: category) { [weak self] cocktails in
                        self?.selectedCocktails[category] = cocktails
                    }
                } else {
                    self.selectedCocktails[category] = self.cocktails[category]
                }
            }
        }
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            let destinationVC = segue.destination as! FilterVC
            destinationVC.categories = categories
            destinationVC.selectedCategory = selectedCategories
            destinationVC.delegate = self
        }
    }
    
     // MARK: - @IBActions
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: segueID, sender: self)
    }
    
    
}


// MARK: TableViewDelegate, TableViewDataSource
extension CocktailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .loading:
            return 1
        case .error:
         return 1
        case .results:
        if selectedCocktails.isEmpty {
            guard !cocktails.isEmpty else { return 0 }
            let category = categories[section].category
            guard let categoryCocktails = cocktails[category] else { return 0 }
            return categoryCocktails.count
        } else {
            let category = sortedSelectedCategories[section].category
            guard let selectedCategoryCocktails = selectedCocktails[category] else { return 0 }
            return selectedCategoryCocktails.count
        }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loading:
             let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.loadingCell, for: indexPath)
             return cell
        case .error:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.errorCell, for: indexPath)
             return cell
        case .results:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cocktailCell, for: indexPath) as! CocktailCell
                   if selectedCocktails.isEmpty {
                       let category = categories[indexPath.section].category
                       if !cocktails.isEmpty, let categoryCocktails = cocktails[category] {
                           let cocktail = categoryCocktails[indexPath.row]
                           cell.configure(result: cocktail)
                       }
                   } else {
                       let category = sortedSelectedCategories[indexPath.section].category
                       if let selectedCategoryCocktails = selectedCocktails[category] {
                           let cocktail = selectedCategoryCocktails[indexPath.row]
                           cell.configure(result: cocktail)
                       }
                   }
             return cell
        }
//        return cell
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch state {
        case .loading: return 1
        case .error: return 1
        case .results:
            guard !selectedCategories.isEmpty else { return categories.count }
             return selectedCategories.count
        }
       
        
       
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        switch state {
        case .loading: return view
        case .error: return view
        case .results:
        
        let label = UILabel()
        label.font = UIFont(name: "Roboto-Regular", size: 14)
        if selectedCategories.isEmpty {
            label.text = "\(categories[section].category)"
        } else {
            label.text = "\(sortedSelectedCategories[section].category)"
        }
        label.textColor = UIColor(red: 0.496, green: 0.496, blue: 0.496, alpha: 1)
        label.frame = CGRect(x: 20, y: 5, width: 200, height: 35)
        view.addSubview(label)
        return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}

// MARK: - scrollViewDidScroll
extension CocktailVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var categories: [Category] = []
        if selectedCategories.isEmpty {
            categories = self.categories
        } else {
            categories = selectedCategories
        }
        
        if sectionIndex < categories.count {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - (2 * scrollView.frame.height) {
                if ableToFetch {
                    ableToFetch = false
                    scrollBeginFetch(from: sectionIndex)
                    tableView.reloadData()
                    ableToFetch = true
                    sectionIndex += 1
                }
            }
        }
    }
}

// MARK: - FilterVCDelegate
extension CocktailVC: FilterVCDelegate {
    func filterViewController(filter: FilterVC, didSelectCategory category: [Category]) {
        selectedCategories = category
        sectionIndex = 0
    }
    
    
}
