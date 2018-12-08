//
//  DatabaseService.swift
//  github reps
//
//  Created by Vadim Patalakh on 12/7/18.
//  Copyright © 2018 Vadim Patalakh. All rights reserved.
//

import Foundation

let fetchLimit = 30

class DatabaseService {
    private let privateContext = NSManagedObjectContext.mr_()
    weak var fetchDelegate: NSFetchedResultsControllerDelegate?

    func cache(_ repos: [[AnyHashable: Any]], _ completion: @escaping (Bool, [Repository]?) -> Void) {
        DispatchQueue.global().async {
            guard let repos = Repository.mr_import(from: repos, in: self.privateContext) as? [Repository] else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(true, repos)
            }
        }

    }

    func getCache(withName name: String) -> [Repository]? {
        let fetchRequest = NSFetchRequest<Repository>(entityName: "Repository")
        let starCountDescriptor = NSSortDescriptor(key: "starCount", ascending: false)
        fetchRequest.sortDescriptors = [starCountDescriptor]
        fetchRequest.fetchLimit = fetchLimit
        let predicate = NSPredicate(format: "(name CONTAINS[cd] %@)", name)
        fetchRequest.predicate = predicate
        let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                         managedObjectContext: privateContext,
                                                         sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchController.performFetch()
            return fetchController.fetchedObjects
        } catch {
            return nil
        }
    }
}
