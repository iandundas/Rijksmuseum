//
//  UICollectionView.extension.swift
//
//
//  Created by Ian Dundas on 28/03/2023.
//

import UIKit

extension UIView {
    
    /// Anchors four borders of self to the borders of containing view
    public func constrainToEdges(ofContainingView view: UIView, padding: CGFloat = 0) {
        topAnchor.constraint(equalTo: view.topAnchor, constant: padding).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding).isActive = true
    }
    
    /// Centers self within the given view
    public func centerWithin(containingView view: UIView) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

