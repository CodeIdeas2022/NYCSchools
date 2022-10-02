//
//  SchoolsListViewController.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import UIKit
import Combine

class SchoolsListViewController: UIViewController {
    var sort: Sort = .bestGraduationRate
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .lightGray
        table.allowsMultipleSelection = false
        return table
    }()
    
    var schools: [School] = []
    
    lazy var sortView: SchoolListHeaderView = {
        let headerView = SchoolListHeaderView()
        headerView.button.addTarget(self, action: #selector(sortButtonTapped(_:)), for: .touchUpInside)
        return headerView
    }()
    
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
        view.addSubview(sortView)
    }
    
    func setupLayout() {
        sortView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        sortView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        sortView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        sortView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: sortView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    func setupSources() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MySchoolCell.self, forCellReuseIdentifier: MySchoolCell.id)
        refreshSort()
    }
    
    func refreshSort(_ reload: Bool = true) {
        switch sort {
        case .bestGraduationRate:
            schools = Schools.shared.bestGraduationRate()
        case .worstGraduationRate:
            schools = Schools.shared.worsttGraduationRate()
        case .mostNumberOfStudents:
            schools = Schools.shared.mostNumberOfStudents()
        case .leastNumberOfStudents:
            schools = Schools.shared.leastNumberOfStudents()
        }
        sortView.title.text = "NYC Schools - \(schools.count) students" + "\n\(sort.displayString)"
        if reload {
            tableView.reloadData()
            if schools.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
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

extension SchoolsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let school = schools[indexPath.row]
        var cancellable: AnyCancellable?
        cancellable = school.fetchDetails()
            .sink { result in
                cancellable = nil
            } receiveValue: { [weak self] details in
                guard let details = details else {
                    return
                }
                print(details)
                DispatchQueue.executeInMain {
                    guard let self = self else { return }
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    let vc = SchoolDetailsViewController(schoolDetails: details)
                    guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
                    vc.presentAsPopover(self, sourceView: cell)
                }
            }
    }
}

extension SchoolsListViewController {
    @objc func sortButtonTapped(_ sender: Any) {
        let vc = StringListViewController(Sort.all.map({ $0.displayString }))
        vc.presentAsPopover(self, sourceView: sender as! UIView) { [weak self] item in
            guard let value = Sort.withDisplayString(item) else { return false }
            defer {
                self?.sort = value
                self?.refreshSort()
            }
            return true
        }
    }
}

extension SchoolsListViewController {
    enum Sort {
        case bestGraduationRate
        case worstGraduationRate
        case mostNumberOfStudents
        case leastNumberOfStudents
        
        var displayString: String {
            switch self {
            case .bestGraduationRate:
                return "Top Graduation Rate"
            case .worstGraduationRate:
                return "Bottom Graduation Rate"
            case .mostNumberOfStudents:
                return "Most Number Of Students"
            case .leastNumberOfStudents:
                return "Least Number Of Students"
            }
        }
        static let all: [Sort] = [.bestGraduationRate, .worstGraduationRate, .mostNumberOfStudents, .leastNumberOfStudents]
        
        static func withDisplayString(_ string: String) -> Sort? {
            for value in all {
                if value.displayString == string {
                    return value
                }
            }
            return nil // not found
        }
    }
}

extension UIView {
    func  setBorderColor(_ color: UIColor, width: CGFloat = 1.0) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}

