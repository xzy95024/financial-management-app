//
//  MerchantsViewController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit

class MerchantsViewController: UIViewController {
    
    // MARK: - Properties
    private var merchants: [Merchant] = []
    private var filteredMerchants: [Merchant] = []
    private var isSearching = false
    
    // MARK: - UI Components
    private let searchBar = UISearchBar()
    private let merchantsTableView = UITableView()
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    private let addButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupData()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMerchants()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = "Merchants"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Navigation bar
        addButton.image = UIImage(systemName: "plus")
        addButton.target = self
        addButton.action = #selector(addMerchantTapped)
        navigationItem.rightBarButtonItem = addButton
        
        // Search bar
        searchBar.placeholder = "Search merchants..."
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        
        // TableView
        merchantsTableView.backgroundColor = UIColor.clear
        merchantsTableView.separatorStyle = .none
        merchantsTableView.showsVerticalScrollIndicator = false
        merchantsTableView.delegate = self
        merchantsTableView.dataSource = self
        merchantsTableView.register(MerchantTableViewCell.self, forCellReuseIdentifier: "MerchantCell")
        
        // Empty state
        emptyStateView.backgroundColor = UIColor.clear
        
        emptyStateLabel.text = "🏪\n\nNo merchant records yet.\nMerchants will be created automatically when you add transactions."
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.textColor = UIColor.systemGray
        
        view.addSubview(searchBar)
        view.addSubview(merchantsTableView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateLabel)
        
        showEmptyState()
    }
    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        merchantsTableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Search bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // TableView
            merchantsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            merchantsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            merchantsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            merchantsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty state container
            emptyStateView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty state label
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupData() {
        loadMerchants()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(merchantsUpdated),
            name: .merchantsUpdated,
            object: nil
        )
    }
    
    @objc private func merchantsUpdated() {
        DispatchQueue.main.async { self.loadMerchants() }
    }
    
    // MARK: - Add Merchant
    @objc private func addMerchantTapped() {
        let alert = UIAlertController(
            title: "Add Merchant",
            message: "Enter merchant details",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Merchant name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Category (optional)"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard
                let nameField = alert.textFields?[0],
                let categoryField = alert.textFields?[1],
                let name = nameField.text,
                !name.isEmpty
            else { return }
            
            let merchantKey = name.lowercased().replacingOccurrences(of: " ", with: "")
            let category = categoryField.text?.isEmpty == false ? categoryField.text : "Other"
            
            var note = MerchantNote()
            note.category = category
            
            let merchant = Merchant(
                userId: "",
                merchantKey: merchantKey,
                merchantDisplayName: name,
                note: note
            )
            
            self?.saveMerchant(merchant)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Data Handling
    private func loadMerchants() {
        DataManager.shared.fetchMerchants { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let merchants):
                    self?.merchants = merchants
                    self?.updateUI()
                case .failure(let error):
                    print("Failed to load merchants: \(error.localizedDescription)")
                    self?.showError("Failed to load merchants.")
                }
            }
        }
    }
    
    private func saveMerchant(_ merchant: Merchant) {
        DataManager.shared.addMerchant(merchant) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadMerchants()
                case .failure(let error):
                    print("Failed to save merchant: \(error.localizedDescription)")
                    self?.showError("Failed to save merchant.")
                }
            }
        }
    }
    
    private func deleteMerchant(at indexPath: IndexPath) {
        let merchant = isSearching ? filteredMerchants[indexPath.row] : merchants[indexPath.row]
        
        guard let merchantId = merchant.id else { return }
        
        let alert = UIAlertController(
            title: "Delete Merchant",
            message: "Are you sure you want to delete \"\(merchant.merchantDisplayName)\"?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            DataManager.shared.deleteMerchant(id: merchantId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.loadMerchants()
                    case .failure(let error):
                        print("Failed to delete merchant: \(error.localizedDescription)")
                        self?.showError("Failed to delete merchant.")
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func updateUI() {
        if merchants.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
            merchantsTableView.reloadData()
        }
    }
    
    private func filterMerchants(with searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredMerchants.removeAll()
        } else {
            isSearching = true
            filteredMerchants = merchants.filter { merchant in
                merchant.merchantDisplayName.localizedCaseInsensitiveContains(searchText) ||
                merchant.merchantKey.localizedCaseInsensitiveContains(searchText) ||
                (merchant.note.category?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        merchantsTableView.reloadData()
    }
    
    // MARK: - Helpers
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showEmptyState() {
        emptyStateView.isHidden = false
        merchantsTableView.isHidden = true
    }
    
    private func hideEmptyState() {
        emptyStateView.isHidden = true
        merchantsTableView.isHidden = false
    }
}

// MARK: - SearchBar Delegate
extension MerchantsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterMerchants(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterMerchants(with: "")
    }
}

// MARK: - TableView Delegate & DataSource
extension MerchantsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredMerchants.count : merchants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = merchantsTableView.dequeueReusableCell(withIdentifier: "MerchantCell", for: indexPath) as! MerchantTableViewCell
        let merchant = isSearching ? filteredMerchants[indexPath.row] : merchants[indexPath.row]
        cell.configure(with: merchant)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let merchant = isSearching ? filteredMerchants[indexPath.row] : merchants[indexPath.row]
        
        let detailVC = MerchantDetailViewController(merchant: merchant)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Swipe delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteMerchant(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}
