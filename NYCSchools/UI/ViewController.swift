//
//  ViewController.swift
//  NYCSchools
//
//  Created by M1Pro on 9/30/22.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet var labelStatus: UILabel!
    var isDataLoaded = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isDataLoaded else { return }
        labelStatus.text = "Fetching data about NYC Schools. Please wait..."
        var request: AnyCancellable?
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            request = Schools.shared.fetch()
                .sink { [weak self] result in
                    switch result {
                    case .finished:
                        self?.isDataLoaded = true
                        self?.presentSchools()
                    case .failure(let e):
                        self?.labelStatus.text = "Failed to fetch and store data.\n\(e.localizedDescription)"
                    }
                    request = nil
                } receiveValue: { _ in
                }
        }
    }
    
    func presentSchools() {
        func display() {
            let vc = SchoolsListViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        DispatchQueue.executeInMain {
            display()
        }
    }
}

