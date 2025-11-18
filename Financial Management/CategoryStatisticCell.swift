//
//  CategoryStatisticCell.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit

class CategoryStatisticCell: UITableViewCell {
    
    private let categoryIconView = UIView()
    private let categoryNameLabel = UILabel()
    private let amountLabel = UILabel()
    private let percentageLabel = UILabel()
    private let progressView = UIProgressView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        // Category icon
        categoryIconView.backgroundColor = UIColor.systemBlue
        categoryIconView.layer.cornerRadius = 15
        contentView.addSubview(categoryIconView)
        
        // Category name
        categoryNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        categoryNameLabel.textColor = UIColor.label
        contentView.addSubview(categoryNameLabel)
        
        // Amount
        amountLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        amountLabel.textColor = UIColor.label
        amountLabel.textAlignment = .right
        contentView.addSubview(amountLabel)
        
        // Percentage
        percentageLabel.font = UIFont.systemFont(ofSize: 14)
        percentageLabel.textColor = UIColor.secondaryLabel
        percentageLabel.textAlignment = .right
        contentView.addSubview(percentageLabel)
        
        // Progress bar
        progressView.progressTintColor = UIColor.systemBlue
        progressView.trackTintColor = UIColor.systemGray5
        contentView.addSubview(progressView)
    }
    
    private func setupConstraints() {
        categoryIconView.translatesAutoresizingMaskIntoConstraints = false
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Category icon
            categoryIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryIconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 30),
            categoryIconView.heightAnchor.constraint(equalToConstant: 30),
            
            // Category name
            categoryNameLabel.leadingAnchor.constraint(equalTo: categoryIconView.trailingAnchor, constant: 12),
            categoryNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            categoryNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            // Amount
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            // Percentage
            percentageLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
            percentageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Progress bar
            progressView.leadingAnchor.constraint(equalTo: categoryNameLabel.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: percentageLabel.leadingAnchor, constant: -8),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func configure(with categoryStatistic: CategoryStatistic) {
        categoryNameLabel.text = categoryStatistic.categoryName
        amountLabel.text = String(format: "¥%.2f", categoryStatistic.amount)
        percentageLabel.text = String(format: "%.1f%%", categoryStatistic.percentage)
        
        // Set progress bar
        progressView.progress = Float(categoryStatistic.percentage / 100.0)
        
        // Set colors based on category type
        switch categoryStatistic.type {
        case .income:
            categoryIconView.backgroundColor = UIColor.systemGreen
            progressView.progressTintColor = UIColor.systemGreen
        case .expense:
            categoryIconView.backgroundColor = UIColor.systemRed
            progressView.progressTintColor = UIColor.systemRed
        }
    }
}
