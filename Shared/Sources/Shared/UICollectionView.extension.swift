//
//  File.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import UIKit

extension UICollectionView.CellRegistration {
    
    /// Wraps `collectionView.dequeueConfiguredReusableCell`
    public var cellProvider: (UICollectionView, IndexPath, Item) -> Cell {
        return { collectionView, indexPath, product in
            collectionView.dequeueConfiguredReusableCell(
                using: self,
                for: indexPath,
                item: product
            )
        }
    }
}
