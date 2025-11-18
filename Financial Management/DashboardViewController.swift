//
//  DashboardViewController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DashboardViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header user info area
    private let userHeaderView = UIView()
    private let userAvatarImageView = UIImageView()
    private let userNameLabel = UILabel()
    private let greetingLabel = UILabel()
    
    // Balance card
    private let balanceCardView = UIView()
    private let balanceLabel = UILabel()
    private let incomeLabel = UILabel()
    private let expenseLabel = UILabel()
    
    // Recent transactions
    private let recentTransactionsHeaderView = UIView()
    private let recentTransactionsLabel = UILabel()
    private let viewAllButton = UIButton(type: .system)
    private let transactionsTableView = UITableView()
    
    // Add transaction button
    private let addTransactionButton = UIButton(type: .system)
    
    // MARK: - Properties
    private var transactions: [Transaction] = []
    private var statistics: TransactionStatistics?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupData()
        setupNotifications()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Financial Management"
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Configure scroll view
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configure header user info area
        setupUserHeader()
        
        // Configure balance card
        setupBalanceCard()
        
        // Configure recent transactions header
        setupRecentTransactionsHeader()
        
        // Configure transaction list
        transactionsTableView.backgroundColor = UIColor.clear
        transactionsTableView.separatorStyle = .none
        transactionsTableView.showsVerticalScrollIndicator = false
        transactionsTableView.isScrollEnabled = false
        
        // Configure add button
        setupAddButton()
        
        // Add subviews
        contentView.addSubview(userHeaderView)
        contentView.addSubview(balanceCardView)
        contentView.addSubview(recentTransactionsHeaderView)
        contentView.addSubview(transactionsTableView)
        view.addSubview(addTransactionButton)
    }
    
    private func setupUserHeader() {
        userHeaderView.backgroundColor = UIColor.systemBackground
        userHeaderView.layer.cornerRadius = 12
        userHeaderView.layer.shadowColor = UIColor.black.cgColor
        userHeaderView.layer.shadowOffset = CGSize(width: 0, height: 2)
        userHeaderView.layer.shadowRadius = 4
        userHeaderView.layer.shadowOpacity = 0.1
        
        // Add tap gesture (optional)
        // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userHeaderTapped))
        // userHeaderView.addGestureRecognizer(tapGesture)
        // userHeaderView.isUserInteractionEnabled = true
        
        // Configure avatar
        userAvatarImageView.contentMode = .scaleAspectFill
        userAvatarImageView.clipsToBounds = true
        userAvatarImageView.layer.cornerRadius = 25
        userAvatarImageView.backgroundColor = UIColor.systemGray5
        userAvatarImageView.image = UIImage(systemName: "person.circle.fill")
        userAvatarImageView.tintColor = UIColor.systemGray3
        
        // Configure greeting
        greetingLabel.text = getGreeting()
        greetingLabel.font = UIFont.systemFont(ofSize: 14)
        greetingLabel.textColor = UIColor.secondaryLabel
        
        // Configure username
        userNameLabel.text = "User"
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        userNameLabel.textColor = UIColor.label
        
        // Add subviews
        userHeaderView.addSubview(userAvatarImageView)
        userHeaderView.addSubview(greetingLabel)
        userHeaderView.addSubview(userNameLabel)
        
        // Constraints
        userHeaderView.translatesAutoresizingMaskIntoConstraints = false
        userAvatarImageView.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userHeaderView.heightAnchor.constraint(equalToConstant: 80),
            
            userAvatarImageView.leadingAnchor.constraint(equalTo: userHeaderView.leadingAnchor, constant: 16),
            userAvatarImageView.centerYAnchor.constraint(equalTo: userHeaderView.centerYAnchor),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: 50),
            userAvatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            greetingLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: 12),
            greetingLabel.topAnchor.constraint(equalTo: userHeaderView.topAnchor, constant: 20),
            greetingLabel.trailingAnchor.constraint(lessThanOrEqualTo: userHeaderView.trailingAnchor, constant: -16),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: 12),
            userNameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            userNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: userHeaderView.trailingAnchor, constant: -16)
        ])
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Good morning"
        case 12..<18:
            return "Good afternoon"
        case 18..<22:
            return "Good evening"
        default:
            return "It's late"
        }
    }
    
    @objc private func userHeaderTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }

    private func setupRecentTransactionsHeader() {
        // Configure title
        recentTransactionsLabel.text = "Recent Transactions"
        recentTransactionsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        recentTransactionsLabel.textColor = UIColor.label
        
        // Configure "View All" button
        viewAllButton.setTitle("View All", for: .normal)
        viewAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        viewAllButton.setTitleColor(UIColor.systemBlue, for: .normal)
        viewAllButton.addTarget(self, action: #selector(viewAllTransactionsTapped), for: .touchUpInside)
        
        // Add to header view
        recentTransactionsHeaderView.addSubview(recentTransactionsLabel)
        recentTransactionsHeaderView.addSubview(viewAllButton)
        
        // Constraints
        recentTransactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        viewAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recentTransactionsLabel.leadingAnchor.constraint(equalTo: recentTransactionsHeaderView.leadingAnchor),
            recentTransactionsLabel.centerYAnchor.constraint(equalTo: recentTransactionsHeaderView.centerYAnchor),
            
            viewAllButton.trailingAnchor.constraint(equalTo: recentTransactionsHeaderView.trailingAnchor),
            viewAllButton.centerYAnchor.constraint(equalTo: recentTransactionsHeaderView.centerYAnchor),
            
            recentTransactionsHeaderView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupBalanceCard() {
        // Create gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1.0).cgColor,  // #667eea
            UIColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1.0).cgColor  // #764ba2
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        
        balanceCardView.layer.insertSublayer(gradientLayer, at: 0)
        balanceCardView.layer.cornerRadius = 16
        balanceCardView.layer.shadowColor = UIColor.black.cgColor
        balanceCardView.layer.shadowOpacity = 0.1
        balanceCardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        balanceCardView.layer.shadowRadius = 8
        
        // Balance label
        balanceLabel.text = "¥ 0.00"
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 32)
        balanceLabel.textColor = UIColor.white
        balanceLabel.textAlignment = .center
        
        // Income label
        incomeLabel.text = "This Month Income: ¥ 0.00"
        incomeLabel.font = UIFont.systemFont(ofSize: 16)
        incomeLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        
        // Expense label
        expenseLabel.text = "This Month Expense: ¥ 0.00"
        expenseLabel.font = UIFont.systemFont(ofSize: 16)
        expenseLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        
        balanceCardView.addSubview(balanceLabel)
        balanceCardView.addSubview(incomeLabel)
        balanceCardView.addSubview(expenseLabel)
        
        // Update gradient layer frame
        DispatchQueue.main.async {
            gradientLayer.frame = self.balanceCardView.bounds
        }
    }
    
    private func setupAddButton() {
        addTransactionButton.backgroundColor = UIColor(red: 0.94, green: 0.58, blue: 0.98, alpha: 1.0) // #f093fb
        addTransactionButton.setTitle("+", for: .normal)
        addTransactionButton.setTitleColor(.white, for: .normal)
        addTransactionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        addTransactionButton.layer.cornerRadius = 28
        addTransactionButton.layer.shadowColor = UIColor.black.cgColor
        addTransactionButton.layer.shadowOpacity = 0.2
        addTransactionButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addTransactionButton.layer.shadowRadius = 8
        
        addTransactionButton.addTarget(self, action: #selector(addTransactionTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // Disable autoresizing masks
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        balanceCardView.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        incomeLabel.translatesAutoresizingMaskIntoConstraints = false
        expenseLabel.translatesAutoresizingMaskIntoConstraints = false
        recentTransactionsHeaderView.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header user info constraints
            userHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            userHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Balance card constraints
            balanceCardView.topAnchor.constraint(equalTo: userHeaderView.bottomAnchor, constant: 20),
            balanceCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            balanceCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            balanceCardView.heightAnchor.constraint(equalToConstant: 160),
            
            // Balance label constraints
            balanceLabel.centerXAnchor.constraint(equalTo: balanceCardView.centerXAnchor),
            balanceLabel.topAnchor.constraint(equalTo: balanceCardView.topAnchor, constant: 30),
            
            // Income label constraints
            incomeLabel.leadingAnchor.constraint(equalTo: balanceCardView.leadingAnchor, constant: 20),
            incomeLabel.bottomAnchor.constraint(equalTo: balanceCardView.bottomAnchor, constant: -20),
            
            // Expense label constraints
            expenseLabel.trailingAnchor.constraint(equalTo: balanceCardView.trailingAnchor, constant: -20),
            expenseLabel.bottomAnchor.constraint(equalTo: balanceCardView.bottomAnchor, constant: -20),
            
            // Recent transactions header constraints
            recentTransactionsHeaderView.topAnchor.constraint(equalTo: balanceCardView.bottomAnchor, constant: 30),
            recentTransactionsHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recentTransactionsHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Transactions table constraints
            transactionsTableView.topAnchor.constraint(equalTo: recentTransactionsHeaderView.bottomAnchor, constant: 15),
            transactionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            transactionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            transactionsTableView.heightAnchor.constraint(equalToConstant: 300),
            transactionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Add button constraints
            addTransactionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addTransactionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addTransactionButton.widthAnchor.constraint(equalToConstant: 56),
            addTransactionButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupData() {
        // Configure table view
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        transactionsTableView.separatorStyle = .none
        transactionsTableView.backgroundColor = UIColor.clear
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transactionAdded),
            name: .transactionAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transactionUpdated),
            name: .transactionUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transactionDeleted),
            name: .transactionDeleted,
            object: nil
        )
    }
    
    @objc private func transactionAdded() {
        loadData()
    }
    
    @objc private func transactionUpdated() {
        loadData()
    }
    
    @objc private func transactionDeleted() {
        loadData()
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        loadStatistics()
        loadRecentTransactions()
        loadUserInfo()
    }
    
    private func loadUserInfo() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // Fetch more user info from Firestore
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    if let displayName = data?["displayName"] as? String, !displayName.isEmpty {
                        self?.userNameLabel.text = displayName
                    } else {
                        // Fallback to Firebase user displayName or email prefix
                        if let displayName1 = currentUser.displayName, !displayName1.isEmpty {
                            self?.userNameLabel.text = displayName1
                        } else {
                            self?.userNameLabel.text = currentUser.email?.components(separatedBy: "@").first ?? "User"
                        }
                    }
                }
                
                // Load avatar from keychain
                self?.loadAvatarFromKeychain()
            }
        }
    }
    
    private func loadAvatarFromKeychain() {
        print("DashboardViewController: Start loading avatar from keychain")
        
        if let avatarImage = UIImage.loadAvatarImage() {
            print("DashboardViewController: Successfully loaded avatar from keychain")
            userAvatarImageView.image = avatarImage
            userAvatarImageView.backgroundColor = UIColor.clear
        } else {
            print("DashboardViewController: No avatar in keychain, using default avatar")
            setDefaultAvatar()
        }
    }
    
    private func setDefaultAvatar() {
        userAvatarImageView.image = UIImage(systemName: "person.circle.fill")
        userAvatarImageView.tintColor = UIColor.systemGray3
        userAvatarImageView.backgroundColor = UIColor.systemGray5
    }

    private func loadUserAvatar(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.userAvatarImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private func loadStatistics() {
        DataManager.shared.calculateStatistics(for: .month) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statistics):
                    self?.statistics = statistics
                    self?.updateBalanceCard(with: statistics)
                case .failure(let error):
                    print("Failed to load statistics: \(error.localizedDescription)")
                    // Show default data
                    self?.updateBalanceCard(with: nil)
                }
            }
        }
    }
    
    private func loadRecentTransactions() {
        DataManager.shared.fetchTransactions(limit: 4) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transactions):
                    self?.transactions = transactions
                    self?.transactionsTableView.reloadData()
                case .failure(let error):
                    print("Failed to load transactions: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateBalanceCard(with statistics: TransactionStatistics?) {
        let totalIncome = statistics?.totalIncome ?? 0
        let totalExpense = statistics?.totalExpense ?? 0
        let balance = totalIncome - totalExpense
        
        balanceLabel.text = String(format: "¥%.2f", balance)
        incomeLabel.text = String(format: "Income ¥%.2f", totalIncome)
        expenseLabel.text = String(format: "Expense ¥%.2f", totalExpense)
        
        // Set color based on balance
        if balance >= 0 {
            balanceLabel.textColor = UIColor.white
        } else {
            balanceLabel.textColor = UIColor.systemRed
        }
    }
    
    @objc private func addTransactionTapped() {
        let addTransactionVC = AddTransactionViewController()
        let navController = UINavigationController(rootViewController: addTransactionVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func viewAllTransactionsTapped() {
        let transactionListVC = TransactionListViewController()
        navigationController?.pushViewController(transactionListVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        let transaction = transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Show transaction detail or edit screen
    }
}
