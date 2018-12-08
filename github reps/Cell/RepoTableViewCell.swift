//
//  RepoTableViewCell.swift
//  github reps
//
//  Created by Vadim Patalakh on 12/8/18.
//  Copyright © 2018 Vadim Patalakh. All rights reserved.
//

import Foundation

protocol Reusable {
    static func reuseIdentifier() -> String
    static func nibName() -> String
}

extension Reusable {
    static func reuseIdentifier() -> String {
        return String(describing: self)
    }

    static func nibName() -> String {
        return String(describing: self)
    }
}

class RepoTableViewCell: UITableViewCell, Reusable {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var starCountLabel: UILabel!

    func setNameText(_ text: String) {
        nameLabel.text = text
    }

    func setStarsCount(_ starsCount: Int64) {
        starCountLabel.text = String(format: "Stars count = %d", starsCount)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        starCountLabel.text = ""
    }
}
