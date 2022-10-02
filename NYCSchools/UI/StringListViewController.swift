//
//  AnyListViewController.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import UIKit

class StringListViewController: UIViewController {
    typealias ItemSelectedHandler = (_ item: String) -> Bool
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let items: [String]
    var itemSelectedHandler: ItemSelectedHandler?
    
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: UIView.noIntrinsicMetric , height: (CGFloat(items.count) * Constants.tableViewCellHeight))
        }
        set {
            super.preferredContentSize = newValue
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("IB not supported")
    }
    
    init(_ items: [String]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupLayout()
        setupSources()
    }
    

    func addSubViews() {
        view.addSubview(tableView)
    }
        
    func setupLayout() {
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    func setupSources() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.reloadData()
    }
    
    func presentAsPopover(_ parent: UIViewController, sourceView: UIView, _ completion: @escaping ItemSelectedHandler) {
        itemSelectedHandler = completion
        modalPresentationStyle = .popover
        if let pres = presentationController {
            pres.delegate = self
        }
        if let popover = popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
            popover.permittedArrowDirections = [.up]
        }
        parent.present(self, animated: true)
    }
}

extension StringListViewController {
    struct Constants {
        static let tableViewCellHeight = 50.0
    }
}

extension StringListViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}


extension StringListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.contentView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        return cell
    }
}

extension StringListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemSelectedHandler?(items[indexPath.row]) == true {
            dismiss(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.tableViewCellHeight
    }
}
