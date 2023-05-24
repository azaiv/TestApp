//
//  TranslationCell.swift
//  absolute
//
//  Created by aiv on 21.05.2023.
//

import UIKit

class TranslationCell: UICollectionViewCell {

    let textView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            textView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
 
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 15)
        textView.textContainerInset = .init(top: 15, left: 0, bottom: 15, right: 0)

        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getData() -> String? {
        return textView.text
    }
}

