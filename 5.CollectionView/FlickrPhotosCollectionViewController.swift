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
    private var selectedPhotos: [FlickrPhoto] = []
    private let shareLabel = UILabel()
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(
        top: 50.0,
        left: 20.0,
        bottom: 50.0,
        right: 20.0
    )
    
    var largePhotoIndexPath: IndexPath? {
        didSet {
            var indexPaths: [IndexPath] = []
            if let largePhotoIndexPath = largePhotoIndexPath {
                indexPaths.append(largePhotoIndexPath)
            }
            
            if let oldValue = oldValue {
                indexPaths.append(oldValue)
            }
            collectionView.performBatchUpdates({
                self.collectionView.reloadItems(at: indexPaths)
            }) { _ in
                if let largePhotoIndexPath = self.largePhotoIndexPath {
                    self.collectionView.scrollToItem(
                        at: largePhotoIndexPath,
                        at: .centeredVertically,
                        animated: true
                    )
                }
            }
        }
    }
    
    var sharing: Bool = false {
        didSet {
            collectionView.allowsMultipleSelection = sharing
            
            collectionView.selectItem(at: nil, animated: true, scrollPosition: [])
            selectedPhotos.removeAll()
            
            guard let shareButton = self.navigationItem.rightBarButtonItems?.first else {
                return
            }
            
            guard sharing else {
                navigationItem.setRightBarButton(shareButton, animated: true)
                return
            }
            
            if largePhotoIndexPath != nil {
                largePhotoIndexPath = nil
            }
            
            updateSharedPhotoCountLabel()
            
            let sharingItem = UIBarButtonItem(customView: shareLabel)
            let items: [UIBarButtonItem] = [
                shareButton,
                sharingItem
            ]
            
            navigationItem.setRightBarButtonItems(items, animated: true)
        }
    }
    
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
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))
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
    
    @objc func share(sender: UIBarButtonItem) {
        guard !searches.isEmpty else {
            return
        }
        
        guard !selectedPhotos.isEmpty else {
            sharing.toggle()
            return
        }
        
        guard sharing else {
            return
        }
        
        let images: [UIImage] = selectedPhotos.compactMap { photo in
            if let thumbnail = photo.thumbnail {
                return thumbnail
            }
            
            return nil
        }
        
        guard !images.isEmpty else {
            return
        }
        
        let shareController = UIActivityViewController(
            activityItems: images,
            applicationActivities: nil)
        shareController.completionWithItemsHandler = { _, _, _, _ in
            self.sharing = false
            self.selectedPhotos.removeAll()
            self.updateSharedPhotoCountLabel()
        }
        
        shareController.popoverPresentationController?.barButtonItem = sender
        shareController.popoverPresentationController?.permittedArrowDirections = .any
        present(shareController, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return searches.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return searches[section].searchResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)as! FlickrPhotoCell
        let flickrPhoto = photo(for: indexPath)
        cell.backgroundColor = .white
        cell.imageView.image = flickrPhoto.thumbnail
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: headerIdentifier,
                    for: indexPath) as? FlickrPhotoHeaderView
                else {
                    fatalError("Invalid view type")
            }
            
            let searchTerm = searches[indexPath.section].searchTerm
            headerView.label.text = searchTerm
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard !sharing else {
            return true
        }
        
        if largePhotoIndexPath == indexPath {
            largePhotoIndexPath = nil
        } else {
            largePhotoIndexPath = indexPath
        }
        
        return false
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        guard sharing else {
            return
        }
        
        let flickrPhoto = photo(for: indexPath)
        selectedPhotos.append(flickrPhoto)
        updateSharedPhotoCountLabel()
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 didDeselectItemAt indexPath: IndexPath) {
        guard sharing else {
            return
        }
        
        let flickrPhoto = photo(for: indexPath)
        if let index = selectedPhotos.firstIndex(of: flickrPhoto) {
            selectedPhotos.remove(at: index)
            updateSharedPhotoCountLabel()
        }
    }
    
}

// MARK: - Private
private extension FlickrPhotosCollectionViewController {
    func photo(for indexPath: IndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
    func updateSharedPhotoCountLabel() {
        if sharing {
            shareLabel.text = "\(selectedPhotos.count) photos selected"
        } else {
            shareLabel.text = ""
        }
        
        shareLabel.textColor = view.tintColor
        
        UIView.animate(withDuration: 0.3) {
            self.shareLabel.sizeToFit()
        }
    }
}

extension FlickrPhotosCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        flickr.searchFlickr(for: textField.text!) { searchResults in
            activityIndicator.removeFromSuperview()
            
            switch searchResults {
            case .error(let error) :
                print("Error Searching: \(error)")
            case .results(let results):
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.insert(results, at: 0)
                self.collectionView?.reloadData()
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

extension FlickrPhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath == largePhotoIndexPath {
            let flickrPhoto = photo(for: indexPath)
            var size = collectionView.bounds.size
            size.height -= (sectionInsets.top + sectionInsets.bottom)
            size.width -= (sectionInsets.left + sectionInsets.right)
            return flickrPhoto.sizeToFillWidth(of: size)
        }
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
