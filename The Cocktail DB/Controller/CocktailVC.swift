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
    
    private let dataFetcher = CocktailAPI()
    
    
    //MARK: - Standard
    private var cocktails: [String:[Cocktail]] = [:]
    
    // 8. As soon as we get categories, didSet triggers loadCocktails and populates cocktails array
    private(set) var categories: [Category] = [] {
        didSet {
            let category = categories[0].category
            group.enter()
            loadCocktails(from: category) { [weak self] cocktails in
                self?.cocktails[category] = cocktails
            }
        }
    }
    
    //MARK: - Filtered
    var selectedCocktails: [String:[Cocktail]] = [:]
    
    
    var selectedCategories: [Category] = [] {
        didSet {
            selectedCocktails = [:]
            scrollBeginFetch(from: 0)
        }
    }
    
    var sortedSelectedCategories: [Category] {
        var indecies: [Int] = []
        for category in selectedCategories {
            indecies.append(categories.firstIndex(of: category)!)
        }
        return zip(selectedCategories, indecies).sorted(by: { $0.1 < $1.1 }).map( {$0.0} )
    }
    
    
    
    
    
    var isLoading: Bool = false {
        didSet {
            loadTriggered?()
        }
    }
    
       var sectionIndex = 0
    private var canFetchMore = true
    
    
    
    var loadTriggered: (() -> Void)?
    var reloadData: (() -> Void)?
    var showError: ((Error) -> Void)?
    let group = DispatchGroup()
    
    
    
    
    //MARK: Loading Data
    // 3. trigger load
    func startLoadingData() {
        // 4. trigger load did set for first time but nothing heppens
        isLoading = true
        // 5. loading categories
        loadCocktailCategories()
        
        // 9. we trigger didSet isLoading for the second time
        group.notify(queue: .main) {
            self.isLoading = false
//            self.reloadData?()
        }
    }
    
    //MARK: Loading Categories
    
    // 6. load categories
    private func loadCocktailCategories() {
        
        group.enter()
        dataFetcher.fetchCategories { [weak self] result in
            
            switch result {
                
            case .success(let categories):
                // 7. categories get value and did set triggers
                self?.categories = categories
                
            case .failure(let error):
                self?.showError?(error)
            }
            self?.group.leave()
        }
    }
    
    //MARK: Loading Cocktails
    
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
    
    func scrollBeginFetch(from section: Int) {
        
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
            self.reloadData?()
        }
    }
    
    //
    //         //MARK: FilterView UI
    //
    //         func filterViewModel() -> FilterViewModel {
    //             let filterCategories = categories
    //             return FilterViewModel(categories: filterCategories)
    //         }
    
    
    
    
    
    let segueID = "filterVC"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. register cell
        let cellNib = UINib(nibName: CellIdentifiers.cocktailCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.cocktailCell)
        // 2. load data
        startLoadingData()
        // 10. we reload data after didSet triggered
        loadTriggered = {
            if !self.isLoading {
                self.tableView.reloadData()
            }
    }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            let destinationVC = segue.destination as! FilterVC
            destinationVC.categories = categories
            destinationVC.selectedCategory = selectedCategories
            destinationVC.delegate = self
        }
    }
    
    
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: segueID, sender: self)
    }
    
    
}

extension CocktailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 120
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            
            func numberOfSections(in tableView: UITableView) -> Int {
                guard !selectedCategories.isEmpty else { return categories.count }
                
                return selectedCategories.count
            }
    
          func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let view = UIView()
            view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
           
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
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
                if canFetchMore {
                    canFetchMore = false
                    scrollBeginFetch(from: sectionIndex)
                    reloadData = {
                        self.tableView.reloadData()
                        self.canFetchMore = true
                    }
                    sectionIndex += 1
                    print("Section index: \(sectionIndex)")
                }
            }
        }
    }
}

extension CocktailVC: FilterVCDelegate {
    func filterViewController(filter: FilterVC, didSelectCategory category: [Category]) {
        selectedCategories = category
        sectionIndex = 0
    }
    
    
}
