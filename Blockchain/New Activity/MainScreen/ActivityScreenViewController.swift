//
//  ActivityScreenViewController.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift

final class ActivityScreenViewController: BaseScreenViewController {
    
    // MARK: - Private Types
    
    private typealias RxDataSource = RxTableViewSectionedAnimatedDataSource<ActivityItemsSectionViewModel>

    // MARK: - UI Properties
    
    @IBOutlet private var selectionButtonView: SelectionButtonView!
    @IBOutlet private var emptyActivityTitleLabel: UILabel!
    @IBOutlet private var emptyActivitySubtitleLabel: UILabel!
    @IBOutlet private var emptyActivityImageView: UIImageView!
    @IBOutlet private var empyActivityStackView: UIStackView!
    @IBOutlet private var tableView: SelfSizingTableView!
    private var refreshControl: UIRefreshControl!
    
    // MARK: - Injected
    
    private let presenter: ActivityScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Setup
    
    init() {
        // TODO: Presenter should be injected into the view as well as the `Router`.
        let services = ActivityServiceContainer()
        let router = ActivityRouter(container: services)
        let interactor = ActivityScreenInteractor(serviceContainer: services)
        self.presenter = ActivityScreenPresenter(router: router, interactor: interactor)
        super.init(nibName: ActivityScreenViewController.objectName, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectionButtonView.viewModel = presenter.selectionButtonViewModel
        setupNavigationBar()
        setupTableView()
        setupEmptyState()
        presenter.refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            guard let self = self else { return }
            self.presenter.refresh()
        }
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        set(barStyle: .lightContent(),
            leadingButtonStyle: .drawer,
            trailingButtonStyle: .qrCode)
        titleViewStyle = .text(value: presenter.title)
    }
    
    private func setupEmptyState() {
        emptyActivityTitleLabel.content = presenter.emptyActivityTitle
        emptyActivitySubtitleLabel.content = presenter.emptyActivitySubtitle
        
        let alpha = presenter
            .emptySubviewsVisibility
            .map { $0.defaultAlpha }
        
        alpha
            .drive(emptyActivitySubtitleLabel.rx.alpha)
            .disposed(by: disposeBag)
        
        alpha
            .drive(emptyActivityTitleLabel.rx.alpha)
            .disposed(by: disposeBag)
        
        alpha
            .drive(emptyActivityImageView.rx.alpha)
            .disposed(by: disposeBag)
        
        alpha
            .map { $0 == 0 }
            .drive(empyActivityStackView.rx.isHidden)
            .disposed(by: disposeBag)
        }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(SelectionButtonTableViewCell.self)
        tableView.registerNibCell(ActivityItemTableViewCell.self)
        tableView.registerNibCell(ActivitySkeletonTableViewCell.self)
        
        let animation = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade)
        
        let dataSource = RxDataSource(animationConfiguration: animation, configureCell: { [weak self] _, _, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            
            switch item {
            case .selection(let viewModel):
                cell = self.selectionButtonTableViewCell(for: indexPath, viewModel: viewModel)
            case .skeleton:
                cell = self.skeletonCell(for: indexPath)
            case .activity(let presenter):
                cell = self.activityItemTableViewCell(for: indexPath, presenter: presenter)
            }
            cell.selectionStyle = .none
            return cell
        })
        
        presenter.sectionsObservable
            .bindAndCatch(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.rx
            .modelSelected(ActivityCellItem.self)
            .bindAndCatch(to: presenter.selectedModelRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    
    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonPressed()
    }
    
    override func navigationBarTrailingButtonPressed() {
        presenter.navigationBarTrailingButtonPressed()
    }
    
    // MARK: - UITableView refresh
    
    @objc
    private func refresh() {
        presenter.refresh()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Private Functions
    
    private func skeletonCell(for indexPath: IndexPath) -> ActivitySkeletonTableViewCell {
        let cell = tableView.dequeue(ActivitySkeletonTableViewCell.self, for: indexPath)
        return cell
    }
    
    private func activityItemTableViewCell(for indexPath: IndexPath, presenter: ActivityItemPresenter) -> ActivityItemTableViewCell {
        let cell = tableView.dequeue(ActivityItemTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
    
    private func selectionButtonTableViewCell(for indexPath: IndexPath, viewModel: SelectionButtonViewModel) -> SelectionButtonTableViewCell {
        let cell = tableView.dequeue(
            SelectionButtonTableViewCell.self,
            for: indexPath
        )
        cell.viewModel = viewModel
        return cell
    }
}
