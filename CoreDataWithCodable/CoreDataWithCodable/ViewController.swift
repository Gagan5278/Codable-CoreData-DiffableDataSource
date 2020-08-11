//
//  ViewController.swift
//  CoreDataWithCodable
//
//  Created by Gagan  Vishal on 8/10/20.
//

import UIKit
import Combine
class ViewController: UIViewController{
    var diffableDataSource: UICollectionViewDiffableDataSource<Section, UserViewModel>! = nil
    var snapshot: NSDiffableDataSourceSnapshot<Section, UserViewModel>! = nil
    private let footeridentifier = "footer_identifier"
    //controller object
    let userController = UserController()
    //
    var cacellable: AnyCancellable?
    //CollectionView
    var collectionView: UICollectionView! = nil
    //MARK:- View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "All Users"
        //1.Bind
        self.bind()
        //2. Add collectionView
        self.setupCollectionView()
        //3.
        self.createDataSource()
        //4.
        self.createAndApplySnapshot()
        //5.
        self.userController.fetchItems(at: 0)
    }

    //MARK:- Bind for singal
    fileprivate func bind() {
        self.cacellable = userController.passthroughSubecjtForFetchReload.sink { [weak self](isReload) in
            if isReload {
                self?.createAndApplySnapshot()
            }
        }
    }
    
    //MARK:- Setup collectionView
    fileprivate func setupCollectionView() {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        self.view.addSubview(self.collectionView)
        self.collectionView.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        self.collectionView.delegate = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    //MARK:- Create collectionView Layout
    fileprivate func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (indx, environment) -> NSCollectionLayoutSection? in
            let configuration = UICollectionLayoutListConfiguration.init(appearance: .plain)
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0.0, bottom: 44.0, trailing: 0.0)
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(44)),
                elementKind: self.footeridentifier,
                alignment: .bottom)
            sectionFooter.pinToVisibleBounds = true
            sectionFooter.zIndex = 2
            section.boundarySupplementaryItems = [sectionFooter]
            return section
        }

    }
    
    //MARK:- Create Data Source
    fileprivate func createDataSource() {
        //1.
        let cell = UICollectionView.CellRegistration<CollectionViewListCell, UserViewModel> { (cell, indexPath, user) in
            cell.update(for: user)
        }
        
        let footerView = UICollectionView.SupplementaryRegistration<CollectionFooterView>(elementKind: self.footeridentifier) { (footer, kind, indexPath) in
            footer.backgroundColor = .blue
        }
        
        //2.
        self.diffableDataSource = UICollectionViewDiffableDataSource<Section, UserViewModel>(collectionView: self.collectionView, cellProvider: { (clView, indexPath, user) -> UICollectionViewCell? in
            self.userController.fetchItems(at: indexPath.row)
            return clView.dequeueConfiguredReusableCell(using: cell, for: indexPath, item: user)
        })
        //3.
        self.diffableDataSource.supplementaryViewProvider = { (footer, kind, indexPath) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: footerView, for: indexPath)
        }
    }
    
    //MARK:- Create and Apply Snapshot
    fileprivate func createAndApplySnapshot() {
        //1.
        self.snapshot = NSDiffableDataSourceSnapshot<Section, UserViewModel>()
        //2.
        self.snapshot.appendSections([.main])
        //3.
        self.snapshot.appendItems(self.userController.items)
        //4.
        self.diffableDataSource.apply(self.snapshot)
    }
}


extension ViewController {
    enum Section {
        case main
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
