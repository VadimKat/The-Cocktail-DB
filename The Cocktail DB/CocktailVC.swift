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
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
        var cellNib = UINib(nibName: CellIdentifiers.cocktailCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: CellIdentifiers.cocktailCell)
    }
    
    
}

extension CocktailVC: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.cocktailCell, for: indexPath)
        return cell
    }
    
    
}
