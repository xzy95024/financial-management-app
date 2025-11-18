//
//  MerchantTableViewCell.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit

class MerchantTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let merchantIconView = UIView()
    private let merchantIconLabel = UILabel()
    private let merchantNameLabel = UILabel()
    private let merchantCategoryLabel = UILabel()
    private let statsStackView = UIStackView()
    private let visitCountLabel = UILabel()
    private let totalSpentLabel = UILabel()
    private let lastVisitLabel = UILabel()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        // Card-style container
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 3
        
        // Merchant icon
        merchantIconView.backgroundColor = UIColor.systemBlue
        merchantIconView.layer.cornerRadius = 20
        
        merchantIconLabel.text = "🏪"
        merchantIconLabel.textAlignment = .center
        merchantIconLabel.font = UIFont.systemFont(ofSize: 20)
        
        // Merchant name
        merchantNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        merchantNameLabel.textColor = UIColor.label
        merchantNameLabel.numberOfLines = 1
        
        // Merchant category
        merchantCategoryLabel.font = UIFont.systemFont(ofSize: 14)
        merchantCategoryLabel.textColor = UIColor.secondaryLabel
        merchantCategoryLabel.numberOfLines = 1
        
        // Stats stack
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 8
        
        // Visit count
        visitCountLabel.font = UIFont.systemFont(ofSize: 12)
        visitCountLabel.textColor = UIColor.systemBlue
        visitCountLabel.textAlignment = .center
        visitCountLabel.numberOfLines = 2
        
        // Total spent
        totalSpentLabel.font = UIFont.systemFont(ofSize: 12)
        totalSpentLabel.textColor = UIColor.systemGreen
        totalSpentLabel.textAlignment = .center
        totalSpentLabel.numberOfLines = 2
        
        // Last visit
        lastVisitLabel.font = UIFont.systemFont(ofSize: 12)
        lastVisitLabel.textColor = UIColor.systemOrange
        lastVisitLabel.textAlignment = .center
        lastVisitLabel.numberOfLines = 2
        
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(merchantIconView)
        merchantIconView.addSubview(merchantIconLabel)
        containerView.addSubview(merchantNameLabel)
        containerView.addSubview(merchantCategoryLabel)
        containerView.addSubview(statsStackView)
        
        statsStackView.addArrangedSubview(visitCountLabel)
        statsStackView.addArrangedSubview(totalSpentLabel)
        statsStackView.addArrangedSubview(lastVisitLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        merchantIconView.translatesAutoresizingMaskIntoConstraints = false
        merchantIconLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Card container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Icon
            merchantIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            merchantIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            merchantIconView.widthAnchor.constraint(equalToConstant: 40),
            merchantIconView.heightAnchor.constraint(equalToConstant: 40),
            
            merchantIconLabel.centerXAnchor.constraint(equalTo: merchantIconView.centerXAnchor),
            merchantIconLabel.centerYAnchor.constraint(equalTo: merchantIconView.centerYAnchor),
            
            // Name
            merchantNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            merchantNameLabel.leadingAnchor.constraint(equalTo: merchantIconView.trailingAnchor, constant: 12),
            merchantNameLabel.trailingAnchor.constraint(equalTo: statsStackView.leadingAnchor, constant: -8),
            
            // Category
            merchantCategoryLabel.topAnchor.constraint(equalTo: merchantNameLabel.bottomAnchor, constant: 4),
            merchantCategoryLabel.leadingAnchor.constraint(equalTo: merchantIconView.trailingAnchor, constant: 12),
            merchantCategoryLabel.trailingAnchor.constraint(equalTo: statsStackView.leadingAnchor, constant: -8),
            
            // Stats
            statsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            statsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            statsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with merchant: Merchant) {
        merchantNameLabel.text = merchant.merchantDisplayName
        merchantCategoryLabel.text = merchant.note.category ?? "Uncategorized"
        
        // Icon color based on merchantKey hash
        let colors: [UIColor] = [
            .systemBlue,
            .systemGreen,
            .systemOrange,
            .systemPurple,
            .systemRed,
            .systemTeal
        ]
        let colorIndex = abs(merchant.merchantKey.hashValue) % colors.count
        merchantIconView.backgroundColor = colors[colorIndex]
        
        // Visits
        let visitCount = merchant.stats.visitCount
        if visitCount > 0 {
            let visitsText = visitCount == 1 ? "Visit" : "Visits"
            visitCountLabel.text = "\(visitCount)\n\(visitsText)"
        } else {
            visitCountLabel.text = "0\nVisits"
        }
        
        // Total spent
        let totalSpent = merchant.stats.totalSpending
        totalSpentLabel.text = String(format: "$%.0f\nTotal spent", totalSpent)
        
        // Last visit
        if let lastVisit = merchant.stats.lastVisitDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            lastVisitLabel.text = "\(formatter.string(from: lastVisit))\nLast visit"
        } else {
            lastVisitLabel.text = "-\nLast visit"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        merchantNameLabel.text = nil
        merchantCategoryLabel.text = nil
        visitCountLabel.text = nil
        totalSpentLabel.text = nil
        lastVisitLabel.text = nil
    }
}
