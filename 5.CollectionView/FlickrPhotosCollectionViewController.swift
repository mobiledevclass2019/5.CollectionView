//
//  FlickrPhotosCollectionViewController.swift
//  5.CollectionView
//
//  Created by 李超逸 on 2019/11/30.
//  Copyright © 2019 李超逸. All rights reserved.
//

import UIKit

private let reuseIdentifier = "FlickrCell"
private let headerIdentifier = "FlickrPhotoHeaderView"

class FlickrPhotosCollectionViewController: UICollectionViewController {
    
    var searchBar: UITextField
    
    private var searches: [FlickrSearchResults] = []
    private let flickr = Flickr()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        searchBar = UITextField()
        super.init(collectionViewLayout: layout)
        
        collectionView.backgroundColor = .white
        
        searchBar.frame = CGRect(origin: .zero, size: CGSize(width: 400, height: 0))
        searchBar.placeholder = "Search"
        searchBar.borderStyle = .line
        searchBar.returnKeyType = .search
        searchBar.clearButtonMode = .always
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: nil)
        navigationItem.rightBarButtonItem = rightButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(FlickrPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(FlickrPhotoHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

// MARK: - Private
private extension FlickrPhotosCollectionViewController {
  func photo(for indexPath: IndexPath) -> FlickrPhoto {
    return searches[indexPath.section].searchResults[indexPath.row]
  }
}

extension FlickrPhotosCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      // 1
      let activityIndicator = UIActivityIndicatorView(style: .gray)
      textField.addSubview(activityIndicator)
      activityIndicator.frame = textField.bounds
      activityIndicator.startAnimating()
      
      flickr.searchFlickr(for: textField.text!) { searchResults in
        activityIndicator.removeFromSuperview()
        
        switch searchResults {
        case .error(let error) :
          // 2
          print("Error Searching: \(error)")
        case .results(let results):
          // 3
          print("Found \(results.searchResults.count) matching \(results.searchTerm)")
          self.searches.insert(results, at: 0)
          // 4
          self.collectionView?.reloadData()
        }
      }
      
      textField.text = nil
      textField.resignFirstResponder()
      return true
    }
}
