//
//  ApiService.swift
//  github reps
//
//  Created by Vadim Patalakh on 12/6/18.
//  Copyright © 2018 Vadim Patalakh. All rights reserved.
//

import Foundation

protocol DownloadInfoDelegate: class {
    func didNotDownloadInfo(_ error: ApiError)
    func didDownloadInfo(_ repos: [[AnyHashable: Any]])
}

enum ApiError: String, Error {
    case unexpectedError = "Unexpected error"
    case noNetwork = "No network"
}

class ApiService {
    fileprivate let maxOperationCount = 2
    fileprivate let maxResultCount = 15
    fileprivate let apiUrl = "https://api.github.com/search/repositories?q="
    private let dispatchGroup = DispatchGroup()
    private var results = [[AnyHashable: Any]]()

    weak var delegate: DownloadInfoDelegate?

    func downloadInfo(_ name: String) {
        if !Reachability.isConnectedToNetwork() {
            self.delegate?.didNotDownloadInfo(.noNetwork)
            return
        }

        DispatchQueue.global().async {
            var index = 0
            while index < self.maxOperationCount {
                self.createOperation(requestName: name, index)
                index += 1
            }

            if self.dispatchGroup.wait(timeout: .now() + 5) == .success {
                DispatchQueue.main.async {
                    self.delegate?.didDownloadInfo(self.results)
                    self.results = [[AnyHashable: Any]()]
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.didNotDownloadInfo(.noNetwork)
                }
            }
        }
    }

    private func createOperation(requestName name: String, _ index: Int) {
        dispatchGroup.enter()
//        uncomment to simulate long operation
//        sleep(3)
        downloadData(requestName: name, index) { () in
            dispatchGroup.leave()
        }
    }

    private func downloadData(requestName name: String, _ index: Int, _ completion: () -> Void) {
        let downloadUrl = apiUrl.appendingFormat("%@&page=%d&per_page=%d", name, index + 1, maxResultCount)
        guard let url = URL(string: downloadUrl) else {
            completion()
            return
        }

        do {
            let data = try Data(contentsOf: url, options: [])
            guard let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let parsedData = jsonData["items"] as? [[AnyHashable: Any]] else {
                return
            }

            objc_sync_enter(self.results)
            self.results.append(contentsOf: parsedData)
            objc_sync_exit(self.results)

            completion()
        } catch {
        }
    }
}
