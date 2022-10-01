//
//  SchoolsListViewController.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import UIKit

class SchoolsListViewController: UIViewController {
    var sort: Sort = .bestGraduationRate
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    var schools: [SchoolInfo] = []
    
    required init?(coder: NSCoder) {
        fatalError("IB not supported")
    }
    
    init() {
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
        refreshSort()
        tableView.dataSource = self
        tableView.register(MySchoolCell.self, forCellReuseIdentifier: MySchoolCell.id)
        tableView.reloadData()
    }
    
    func refreshSort() {
        switch sort {
        case .bestGraduationRate:
            schools = Schools.shared.bestGraduationRate()
        case .worstGraduationRate:
            schools = Schools.shared.worsttGraduationRate()
        }
    }
}

extension SchoolsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MySchoolCell.id, for: indexPath) as! MySchoolCell
        cell.fillData(schools[indexPath.row], highlightField: sort)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
}

extension SchoolsListViewController {
    enum Sort {
        case bestGraduationRate
        case worstGraduationRate
    }
}

class MySchoolCell: UITableViewCell {
    static let id = "cell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.textLabel?.numberOfLines = 0
        self.textLabel?.lineBreakMode = .byWordWrapping
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fillData(_ school: SchoolInfo, highlightField: SchoolsListViewController.Sort) {
        textLabel?.text = school.name
        var detail: [String] = [school.dbn ?? ""]
        switch highlightField {
        case .bestGraduationRate, .worstGraduationRate:
            if let rateString = school.graduationRate, let rate = Float(rateString) {
                detail.append("\(rate * 100.0)%")
            }
            
            
        }
        detailTextLabel?.text = detail.joined(separator: ", ")
    }
}
