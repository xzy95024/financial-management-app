//
//  TransactionTableViewCell.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let categoryIconView = UIView()
    private let categoryLabel = UILabel()
    private let merchantLabel = UILabel()
    private let amountLabel = UILabel()
    private let dateLabel = UILabel()
    
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
        
        // Container view
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        // Category icon
        categoryIconView.backgroundColor = UIColor.systemBlue
        categoryIconView.layer.cornerRadius = 20
        
        // Category label
        categoryLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        categoryLabel.textColor = UIColor.label
        
        // Merchant label
        merchantLabel.font = UIFont.systemFont(ofSize: 14)
        merchantLabel.textColor = UIColor.secondaryLabel
        
        // Amount label
        amountLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        amountLabel.textAlignment = .right
        
        // Date label
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = UIColor.tertiaryLabel
        dateLabel.textAlignment = .right
        
        contentView.addSubview(containerView)
        containerView.addSubview(categoryIconView)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(merchantLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(dateLabel)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        merchantLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Category icon
            categoryIconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            categoryIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 40),
            categoryIconView.heightAnchor.constraint(equalToConstant: 40),
            
            // Category label
            categoryLabel.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 12),
            categoryLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            // Merchant label
            merchantLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            merchantLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            merchantLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),
            
            // Amount label
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            amountLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            // Date label
            dateLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4)
        ])
    }
    
    // MARK: - Configuration
    func configure(with transaction: Transaction) {
        categoryLabel.text = transaction.categoryName
        merchantLabel.text = transaction.merchantName ?? "Unknown merchant"
        amountLabel.text = String(format: "%.2f", transaction.amount)
        
        // Date formatting
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        dateLabel.text = formatter.string(from: transaction.date)
        
        // Color based on type
        if transaction.type == .income {
            amountLabel.textColor = UIColor.systemGreen
        } else {
            amountLabel.textColor = UIColor.systemRed
        }
    }
}
