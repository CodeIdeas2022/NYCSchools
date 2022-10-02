//
//  SchoolListHeaderView.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import UIKit

class SchoolListHeaderView: UIView {
    let sortButton: UIButton
    let searchButton: UIButton
    let title: UILabel
    let sortType: UILabel
    init() {
        self.sortButton = UIButton(type: .custom)
        self.searchButton = UIButton(type: .custom)
        self.title = UILabel()
        self.sortType = UILabel()
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)
        addSubview(sortType)
        addSubview(sortButton)
        addSubview(searchButton)

        title.numberOfLines = 0
        title.textAlignment = .center
        title.lineBreakMode = .byWordWrapping
        title.text = "NYC Schools"
        title.textColor = .white
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        title.topAnchor.constraint(equalTo: sortButton.topAnchor).isActive = true
        
        sortType.textAlignment = .center
        sortType.lineBreakMode = .byWordWrapping
        sortType.textColor = .lightText
        sortType.font = UIFont.systemFont(ofSize: 14)
        sortType.translatesAutoresizingMaskIntoConstraints = false
        sortType.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        sortType.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 0.0).isActive = true
        
        
        let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let sortImage = UIImage(systemName: "arrow.up.arrow.down.square", withConfiguration: config)
        sortButton.tintColor = .lightGray
        sortButton.setImage(sortImage, for: .normal)
        sortButton.imageView?.contentMode = .scaleAspectFill
        if sortImage == nil {
            sortButton.setBorderColor(.white)
        }
        sortButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        sortButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        sortButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        
        let searchImage = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        searchButton.tintColor = .lightGray
        searchButton.setImage(searchImage, for: .normal)
        searchButton.imageView?.contentMode = .scaleAspectFill
        if searchImage == nil {
            searchButton.setBorderColor(.white)
        }
        searchButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        searchButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
