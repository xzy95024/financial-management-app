//
//  MerchantDetailViewController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//
//

import UIKit

class MerchantDetailViewController: UIViewController {
    
    // MARK: - Properties
    private var merchant: Merchant
    private var transactions: [Transaction] = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header Section
    private let headerView = UIView()
    private let merchantIconView = UIView()
    private let merchantIconLabel = UILabel()
    private let merchantNameLabel = UILabel()
    private let merchantCategoryLabel = UILabel()
    private let editButton = UIButton(type: .system)
    
    // Stats Section
    private let statsContainerView = UIView()
    private let statsStackView = UIStackView()
    private let visitCountView = StatisticCardView()
    private let totalSpentView = StatisticCardView()
    private let avgSpentView = StatisticCardView()
    
    // Rating Section
    private let ratingContainerView = UIView()
    private let ratingTitleLabel = UILabel()
    private let ratingStackView = UIStackView()
    private let ratingStarsView = UIStackView()
    private let ratingLabel = UILabel()
    private let verdictLabel = UILabel()
    
    // Notes Section
    private let notesContainerView = UIView()
    private let notesTitleLabel = UILabel()
    private let prosLabel = UILabel()
    private let consLabel = UILabel()
    private let tipsLabel = UILabel()
    private let rawNotesLabel = UILabel()
    
    // Recent Transactions Section
    private let transactionsContainerView = UIView()
    private let transactionsTitleLabel = UILabel()
    private let transactionsTableView = UITableView()
    
    // MARK: - Initialization
    init(merchant: Merchant) {
        self.merchant = merchant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadData()
    }
    
    private func setupUI() {
        title = merchant.merchantDisplayName
        view.backgroundColor = UIColor.systemGroupedBackground
        
        // Configure navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editMerchantTapped)
        )
        
        // Configure scroll view
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        
        contentView.backgroundColor = UIColor.clear
        
        // Configure header section
        setupHeaderSection()
        
        // Configure stats section
        setupStatsSection()
        
        // Configure rating section
        setupRatingSection()
        
        // Configure notes section
        setupNotesSection()
        
        // Configure recent transactions section
        setupTransactionsSection()
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(statsContainerView)
        contentView.addSubview(ratingContainerView)
        contentView.addSubview(notesContainerView)
        contentView.addSubview(transactionsContainerView)
    }
    
    private func setupHeaderSection() {
        headerView.backgroundColor = UIColor.systemBackground
        headerView.layer.cornerRadius = 12
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowRadius = 3
        
        // Merchant icon
        merchantIconView.backgroundColor = UIColor.systemBlue
        merchantIconView.layer.cornerRadius = 30
        
        merchantIconLabel.text = "🏪"
        merchantIconLabel.textAlignment = .center
        merchantIconLabel.font = UIFont.systemFont(ofSize: 30)
        
        // Merchant name
        merchantNameLabel.text = merchant.merchantDisplayName
        merchantNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        merchantNameLabel.textColor = UIColor.label
        merchantNameLabel.numberOfLines = 0
        
        // Merchant category
        merchantCategoryLabel.text = merchant.note.category ?? "Uncategorized"
        merchantCategoryLabel.font = UIFont.systemFont(ofSize: 16)
        merchantCategoryLabel.textColor = UIColor.secondaryLabel
        
        // Edit button
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        editButton.addTarget(self, action: #selector(editMerchantTapped), for: .touchUpInside)
        
        headerView.addSubview(merchantIconView)
        merchantIconView.addSubview(merchantIconLabel)
        headerView.addSubview(merchantNameLabel)
        headerView.addSubview(merchantCategoryLabel)
        headerView.addSubview(editButton)
    }
    
    private func setupStatsSection() {
        statsContainerView.backgroundColor = UIColor.systemBackground
        statsContainerView.layer.cornerRadius = 12
        statsContainerView.layer.shadowColor = UIColor.black.cgColor
        statsContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        statsContainerView.layer.shadowOpacity = 0.1
        statsContainerView.layer.shadowRadius = 3
        
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 1
        
        // Visit count
        visitCountView.configure(
            title: "Visits",
            value: "\(merchant.stats.visitCount)",
            color: UIColor.systemBlue
        )
        
        // Total spent
        totalSpentView.configure(
            title: "Total Spent",
            value: String(format: "%.0f", merchant.stats.totalSpending),
            color: UIColor.systemGreen
        )
        
        // Average spent
        let avgSpent = merchant.stats.visitCount > 0 ? merchant.stats.totalSpending / Double(merchant.stats.visitCount) : 0
        avgSpentView.configure(
            title: "Avg per Visit",
            value: String(format: "%.0f", avgSpent),
            color: UIColor.systemOrange
        )
        
        statsStackView.addArrangedSubview(visitCountView)
        statsStackView.addArrangedSubview(totalSpentView)
        statsStackView.addArrangedSubview(avgSpentView)
        
        statsContainerView.addSubview(statsStackView)
    }
    
    private func setupRatingSection() {
        ratingContainerView.backgroundColor = UIColor.systemBackground
        ratingContainerView.layer.cornerRadius = 12
        ratingContainerView.layer.shadowColor = UIColor.black.cgColor
        ratingContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        ratingContainerView.layer.shadowOpacity = 0.1
        ratingContainerView.layer.shadowRadius = 3
        
        ratingTitleLabel.text = "Rating"
        ratingTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        ratingTitleLabel.textColor = UIColor.label
        
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 8
        ratingStackView.alignment = .center
        
        // Star rating
        ratingStarsView.axis = .horizontal
        ratingStarsView.spacing = 4
        
        let rating = merchant.note.rating ?? 0
        for i in 1...5 {
            let starLabel = UILabel()
            starLabel.text = i <= rating ? "⭐" : "☆"
            starLabel.font = UIFont.systemFont(ofSize: 20)
            ratingStarsView.addArrangedSubview(starLabel)
        }
        
        ratingLabel.text = rating > 0 ? "\(rating)/5" : "Not rated"
        ratingLabel.font = UIFont.systemFont(ofSize: 16)
        ratingLabel.textColor = UIColor.secondaryLabel
        
        // Recommendation badge
        if let verdict = merchant.note.verdict {
            verdictLabel.text = verdict.displayName
            verdictLabel.font = UIFont.systemFont(ofSize: 14)
            verdictLabel.textColor = UIColor(hex: verdict.color)
            verdictLabel.backgroundColor = UIColor(hex: verdict.color)?.withAlphaComponent(0.1)
            verdictLabel.layer.cornerRadius = 8
            verdictLabel.textAlignment = .center
            verdictLabel.layer.masksToBounds = true
        } else {
            verdictLabel.isHidden = true
        }
        
        ratingStackView.addArrangedSubview(ratingStarsView)
        ratingStackView.addArrangedSubview(ratingLabel)
        ratingStackView.addArrangedSubview(verdictLabel)
        
        ratingContainerView.addSubview(ratingTitleLabel)
        ratingContainerView.addSubview(ratingStackView)
    }
    
    private func setupNotesSection() {
        notesContainerView.backgroundColor = UIColor.systemBackground
        notesContainerView.layer.cornerRadius = 12
        notesContainerView.layer.shadowColor = UIColor.black.cgColor
        notesContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        notesContainerView.layer.shadowOpacity = 0.1
        notesContainerView.layer.shadowRadius = 3
        
        notesTitleLabel.text = "Notes"
        notesTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        notesTitleLabel.textColor = UIColor.label
        
        // Pros
        prosLabel.text = merchant.note.pros.isEmpty
            ? "Pros: None"
            : "Pros: \(merchant.note.pros.joined(separator: ", "))"
        prosLabel.font = UIFont.systemFont(ofSize: 14)
        prosLabel.textColor = UIColor.systemGreen
        prosLabel.numberOfLines = 0
        
        // Cons
        consLabel.text = merchant.note.cons.isEmpty
            ? "Cons: None"
            : "Cons: \(merchant.note.cons.joined(separator: ", "))"
        consLabel.font = UIFont.systemFont(ofSize: 14)
        consLabel.textColor = UIColor.systemRed
        consLabel.numberOfLines = 0
        
        // Tips
        tipsLabel.text = merchant.note.tips.isEmpty
            ? "Tips: None"
            : "Tips: \(merchant.note.tips.joined(separator: ", "))"
        tipsLabel.font = UIFont.systemFont(ofSize: 14)
        tipsLabel.textColor = UIColor.systemBlue
        tipsLabel.numberOfLines = 0
        
        // Raw notes
        if let raw = merchant.note.raw, !raw.isEmpty {
            rawNotesLabel.text = "Additional notes: \(raw)"
        } else {
            rawNotesLabel.text = "Additional notes: None"
        }
        rawNotesLabel.font = UIFont.systemFont(ofSize: 14)
        rawNotesLabel.textColor = UIColor.label
        rawNotesLabel.numberOfLines = 0
        
        notesContainerView.addSubview(notesTitleLabel)
        notesContainerView.addSubview(prosLabel)
        notesContainerView.addSubview(consLabel)
        notesContainerView.addSubview(tipsLabel)
        notesContainerView.addSubview(rawNotesLabel)
    }
    
    private func setupTransactionsSection() {
        transactionsContainerView.backgroundColor = UIColor.systemBackground
        transactionsContainerView.layer.cornerRadius = 12
        transactionsContainerView.layer.shadowColor = UIColor.black.cgColor
        transactionsContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        transactionsContainerView.layer.shadowOpacity = 0.1
        transactionsContainerView.layer.shadowRadius = 3
        
        transactionsTitleLabel.text = "Recent Transactions"
        transactionsTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        transactionsTitleLabel.textColor = UIColor.label
        
        transactionsTableView.backgroundColor = UIColor.clear
        transactionsTableView.separatorStyle = .none
        transactionsTableView.isScrollEnabled = false
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        
        transactionsContainerView.addSubview(transactionsTitleLabel)
        transactionsContainerView.addSubview(transactionsTableView)
    }
    
    private func setupConstraints() {
        // Disable autoresizing mask
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        merchantIconView.translatesAutoresizingMaskIntoConstraints = false
        merchantIconLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        ratingContainerView.translatesAutoresizingMaskIntoConstraints = false
        ratingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        verdictLabel.translatesAutoresizingMaskIntoConstraints = false
        
        notesContainerView.translatesAutoresizingMaskIntoConstraints = false
        notesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        prosLabel.translatesAutoresizingMaskIntoConstraints = false
        consLabel.translatesAutoresizingMaskIntoConstraints = false
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        rawNotesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        transactionsContainerView.translatesAutoresizingMaskIntoConstraints = false
        transactionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            merchantIconView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            merchantIconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            merchantIconView.widthAnchor.constraint(equalToConstant: 60),
            merchantIconView.heightAnchor.constraint(equalToConstant: 60),
            
            merchantIconLabel.centerXAnchor.constraint(equalTo: merchantIconView.centerXAnchor),
            merchantIconLabel.centerYAnchor.constraint(equalTo: merchantIconView.centerYAnchor),
            
            merchantNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            merchantNameLabel.leadingAnchor.constraint(equalTo: merchantIconView.trailingAnchor, constant: 16),
            merchantNameLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            
            merchantCategoryLabel.topAnchor.constraint(equalTo: merchantNameLabel.bottomAnchor, constant: 8),
            merchantCategoryLabel.leadingAnchor.constraint(equalTo: merchantIconView.trailingAnchor, constant: 16),
            merchantCategoryLabel.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -8),
            
            editButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            editButton.widthAnchor.constraint(equalToConstant: 60),
            
            // Stats section
            statsContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            statsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsContainerView.heightAnchor.constraint(equalToConstant: 100),
            
            statsStackView.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -16),
            
            // Rating section
            ratingContainerView.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 16),
            ratingContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ratingContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ratingContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            ratingTitleLabel.topAnchor.constraint(equalTo: ratingContainerView.topAnchor, constant: 16),
            ratingTitleLabel.leadingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: 16),
            ratingTitleLabel.trailingAnchor.constraint(equalTo: ratingContainerView.trailingAnchor, constant: -16),
            
            ratingStackView.topAnchor.constraint(equalTo: ratingTitleLabel.bottomAnchor, constant: 12),
            ratingStackView.leadingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: 16),
            ratingStackView.trailingAnchor.constraint(lessThanOrEqualTo: ratingContainerView.trailingAnchor, constant: -16),
            ratingStackView.bottomAnchor.constraint(equalTo: ratingContainerView.bottomAnchor, constant: -16),
            
            verdictLabel.widthAnchor.constraint(equalToConstant: 60),
            verdictLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // Notes section
            notesContainerView.topAnchor.constraint(equalTo: ratingContainerView.bottomAnchor, constant: 16),
            notesContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            notesContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            notesTitleLabel.topAnchor.constraint(equalTo: notesContainerView.topAnchor, constant: 16),
            notesTitleLabel.leadingAnchor.constraint(equalTo: notesContainerView.leadingAnchor, constant: 16),
            notesTitleLabel.trailingAnchor.constraint(equalTo: notesContainerView.trailingAnchor, constant: -16),
            
            prosLabel.topAnchor.constraint(equalTo: notesTitleLabel.bottomAnchor, constant: 12),
            prosLabel.leadingAnchor.constraint(equalTo: notesContainerView.leadingAnchor, constant: 16),
            prosLabel.trailingAnchor.constraint(equalTo: notesContainerView.trailingAnchor, constant: -16),
            
            consLabel.topAnchor.constraint(equalTo: prosLabel.bottomAnchor, constant: 8),
            consLabel.leadingAnchor.constraint(equalTo: notesContainerView.leadingAnchor, constant: 16),
            consLabel.trailingAnchor.constraint(equalTo: notesContainerView.trailingAnchor, constant: -16),
            
            tipsLabel.topAnchor.constraint(equalTo: consLabel.bottomAnchor, constant: 8),
            tipsLabel.leadingAnchor.constraint(equalTo: notesContainerView.leadingAnchor, constant: 16),
            tipsLabel.trailingAnchor.constraint(equalTo: notesContainerView.trailingAnchor, constant: -16),
            
            rawNotesLabel.topAnchor.constraint(equalTo: tipsLabel.bottomAnchor, constant: 8),
            rawNotesLabel.leadingAnchor.constraint(equalTo: notesContainerView.leadingAnchor, constant: 16),
            rawNotesLabel.trailingAnchor.constraint(equalTo: notesContainerView.trailingAnchor, constant: -16),
            rawNotesLabel.bottomAnchor.constraint(equalTo: notesContainerView.bottomAnchor, constant: -16),
            
            // Transactions section
            transactionsContainerView.topAnchor.constraint(equalTo: notesContainerView.bottomAnchor, constant: 16),
            transactionsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transactionsContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            transactionsTitleLabel.topAnchor.constraint(equalTo: transactionsContainerView.topAnchor, constant: 16),
            transactionsTitleLabel.leadingAnchor.constraint(equalTo: transactionsContainerView.leadingAnchor, constant: 16),
            transactionsTitleLabel.trailingAnchor.constraint(equalTo: transactionsContainerView.trailingAnchor, constant: -16),
            
            transactionsTableView.topAnchor.constraint(equalTo: transactionsTitleLabel.bottomAnchor, constant: 12),
            transactionsTableView.leadingAnchor.constraint(equalTo: transactionsContainerView.leadingAnchor, constant: 16),
            transactionsTableView.trailingAnchor.constraint(equalTo: transactionsContainerView.trailingAnchor, constant: -16),
            transactionsTableView.bottomAnchor.constraint(equalTo: transactionsContainerView.bottomAnchor, constant: -16),
            transactionsTableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func loadData() {
        // Reload latest merchant data from Firestore to ensure fresh recent transactions
        guard let merchantId = merchant.id else {
            print("❌ Merchant ID is empty, cannot load latest data")
            return
        }
        
        print("🔄 Reloading merchant detail, merchantId: \(merchantId)")
        
        DataManager.shared.fetchMerchantById(merchantId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedMerchant):
                    print("✅ Successfully fetched latest merchant data, recent transactions: \(updatedMerchant.recentTransactions.count)")
                    self?.merchant = updatedMerchant
                    
                    // Convert RecentTransaction to Transaction for existing UI
                    self?.transactions = updatedMerchant.recentTransactions.map { recentTransaction in
                        Transaction(
                            userId: updatedMerchant.userId,
                            amount: recentTransaction.amount,
                            type: recentTransaction.type,
                            categoryId: recentTransaction.categoryId,
                            categoryName: recentTransaction.categoryName,
                            merchantId: updatedMerchant.id,
                            merchantName: updatedMerchant.merchantDisplayName,
                            description: nil,
                            date: recentTransaction.date
                        )
                    }
                    
                    // Update UI
                    self?.updateMerchantInfo()
                    self?.transactionsTableView.reloadData()
                    
                case .failure(let error):
                    print("❌ Failed to fetch latest merchant data: \(error.localizedDescription)")
                    // Fallback to merchant passed into the initializer
                    self?.transactions = self?.merchant.recentTransactions.map { recentTransaction in
                        Transaction(
                            userId: self?.merchant.userId ?? "",
                            amount: recentTransaction.amount,
                            type: recentTransaction.type,
                            categoryId: recentTransaction.categoryId,
                            categoryName: recentTransaction.categoryName,
                            merchantId: self?.merchant.id,
                            merchantName: self?.merchant.merchantDisplayName ?? "",
                            description: nil,
                            date: recentTransaction.date
                        )
                    } ?? []
                    self?.transactionsTableView.reloadData()
                }
            }
        }
    }
    
    private func updateMerchantInfo() {
        // Basic merchant info
        merchantNameLabel.text = merchant.merchantDisplayName
        merchantCategoryLabel.text = merchant.note.category ?? "Uncategorized"
        merchantIconLabel.text = String(merchant.merchantDisplayName.prefix(1)).uppercased()
        
        // Stats
        visitCountView.configure(
            title: "Visits",
            value: "\(merchant.stats.visitCount)",
            color: .systemBlue
        )
        
        totalSpentView.configure(
            title: "Total Spent",
            value: String(format: "¥%.2f", merchant.stats.totalSpending),
            color: .systemGreen
        )
        
        let avgSpent = merchant.stats.visitCount > 0 ? merchant.stats.totalSpending / Double(merchant.stats.visitCount) : 0
        avgSpentView.configure(
            title: "Avg per Visit",
            value: String(format: "¥%.2f", avgSpent),
            color: .systemOrange
        )
        
        // Rating
        updateRatingDisplay()
        
        // Notes
        updateNotesDisplay()
    }
    
    private func updateRatingDisplay() {
        // Clear star views
        ratingStarsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let rating = merchant.note.rating {
            ratingLabel.text = "\(rating)/5"
            
            // Filled / empty stars
            for i in 1...5 {
                let starLabel = UILabel()
                starLabel.text = i <= rating ? "★" : "☆"
                starLabel.textColor = i <= rating ? .systemYellow : .systemGray3
                starLabel.font = UIFont.systemFont(ofSize: 16)
                ratingStarsView.addArrangedSubview(starLabel)
            }
        } else {
            ratingLabel.text = "Not rated"
            for _ in 1...5 {
                let starLabel = UILabel()
                starLabel.text = "☆"
                starLabel.textColor = .systemGray3
                starLabel.font = UIFont.systemFont(ofSize: 16)
                ratingStarsView.addArrangedSubview(starLabel)
            }
        }
        
        // Verdict badge
        if let verdict = merchant.note.verdict {
            verdictLabel.text = verdict.displayName
            verdictLabel.textColor = UIColor(hex: verdict.color) ?? .label
            verdictLabel.isHidden = false
        } else {
            // Keep badge hidden if no verdict
            // verdictLabel.isHidden = true
        }
    }
    
    private func updateNotesDisplay() {
        // Pros
        if !merchant.note.pros.isEmpty {
            prosLabel.text = "Pros: " + merchant.note.pros.joined(separator: ", ")
            prosLabel.isHidden = false
        } else {
            // prosLabel.isHidden = true
        }
        
        // Cons
        if !merchant.note.cons.isEmpty {
            consLabel.text = "Cons: " + merchant.note.cons.joined(separator: ", ")
            consLabel.isHidden = false
        } else {
            // consLabel.isHidden = true
        }
        
        // Tips
        if !merchant.note.tips.isEmpty {
            tipsLabel.text = "Tips: " + merchant.note.tips.joined(separator: ", ")
            tipsLabel.isHidden = false
        } else {
            // tipsLabel.isHidden = true
        }
        
        // Raw notes
        if let rawNotes = merchant.note.raw, !rawNotes.isEmpty {
            rawNotesLabel.text = rawNotes
            rawNotesLabel.isHidden = false
        } else {
            // rawNotesLabel.isHidden = true
        }
        
        let hasAnyNotes =
            !merchant.note.pros.isEmpty ||
            !merchant.note.cons.isEmpty ||
            !merchant.note.tips.isEmpty ||
            (merchant.note.raw != nil && !merchant.note.raw!.isEmpty)
        
        // notesContainerView.isHidden = !hasAnyNotes
        _ = hasAnyNotes
    }
    
    @objc private func editMerchantTapped() {
        print("Edit merchant tapped")
        let editViewController = MerchantRatingEditViewController(merchant: merchant)
        editViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: editViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MerchantDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        let transaction = transactions[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        cell.textLabel?.text = String(
            format: "Amount: %.2f  ·  Category: %@  ·  %@",
            transaction.amount,
            transaction.categoryName ?? "",
            formatter.string(from: transaction.date)
        )
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - StatisticCardView
class StatisticCardView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 8
        
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        
        valueLabel.font = UIFont.boldSystemFont(ofSize: 18)
        valueLabel.textColor = UIColor.label
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 1
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

// MARK: - MerchantRatingEditDelegate
extension MerchantDetailViewController: MerchantRatingEditDelegate {
    func didUpdateMerchantRating(_ merchant: Merchant) {
        self.merchant = merchant
        DispatchQueue.main.async {
            self.setupRatingSection()
            self.transactionsTableView.reloadData()
        }
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
