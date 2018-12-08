//
//  RepoListViewController.swift
//  github reps
//
//  Created by Vadim Patalakh on 12/6/18.
//  Copyright © 2018 Vadim Patalakh. All rights reserved.
//

import Foundation

class RepoListViewController: UIViewController {

    private let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var reposTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    lazy var viewModel = RepoListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repositories list"
        self.reposTableView.dataSource = self
        let cellNib = UINib(nibName: RepoTableViewCell.nibName(), bundle: nil)
        self.reposTableView.register(cellNib, forCellReuseIdentifier: RepoTableViewCell.reuseIdentifier())
        self.setupSearchController()
        self.viewModel.delegate = self
        self.viewModel.initFetch("tetris")
    }

    func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Name of repository"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

extension RepoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfCells()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RepoTableViewCell.reuseIdentifier()) as? RepoTableViewCell else {
                return UITableViewCell()
        }

        let cellViewModel = viewModel.getCellViewModel(atIndexPath: indexPath)
        cell.setNameText(cellViewModel.name)
        cell.setStarsCount(cellViewModel.starCount)

        return cell
    }
}

extension RepoListViewController: RepoListViewModelContentUpdates {
    func updateList() {
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
            UIView.animate(withDuration: 0.2) {
                self.reposTableView.alpha = 1
            }
        }

        let range = NSRange(location: 0, length: 1)
        let sections = NSIndexSet(indexesIn: range)
        reposTableView.reloadSections(sections as IndexSet, with: .automatic)
    }
}

extension RepoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }

        self.viewModel.initFetch(text)
    }
}
