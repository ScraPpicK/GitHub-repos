//
//  RepoListViewModel.swift
//  github reps
//
//  Created by Vadim Patalakh on 12/6/18.
//  Copyright © 2018 Vadim Patalakh. All rights reserved.
//

protocol RepoListViewModelContentUpdates: class {
    func updateList()

    func willBeginUpdates()
    func didChangeObject(atIndexPath indexPath: IndexPath)
    func didChangeSection(atIndexPath indexPath: IndexPath)
    func didEndUpdates()
}

extension RepoListViewModelContentUpdates {
    func willBeginUpdates() { }
    func didChangeObject(atIndexPath indexPath: IndexPath) { }
    func didChangeSection(atIndexPath indexPath: IndexPath) { }
    func didEndUpdates() { }
}

class RepoListViewModel: NSObject {

    weak var delegate: RepoListViewModelContentUpdates?

    let fetchService = FetchService()

    private var cellViewModels = [RepoCellViewModel]()
    func getCellViewModel(atIndexPath indexPath: IndexPath) -> RepoCellViewModel {
        return cellViewModels[indexPath.row]
    }

    func getNumberOfCells() -> Int {
        return cellViewModels.count
    }

    func getNumberOfSections() -> Int {
        return 1
    }

    private func createCellViewModel(_ repository: Repository) -> RepoCellViewModel? {
        guard let name = repository.name else {
            return nil
        }

        return RepoCellViewModel(name: String(name.prefix(30)), starCount: repository.starCount)
    }

    private func newCellViewModel(withRepos repos: [Repository]) {
        self.cellViewModels.removeAll()
        for repo in repos {
            if let repo = self.createCellViewModel(repo) {
                self.cellViewModels.append(repo)
            }
        }
    }

    func initFetch(_ name: String) {
        self.fetchService.didGetDataCompletion = { [weak self] (repos) in
            self?.newCellViewModel(withRepos: repos)
            self?.delegate?.updateList()
        }

        self.fetchService.setFetchControllerDelegate(self)
        self.fetchService.getData(name)
    }
}

extension RepoListViewModel: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.willBeginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.didEndUpdates()
    }
}

struct RepoCellViewModel {
    let name: String
    let starCount: Int64
}
