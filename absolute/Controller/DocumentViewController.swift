//
//  DocumentViewController.swift
//  absolute
//
//  Created by aiv on 21.05.2023.
//

import Foundation
import UIKit

class DocumentViewController: UIViewController {
    
    var document: UIDocument?
    var wordsArray: [String] = []
    var sourceArray: [String] = []
    var targetArray: [String] = []
    var translations: [Translation] = []
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = .init(title: "Open", style: .plain, target: self, action: #selector(open))
        navigationItem.rightBarButtonItem = .init(title: "Save", style: .done, target: self, action: #selector(save))
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.register(TranslationCell.self, forCellWithReuseIdentifier: "TranslationCell")
        view.addSubview(collectionView)
        
        configureDataSource()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open(completionHandler: { [self] (success) in
            if success {
                let document = self.document?.fileURL
                do {
                    guard let translations = XLIFFParser.parse(fileURL: document!) else {
                        fatalError("Failed to parse XLIFF file")
                    }
                    
                    for source in translations {
                        wordsArray.append(source.source)
                        wordsArray.append(source.target)
                    }
                    
                    DispatchQueue.main.async {
                        self.applySnapshot()
                    }
                    
                } catch {
                    print("Ошибка чтения файла: \(error)")
                }
            } else {
            }
        })
    }
    
    @objc func open() {
        self.dismiss(animated: true)
    }
    
    @objc func save() {
        guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("edited.xliff").path else { return }
        saveFile(with: getData(), filePath: filePath)
    }
    
    func getData() -> [Translation] {
        sourceArray = []

        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? TranslationCell {
                if let cellData = cell.getData() {
                    if indexPath.row % 2 == 0 {
                       sourceArray.append(cellData)
                    } else {
                        targetArray.append(cellData)
                    }
                }
            }
        }
        
        for i in 0...sourceArray.count - 1 {
            self.translations.append(.init(id: "\(i)", source: sourceArray[i], target: targetArray[i]))
        }
        
        return translations
    }
}

private extension DocumentViewController {
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(0.5),
                                                     heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(50))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitem: item,
                                                     count: 2)

        let section = NSCollectionLayoutSection(group: group)
        
        let layout: UICollectionViewCompositionalLayout = .init(section: section)
        return layout
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { [self]
            (collectionView: UICollectionView, indexPath: IndexPath, value: String) -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TranslationCell", for: indexPath) as! TranslationCell
            cell.textView.text = self.wordsArray[indexPath.row]
            return cell
        }
    }

    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()

        snapshot.appendSections([0])
        snapshot.appendItems(wordsArray, toSection: 0)

        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
