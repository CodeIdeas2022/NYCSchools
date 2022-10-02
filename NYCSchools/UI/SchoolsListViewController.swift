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
    var searchResults: [School] = []
    var isSearching = false
    var constraintShowSearchBar: NSLayoutConstraint?
    var constraintHideSearchBar: NSLayoutConstraint?
    lazy var keyboardDismissView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        let gesture = UITapGestureRecognizer(target: self, action: #selector(removeSearchKeyBoard))
        v.addGestureRecognizer(gesture)
        return v
    }()
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
        headerView.sortButton.addTarget(self, action: #selector(sortButtonTapped(_:)), for: .touchUpInside)
        headerView.searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        return headerView
    }()
    
    lazy var searchBar: UISearchBar = {
       let s = UISearchBar()
        s.placeholder = "All fields search"
        s.translatesAutoresizingMaskIntoConstraints = false
        s.showsCancelButton = true
        s.returnKeyType = .default
        return s
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
        view.addSubview(searchBar)
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
        
        constraintHideSearchBar = searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -100)
        constraintShowSearchBar = searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)

        constraintHideSearchBar?.isActive = true
        constraintShowSearchBar?.isActive = false
        
        searchBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupSources() {
        searchBar.delegate = self
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
        case .topSATReading:
            schools = Schools.shared.satReadingRank()
        case .topSATWriting:
            schools = Schools.shared.satWritingRank()
        case .topSATMath:
            schools = Schools.shared.satMathRank()
        case .bottomSATReading:
            schools = Schools.shared.satReadingRank(false)
        case .bottomSATWriting:
            schools = Schools.shared.satWritingRank(false)
        case .bottomSATMath:
            schools = Schools.shared.satMathRank(false)
        }
        sortView.title.text = "NYC Schools - \(schools.count) schools"
        sortView.sortType.text = sort.displayString
        if reload {
            refreshData()
        }
    }
    
    var currentSchools: [School] {
        return isSearching ? searchResults : schools
    }
}

extension SchoolsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MySchoolCell.id, for: indexPath) as! MySchoolCell
        cell.fillData(currentSchools[indexPath.row], highlightField: sort)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSchools.count
    }
}

extension SchoolsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let school = currentSchools[indexPath.row]
        
        guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        let vc = SchoolDetailsViewController(school: school)
        vc.presentAsPopover(self, sourceView: cell)
    }
}

extension SchoolsListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        removeSearchKeyBoard()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResults = schools
            refreshData()
            return
        }
        search(searchText)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearch()
    }
}

extension SchoolsListViewController {
    func endSearch() {
        removeSearchKeyBoard()
        isSearching = false
        searchResults = []
        searchBar.searchTextField.text = nil
        constraintShowSearchBar?.isActive = false
        constraintHideSearchBar?.isActive = true
        refreshSort()
    }
    
    func showSearch() {
        isSearching = true
        constraintHideSearchBar?.isActive = false
        constraintShowSearchBar?.isActive = true
        addSearchKeyBoardDismissView()
        searchBar.becomeFirstResponder()
    }
    
    func addSearchKeyBoardDismissView() {
        view.addSubview(keyboardDismissView)
        keyboardDismissView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        keyboardDismissView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        keyboardDismissView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        keyboardDismissView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    @objc func removeSearchKeyBoard() {
        searchBar.resignFirstResponder()
        keyboardDismissView.removeFromSuperview()
    }
    
    func search(_ searchText: String) {
        var cancellable: AnyCancellable?
        cancellable = Schools.shared.searchSchools(schools, string: searchText)
            .sink { _ in
                cancellable = nil
            } receiveValue: { schools in
                DispatchQueue.executeInMain { [weak self] in
                    self?.searchResults = schools
                    self?.refreshData()
                }
            }
    }
    
    func refreshData() {
        tableView.reloadData()
        if currentSchools.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
    
    @objc func searchButtonTapped(_ sender: Any) {
        showSearch()
    }
    
    @objc func dismissSearch() {
        
    }
}

extension SchoolsListViewController {
    enum Sort {
        case bestGraduationRate
        case worstGraduationRate
        case mostNumberOfStudents
        case leastNumberOfStudents
        case topSATReading
        case topSATWriting
        case topSATMath
        case bottomSATReading
        case bottomSATWriting
        case bottomSATMath
        
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
            case .topSATMath:
                return "Top SAT Math Rank"
            case .topSATReading:
                return "Top SAT Reading Rank"
            case .topSATWriting:
                return "Top SAT Writing Rank"
            case .bottomSATMath:
                return "Bottom SAT Math Rank"
            case .bottomSATReading:
                return "Bottom SAT Reading Rank"
            case .bottomSATWriting:
                return "Bottom SAT Writing Rank"
            }
        }
        static let all: [Sort] = [.bestGraduationRate, .worstGraduationRate, .mostNumberOfStudents, .leastNumberOfStudents, .topSATReading, .topSATMath, .topSATWriting, bottomSATReading, .bottomSATMath, .bottomSATWriting]
        
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

