//
//  OverviewItemCell.swift
// 
//  Created by Ian Dundas on 27/03/2023.
//  Copyright © 2023 Solid Red Systems B.V. All rights reserved.
//

import UIKit

internal final class DetailCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    private let accessoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right.circle"), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 4
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(accessoryButton)
        contentView.addSubview(stackView)

        setupConstraints()

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        
        accessoryButton.addTarget(self, action: #selector(userDidTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        accessoryButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 12).isActive = true
        accessoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        accessoryButton.setContentHuggingPriority(.required, for: .horizontal)
        
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title = ""
        value = ""
        didTapButtonCallback = nil
    }
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var value: String = "" {
        didSet {
            valueLabel.text = value
        }
    }
    
    @objc func userDidTapButton() {
        didTapButtonCallback?()
    }
    
    var didTapButtonCallback: (() -> Void)? {
        didSet {
            accessoryButton.isEnabled = didTapButtonCallback != nil
        }
    }
}
