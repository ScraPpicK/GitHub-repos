//
//  FetchService.swift
//  github reps
//
//  Created by Vadim Patalakh on 12/7/18.
//  Copyright © 2018 Vadim Patalakh. All rights reserved.
//

import Foundation

protocol GetData {
    func getData(_ name: String)
    func setFetchControllerDelegate(_ delegate: NSFetchedResultsControllerDelegate)

    var didGetDataCompletion: (([Repository]) -> Void)? {get set}
}

class FetchService {
    private let databaseService = DatabaseService()
    private let apiService = ApiService()
    private var name = ""

    var didGetDataCompletion: (([Repository]) -> Void)?
}

extension FetchService: GetData {
    func getData(_ name: String) {
        self.name = name
        apiService.delegate = self
        apiService.downloadInfo(name)
    }

    func setFetchControllerDelegate(_ delegate: NSFetchedResultsControllerDelegate) {
        databaseService.fetchDelegate = delegate
    }
}

extension FetchService: DownloadInfoDelegate {
    func didNotDownloadInfo(_ error: ApiError) {
        switch error {
        case .noNetwork:
            if let repos = databaseService.getCache(withName: name) {
                didGetDataCompletion?(repos)
            }

        case .unexpectedError: break
        }
    }

    func didDownloadInfo(_ repos: [[AnyHashable: Any]]) {
        databaseService.cache(repos) { [weak self] (success, repos) in
            if success == true, let repositories = repos {
                self?.didGetDataCompletion?(repositories)
            } else {
                self?.didNotDownloadInfo(.unexpectedError)
            }
        }
    }
}
