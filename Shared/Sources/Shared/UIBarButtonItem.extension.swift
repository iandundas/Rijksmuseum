//
//  UIBarButtonItem.extension.swift
//  
//
//  Created by Ian Dundas on 29/03/2023.
//

import UIKit

/// Simply a UIActivityIndicatorView embedded in a UIBarButtonItem
public class ActivityIndicatorBarButtonItem: UIBarButtonItem {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public override init() {
        super.init()
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    private func configureView() {
        activityIndicator.startAnimating()
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: activityIndicator.bounds.width, height: activityIndicator.bounds.height))
        containerView.addSubview(activityIndicator)
        activityIndicator.constrainToEdges(ofContainingView: containerView)
        customView = containerView
    }
}
