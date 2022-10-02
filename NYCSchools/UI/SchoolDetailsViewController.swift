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
        v.addSubview(closeButton)

        closeButton.rightAnchor.constraint(equalTo: v.safeAreaLayoutGuide.rightAnchor, constant: -5).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: v.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        labelTitle.topAnchor.constraint(equalTo: v.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        labelTitle.centerXAnchor.constraint(equalTo: v.safeAreaLayoutGuide.centerXAnchor).isActive = true
        labelTitle.rightAnchor.constraint(lessThanOrEqualTo: closeButton.leftAnchor, constant: -5).isActive = true
        labelTitle.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
        return v
    }()
    lazy var labelDetails: UITextView = {
        let label = UITextView()
        label.isEditable = false
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.dataDetectorTypes = [.phoneNumber, .address, .link]
        return label
    }()
    
    lazy var closeButton: UIButton = {
       let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        let closeImage = UIImage(systemName: "xmark.circle", withConfiguration: config)
        b.setImage(closeImage, for: .normal)
        b.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)
        b.tintColor = .white
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
        
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
        if let schoolDetails = school.details {
            let ranking = Schools.shared.satRankingForSchool(schoolDetails)
            var detailInfo = schoolDetails.satTakers + " students took the SAT." + "\n\nThe average score for critical reading is " + schoolDetails.satCriticalReadingAverage + ".\n\nThe average score for math is " + schoolDetails.satMathAverage + ".\n\nThe average score for critical writing is " + schoolDetails.satWritingAverage + "."
            detailInfo = detailInfo + "\n\nCritical reading rank is \(ranking.reading)/\(ranking.totalSchoolsWithReadingScores)."
            detailInfo = detailInfo + "\n\nCritical math rank is \(ranking.math)/\(ranking.totalSchoolsWithMathScores)."
            detailInfo = detailInfo + "\n\nCritical writing rank is \(ranking.writing)/\(ranking.totalSchoolsWithWritingScores)."
            detailInfo = detailInfo + "\n\nOverview: \(school.overview)"
            labelDetails.text = detailInfo
        } else {
            displayNoData(nil)
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
        titleContainerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        titleContainerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        titleContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        labelDetails.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        labelDetails.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -20).isActive = true
        labelDetails.topAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: 10).isActive = true
        labelDetails.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
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
    
    @objc func closeScreen() {
        self.dismiss(animated: true)
    }
}

extension SchoolDetailsViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
