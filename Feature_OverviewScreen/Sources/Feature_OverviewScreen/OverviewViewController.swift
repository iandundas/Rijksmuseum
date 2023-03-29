//
//  OverviewViewController.swift
//  
//
//  Created by Ian Dundas on 28/03/2023.
//

import UIKit
import Combine
import Shared

public final class OverviewViewController: UIViewController {
    
    typealias Cell = ItemCell
    typealias CellRegistration = UICollectionView.CellRegistration<Cell, CollectionItem>

    fileprivate let collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 50) / 3, height: (UIScreen.main.bounds.width - 50) / 3) // TODO: improve this
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.sectionHeadersPinToVisibleBounds = true
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate func makeCellRegistration() -> CellRegistration {
        CellRegistration { cell, indexPath, item in
            cell.name = item.name
            cell.imageURL = item.imageURL
        }
    }
    
    fileprivate lazy var datasource: UICollectionViewDiffableDataSource<Section, CollectionItem> = {
        let datasource = UICollectionViewDiffableDataSource<Section, CollectionItem>(
            collectionView: collectionView,
            cellProvider: makeCellRegistration().cellProvider
        )
        
        datasource.supplementaryViewProvider = { [unowned datasource] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as! SectionHeaderView

            let section = datasource.snapshot().sectionIdentifiers[indexPath.section]
            
            headerView.title = section.name
            
            return headerView
        }
        
        return datasource
    }()

    fileprivate let viewModel: OverviewViewModel
    
    private var lastLoadedCancellable: AnyCancellable? // holds a reference to the `viewModel.itemUpdates` cancellable
    private var errorAlertsCancellable: AnyCancellable? // holds a reference to the `viewModel.errorAlerts` cancellable
    private var isLoadingCancellable: AnyCancellable? // holds a reference to the `viewModel.isLoading` cancellable
    
    public init(viewModel: OverviewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        
        setupCollectionView()
        setupBindings()
        setupSearchController()
    }
    
    private func setupBindings() {
        
        lastLoadedCancellable = viewModel.itemUpdates
            .compactMap { $0 } // skip initial `nil` value
            .sink { [weak self] mode, items in
                guard let self else { return }
                var snapshot = self.datasource.snapshot()
                
                if case .overwrite = mode {
                    snapshot.deleteAllItems()
                }
                
                items.forEach { item in
                    self.append(item: item, to: &snapshot)
                }
                
                self.datasource.apply(snapshot)
            }
        
        errorAlertsCancellable = viewModel.errorAlerts
            .compactMap { $0 } // TODO: - dismiss any presented alert if this becomes nil
            .sink { [weak self] errorAlert in
                guard let self else { return }
                self.presentAlert(alertInfo: errorAlert)
            }
        
        isLoadingCancellable = viewModel.isLoading
            .sink(receiveValue: { [weak self] isLoading in
                guard let self else { return }
                self.navigationItem.rightBarButtonItem = isLoading ? ActivityIndicatorBarButtonItem() : nil
            })
    }
    
    private func append(item: CollectionItem, to snapshot: inout NSDiffableDataSourceSnapshot<Section, CollectionItem>) {
        
        /// If the current section does not exist, insert one into the snapshot:
        if snapshot.indexOfSection(item.section) == nil {
            snapshot.appendSections([item.section])
        }
        
        snapshot.appendItems([item], toSection: item.section)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.constrainToEdges(ofContainingView: view)

        collectionView.delegate = self
        collectionView.dataSource = datasource
        
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "Search bar text placeholder")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // TODO: it's arguable that the Coordinator should be presenting this, but running out of time..
    private func presentAlert(alertInfo: OverviewViewModel.ErrorAlert) {
        switch alertInfo {
        case let .networkError(title, message, retry):
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let retryAction = UIAlertAction(title: NSLocalizedString("Retry", comment: "Error alert retry button"), style: .default) { _ in
                retry()
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Error alert cancel button"), style: .cancel)
            alertController.addAction(retryAction)
            alertController.addAction(cancelAction)
            alertController.preferredAction = retryAction
            self.present(alertController, animated: true)
        }
    }
}

extension OverviewViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collectionItem = datasource.itemIdentifier(for: indexPath) else { return }
        viewModel.userTappedCell(data: collectionItem)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let numberOfSections = datasource.numberOfSections(in: collectionView)
        guard indexPath.section == (numberOfSections - 1) else { return } // only dealing with the last section
        
        let numberOfRows = datasource.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        guard indexPath.row == (numberOfRows - 1) else { return } // only dealing with the last row in the last section.
        
        viewModel.userViewedTheLastCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 70)
    }
}

extension OverviewViewController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        // If the query is an empty string, prefer nil instead:
        let query: String? = {
            guard let query = searchController.searchBar.text, !query.isEmpty else {
                return nil
            }
            return query
        }()
        viewModel.userTypedSearchQuery(query: query)
    }
}


