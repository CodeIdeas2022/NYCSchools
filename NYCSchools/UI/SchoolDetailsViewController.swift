//
//  SchoolDetailsViewController.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import UIKit

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
    let schoolDetails: SchoolDetails
    
    init(schoolDetails: SchoolDetails) {
        self.schoolDetails = schoolDetails
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupLayout()
        setupData()
    }
    
    
    func addSubViews() {
        view.addSubview(labelTitle)
        view.addSubview(labelDetails)
    }
    
    func setupData() {
        labelTitle.text = "\(schoolDetails.name)"
        labelDetails.text = schoolDetails.satTakers + " students took the SAT." + "\n\nThe average score for critical reading is " + schoolDetails.satCriticalReadingAverage + ".\n\nThe average score for math is " + schoolDetails.satMathAverage + ".\n\nThe average score for critical writing is " + schoolDetails.satWritingAverage + "."
    }
    
    func setupLayout() {
        labelTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        labelTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        labelTitle.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: 0).isActive = true
        labelTitle.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        labelDetails.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        labelDetails.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -20).isActive = true
        labelDetails.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 20).isActive = true
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
