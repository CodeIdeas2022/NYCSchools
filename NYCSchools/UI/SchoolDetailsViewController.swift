//
//  SchoolDetailsViewController.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import UIKit
import Combine

class SchoolDetailsViewController: UIViewController {
    lazy var labelTitle: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.backgroundColor = .black
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var titleContainerView: UIView = {
       let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .black
        v.addSubview(labelTitle)
        labelTitle.topAnchor.constraint(equalTo: v.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        labelTitle.centerXAnchor.constraint(equalTo: v.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        labelTitle.widthAnchor.constraint(equalTo: v.safeAreaLayoutGuide.widthAnchor, constant: 0).isActive = true
        labelTitle.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
        return v
    }()
    lazy var labelDetails: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
       
    required init?(coder: NSCoder) {
        fatalError("IB not supported")
    }
    let school: School
    
    init(school: School) {
        self.school = school
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupLayout()
        setupData()
    }
    
    
    func addSubViews() {
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.addSubview(titleContainerView)
        view.addSubview(labelDetails)
    }
    
    func setupData() {
        labelTitle.text = "\(school.name)"
        labelDetails.text = "Fetching details for school. Please wait.."
        var cancellable: AnyCancellable?
        cancellable = school.fetchDetails()
            .sink { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.displayNoData(error)
                default: break
                }
                cancellable = nil
            } receiveValue: { [weak self] schoolDetails in
                guard let self = self else { return }
                guard let schoolDetails = schoolDetails else {
                    self.displayNoData(nil)
                    return
                }
                DispatchQueue.executeInMain {
                    self.labelDetails.text = schoolDetails.satTakers + " students took the SAT." + "\n\nThe average score for critical reading is " + schoolDetails.satCriticalReadingAverage + ".\n\nThe average score for math is " + schoolDetails.satMathAverage + ".\n\nThe average score for critical writing is " + schoolDetails.satWritingAverage + "."
                }
            }
    }
    
    func displayNoData(_ error: Error?) {
        DispatchQueue.executeInMain { [weak self] in
            self?.labelDetails.textAlignment = .center
            self?.labelDetails.text = "Details not available for school." + ( error == nil ? "" : "\nError:\(error!.localizedDescription)")
        }
    }
    
    func setupLayout() {
        titleContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        titleContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        titleContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        labelDetails.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        labelDetails.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -20).isActive = true
        labelDetails.topAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 20).isActive = true
    }
    
    func presentAsPopover(_ parent: UIViewController, sourceView: UIView) {
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

extension SchoolDetailsViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
