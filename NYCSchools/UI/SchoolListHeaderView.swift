//
//  SchoolListHeaderView.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import UIKit

class SchoolListHeaderView: UIView {
    let button: UIButton
    let title: UILabel
    init() {
        self.button = UIButton(type: .custom)
        let label = UILabel()
        self.title = label
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)

        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.text = "NYC Schools"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let image = UIImage(systemName: "arrow.up.arrow.down.square", withConfiguration: config)
        button.tintColor = .lightGray
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        button.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
