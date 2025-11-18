import UIKit

class TransactionListViewController: UIViewController {
    
    // MARK: - UI Components
    private let searchBar = UISearchBar()
    private let filterButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    // MARK: - Data
    private var allTransactions: [Transaction] = []
    private var filteredTransactions: [Transaction] = []
    private var categories: [Category] = []
    
    // MARK: - Filter State
    private var selectedCategory: Category?
    private var selectedTransactionType: Transaction.TransactionType?
    private var startDate: Date?
    private var endDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupData()
        loadData()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Transactions"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        
        // Search bar
        searchBar.placeholder = "Search transactions..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        
        // Table view
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.keyboardDismissMode = .onDrag
        
        // Empty state label
        emptyStateLabel.text = "No transactions yet"
        emptyStateLabel.textColor = UIColor.secondaryLabel
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true
        
        // Add subviews
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Search bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Empty state label
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        loadCategories()
        loadTransactions()
    }
    
    private func loadCategories() {
        DataManager.shared.fetchCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                case .failure(let error):
                    print("Failed to load categories: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadTransactions() {
        DataManager.shared.fetchTransactions(limit: 1000) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transactions):
                    self?.allTransactions = transactions
                    self?.applyFilters()
                case .failure(let error):
                    print("Failed to load transactions: \(error.localizedDescription)")
                    self?.updateEmptyState()
                }
            }
        }
    }
    
    // MARK: - Filter Logic
    
    private func applyFilters() {
        var filtered = allTransactions
        
        // Search text filtering
        if let searchText = searchBar.text, !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                // Description
                let matchesDescription = transaction.description?.localizedCaseInsensitiveContains(searchText) == true
                
                // Merchant name
                let matchesMerchant = transaction.merchantName?.localizedCaseInsensitiveContains(searchText) == true
                
                // Category name
                let matchesCategory = transaction.categoryName?.localizedCaseInsensitiveContains(searchText) == true
                
                // Transaction type (using displayName)
                let matchesType = transaction.type.displayName.localizedCaseInsensitiveContains(searchText)
                
                // Amount (supports partial string match)
                let amountString = String(format: "%.2f", transaction.amount)
                let matchesAmount = amountString.contains(searchText) ||
                    String(format: "%.0f", transaction.amount).contains(searchText)
                
                return matchesDescription || matchesMerchant || matchesCategory || matchesType || matchesAmount
            }
        }
        
        // Category filter
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.categoryId == selectedCategory.id }
        }
        
        // Transaction type filter
        if let selectedType = selectedTransactionType {
            filtered = filtered.filter { $0.type == selectedType }
        }
        
        // Date range filter
        if let startDate = startDate {
            filtered = filtered.filter { $0.date >= startDate }
        }
        
        if let endDate = endDate {
            filtered = filtered.filter { $0.date <= endDate }
        }
        
        filteredTransactions = filtered
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = filteredTransactions.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func filterButtonTapped() {
        showFilterOptions()
    }
    
    private func showFilterOptions() {
        let alertController = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .actionSheet)
        
        // Transaction type filters
        alertController.addAction(UIAlertAction(title: "Income", style: .default) { [weak self] _ in
            self?.selectedTransactionType = .income
            self?.applyFilters()
        })
        
        alertController.addAction(UIAlertAction(title: "Expense", style: .default) { [weak self] _ in
            self?.selectedTransactionType = .expense
            self?.applyFilters()
        })
        
        // Time filters
        alertController.addAction(UIAlertAction(title: "This Month", style: .default) { [weak self] _ in
            let calendar = Calendar.current
            let now = Date()
            self?.startDate = calendar.dateInterval(of: .month, for: now)?.start
            self?.endDate = calendar.dateInterval(of: .month, for: now)?.end
            self?.applyFilters()
        })
        
        alertController.addAction(UIAlertAction(title: "This Week", style: .default) { [weak self] _ in
            let calendar = Calendar.current
            let now = Date()
            self?.startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start
            self?.endDate = calendar.dateInterval(of: .weekOfYear, for: now)?.end
            self?.applyFilters()
        })
        
        // Clear filters
        alertController.addAction(UIAlertAction(title: "Clear Filters", style: .destructive) { [weak self] _ in
            self?.clearFilters()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alertController.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alertController, animated: true)
    }
    
    private func clearFilters() {
        selectedCategory = nil
        selectedTransactionType = nil
        startDate = nil
        endDate = nil
        searchBar.text = ""
        applyFilters()
    }
    
    // MARK: - Transaction Actions
    
    private func showDeleteConfirmation(for transaction: Transaction, at indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: "Confirm Delete",
            message: "Are you sure you want to delete this transaction? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteTransaction(transaction, at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func deleteTransaction(_ transaction: Transaction, at indexPath: IndexPath) {
        guard let transactionId = transaction.id else {
            showAlert(title: "Error", message: "Unable to delete transaction: invalid transaction ID")
            return
        }
        
        DataManager.shared.deleteTransaction(id: transactionId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Remove from data source
                    if let allIndex = self?.allTransactions.firstIndex(where: { $0.id == transactionId }) {
                        self?.allTransactions.remove(at: allIndex)
                    }
                    self?.filteredTransactions.remove(at: indexPath.row)
                    
                    // Update UI
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                    self?.updateEmptyState()
                    
                case .failure(let error):
                    self?.showAlert(title: "Delete Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func editTransaction(_ transaction: Transaction) {
        // Present AddTransactionViewController in edit mode
        // If you have a storyboard-based implementation, replace this with instantiateViewController
        let addTransactionVC = AddTransactionViewController()
        addTransactionVC.isEditMode = true
        addTransactionVC.transactionToEdit = transaction
        
        let navController = UINavigationController(rootViewController: addTransactionVC)
        present(navController, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TransactionListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionCell",
            for: indexPath
        ) as! TransactionTableViewCell
        
        let transaction = filteredTransactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TransactionListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 80
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Implement transaction detail view
    }
    
    // MARK: - Swipe Actions
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let transaction = filteredTransactions[indexPath.row]
        
        // Delete
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] (_, _, completionHandler) in
            self?.showDeleteConfirmation(for: transaction, at: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor.systemRed
        
        // Edit
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit"
        ) { [weak self] (_, _, completionHandler) in
            self?.editTransaction(transaction)
            completionHandler(true)
        }
        editAction.backgroundColor = UIColor.systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}

// MARK: - UISearchBarDelegate

extension TransactionListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
