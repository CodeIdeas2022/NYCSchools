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
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func loadData() {
        labelStatus.text = "Fetching data about NYC Schools. Please wait..."
        var cancellable: AnyCancellable?
        cancellable = NetworkSession.shared.sessionStatus
            .sink { _ in
                cancellable = nil
            } receiveValue: { [weak self] isInternetAvailable in
                DispatchQueue.executeInMain {
                    if isInternetAvailable {
                        self?.labelStatus.text = "Fetching data about NYC Schools.\nPlease wait.."
                    } else {
                        self?.labelStatus.text = "Waiting for internet connection..."
                    }
                }
            }

        var request: AnyCancellable?
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            request = Schools.shared.fetch()
                .sink { [weak self] result in
                    let retry: Bool
                    switch result {
                    case .finished:
                        retry = false
                        self?.presentSchools()
                    case .failure(let e):
                        self?.labelStatus.text = "Failed to fetch and store data.\n\(e.localizedDescription)"
                        retry = true
                    }
                    request = nil
                    cancellable?.cancel()
                    if retry {
                        self?.loadData() // Try again
                    }
                } receiveValue: { _ in
                }
        }
    }
    func presentSchools() {
        func display() {
            guard let window = UIApplication.shared.keyWindow else { return }
            let vc = SchoolsListViewController()
            window.rootViewController = vc
        }
        DispatchQueue.executeInMain {
            display()
        }
    }
}

