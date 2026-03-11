//
//  TopSecCollectionViewCell.swift
//  wellSync
//
//  Created by Pranjal on 11/03/26.
//

import UIKit

class TopSecCollectionViewCell: UICollectionViewCell, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!

    var onSearchTextChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search patients..."

        searchBar.backgroundImage = UIImage()
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        onSearchTextChanged?(searchText)
    }
}
