//
//  SectionHeaderView.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import UIKit

internal final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textColor = .label
        return label
    }()

    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blurView)
        blurView.contentView.addSubview(label)

        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupConstraints() {
        blurView.constrainToEdges(ofContainingView: self)
        label.constrainToEdges(ofContainingView: blurView.contentView, padding: 8)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title = ""
    }
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
}
