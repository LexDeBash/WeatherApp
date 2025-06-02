//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Alexey Efimov on 28.05.2025.
//

import UIKit

final class ForecastViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        return tableView.preparedForAutoLayout()
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner.preparedForAutoLayout()
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Dependencies
    private let viewModel: ForecastViewModelProtocol
    
    // MARK: - State
    private var forecastTask: Task<Void, Never>?
    
    // MARK: - Init
    init(viewModel: ForecastViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configureTableView()
        configureLayout()
        configureRefreshControl()
        bindViewModel()
        loadForecast()
    }
    
    deinit {
        forecastTask?.cancel()
    }
}

// MARK: - UITableViewDataSource
extension ForecastViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.reuseIdentifier, for: indexPath)
        
        guard let cell = cell as? ForecastCell else {
            preconditionFailure("Failed to dequeue ForecastCell")
        }
        
        let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
        
        cell.configure(with: cellViewModel) { [weak self] url in
            guard let self else { throw CancellationError() }
            return try await viewModel.loadImage(for: url)
        }
        
        return cell
    }
}

// MARK: - SetupUI
private extension ForecastViewController {
    func configureAppearance() {
        title = "Forecast in Moscow"
        view.backgroundColor = .systemBackground
    }
    
    func configureTableView() {
        tableView.dataSource = self
        
        tableView.register(
            ForecastCell.self,
            forCellReuseIdentifier: ForecastCell.reuseIdentifier
        )
        
    }
    
    private func configureRefreshControl() {
        tableView.alwaysBounceVertical = true
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl = self?.refreshControl
        }
        
        let refreshAction = UIAction { [weak self] _ in
            self?.loadForecast()
        }
        
        refreshControl.addAction(refreshAction, for: .valueChanged)
    }
    
    func configureLayout() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Bindings
private extension ForecastViewController {
    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            
            switch state {
            case .idle:
                break
            case .loading:
                activityIndicator.startAnimating()
            case .loaded:
                self.activityIndicator.stopAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    
                }
            case .failed(let message):
                activityIndicator.stopAnimating()
                refreshControl.endRefreshing()
                presentErrorAlert(message)
            }
        }
    }
}

// MARK: - Actions
private extension ForecastViewController {
    func loadForecast() {
        forecastTask?.cancel()
        forecastTask = Task {
            await viewModel.loadForecast(for: "Moscow")
        }
    }
    
    @objc private func didPullToRefresh() {
        loadForecast()
    }
}

// MARK: - Helpers
private extension ForecastViewController {
    func presentErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
