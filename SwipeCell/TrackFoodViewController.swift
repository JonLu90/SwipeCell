//
//  ViewController.swift
//  TrackFoodExample
//
//  Created by Jon Lu on 1/8/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import UIKit

class TrackFoodViewController: UIViewController {

    let foodArray = generateFood()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FoodCell.self, forCellReuseIdentifier: "FoodCell")
        tableView.backgroundColor = UIColor.lightGray
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
    }

    override func viewWillLayoutSubviews() {
        tableView.frame = view.frame
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

extension TrackFoodViewController: UITableViewDelegate {
    
}

extension TrackFoodViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell") as! FoodCell
        cell.backgroundColor = UIColor.black
        cell.nameLabel.text = foodArray[indexPath.row].name
        cell.servingLabel.text = foodArray[indexPath.row].serving
        cell.smartPtLabel.text = "\(foodArray[indexPath.row].smartPts)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
}

class FoodCell: SwipeTableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let servingLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let smartPtLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //contentView.addSubview(servingLabel)
        contentView.addSubview(smartPtLabel)
        smartPtLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        smartPtLabel.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        smartPtLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        smartPtLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        
        contentView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: smartPtLabel.leftAnchor, constant: -8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        contentView.addSubview(servingLabel)
        servingLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        servingLabel.rightAnchor.constraint(equalTo: smartPtLabel.leftAnchor, constant: -8).isActive = true
        servingLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        servingLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        servingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
