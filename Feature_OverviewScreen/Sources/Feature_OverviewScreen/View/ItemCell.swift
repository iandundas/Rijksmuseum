//
//  ItemCell.swift
//  Rijksmuseum
//
//  Created by Ian Dundas on 27/03/2023.
//  Copyright © 2023 Solid Red Systems B.V. All rights reserved.
//

import UIKit
import Kingfisher

internal final class ItemCell: UICollectionViewCell {
    
    private let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        setupConstraints()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        name = ""
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
    }

    private func setupConstraints() {
        imageView.constrainToEdges(ofContainingView: contentView)
        
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    var name: String = "" {
        didSet {
            label.text = name
        }
    }
    
    var imageURL: URL? {
        didSet {
            guard let imageURL else { return }
            
            // Pipeline to downsample the image (for smoother scrolling):
            let processor = DownsamplingImageProcessor(size: CGSize(width: 100, height: 100)) // TODO: don't hardcode size here
            
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageURL, placeholder: nil, options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
            ]) { [weak imageView] result in
                
                // If it fails, show a 􀃰 image to indicate it failed.
                if case .failure(let error) = result {
                    print("Image load failed: \(error.localizedDescription)")
                    imageView?.image = UIImage(systemName: "xmark.square")
                }
            }
        }
    }    
}
