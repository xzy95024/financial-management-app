//
//  StatisticsViewController.swift
//  Financial Management
//
//  Created by Ziyang Xu on 11/18/25.
//

import UIKit
import DGCharts

class StatisticsViewController: UIViewController, ChartViewDelegate {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Period segmented control
    private let periodSegmentedControl = UISegmentedControl(items: ["This Week", "This Month", "This Year"])
    
    // Overview card
    private let overviewCardView = UIView()
    private let totalIncomeLabel = UILabel()
    private let totalExpenseLabel = UILabel()
    private let netIncomeLabel = UILabel()
    
    // Income & expense trend chart
    private let trendChartView = UIView()
    private let trendTitleLabel = UILabel()
    private var barChartView: BarChartView!
    
    // Category statistics
    private let categoryStatsView = UIView()
    private let categoryTitleLabel = UILabel()
    private let categoryTableView = UITableView()
    
    // MARK: - Properties
    private var currentPeriod: StatisticsPeriod = .month
    private var statistics: TransactionStatistics?
    private var monthlyData: [MonthlyStatistic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupData()
        loadStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        title = "Statistics"
        
        // Scroll view
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Period segmented control
        periodSegmentedControl.selectedSegmentIndex = 1 // Default: "This Month"
        periodSegmentedControl.backgroundColor = UIColor.systemBackground
        periodSegmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        periodSegmentedControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        contentView.addSubview(periodSegmentedControl)
        
        // Overview card
        setupOverviewCard()
        
        // Trend chart
        setupTrendChart()
        
        // Category statistics
        setupCategoryStats()
    }
    
    private func setupOverviewCard() {
        overviewCardView.backgroundColor = UIColor.systemBackground
        overviewCardView.layer.cornerRadius = 16
        overviewCardView.layer.shadowColor = UIColor.black.cgColor
        overviewCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        overviewCardView.layer.shadowRadius = 8
        overviewCardView.layer.shadowOpacity = 0.1
        contentView.addSubview(overviewCardView)
        
        // Total income
        totalIncomeLabel.text = "Total Income\n¥0.00"
        totalIncomeLabel.numberOfLines = 2
        totalIncomeLabel.textAlignment = .center
        totalIncomeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        totalIncomeLabel.textColor = UIColor.systemGreen
        overviewCardView.addSubview(totalIncomeLabel)
        
        // Total expense
        totalExpenseLabel.text = "Total Expense\n¥0.00"
        totalExpenseLabel.numberOfLines = 2
        totalExpenseLabel.textAlignment = .center
        totalExpenseLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        totalExpenseLabel.textColor = UIColor.systemRed
        overviewCardView.addSubview(totalExpenseLabel)
        
        // Net income
        netIncomeLabel.text = "Net Income\n¥0.00"
        netIncomeLabel.numberOfLines = 2
        netIncomeLabel.textAlignment = .center
        netIncomeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        netIncomeLabel.textColor = UIColor.label
        overviewCardView.addSubview(netIncomeLabel)
    }
    
    private func setupTrendChart() {
        trendChartView.backgroundColor = UIColor.systemBackground
        trendChartView.layer.cornerRadius = 16
        trendChartView.layer.shadowColor = UIColor.black.cgColor
        trendChartView.layer.shadowOffset = CGSize(width: 0, height: 2)
        trendChartView.layer.shadowRadius = 8
        trendChartView.layer.shadowOpacity = 0.1
        contentView.addSubview(trendChartView)
        
        trendTitleLabel.text = "Income & Expense Trend"
        trendTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        trendTitleLabel.textColor = UIColor.label
        trendChartView.addSubview(trendTitleLabel)
        
        // Initialize DGCharts bar chart
        barChartView = BarChartView()
        barChartView.backgroundColor = UIColor.systemGray6
        barChartView.layer.cornerRadius = 12
        barChartView.delegate = self
        
        // Chart style
        barChartView.chartDescription.enabled = false
        barChartView.dragEnabled = false
        barChartView.setScaleEnabled(false)
        barChartView.pinchZoomEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = true
        barChartView.legend.horizontalAlignment = .center
        barChartView.legend.verticalAlignment = .bottom
        barChartView.legend.orientation = .horizontal
        barChartView.legend.drawInside = false
        
        // X axis
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = UIColor.secondaryLabel
        
        // Y axis
        let leftAxis = barChartView.leftAxis
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor.systemGray4
        leftAxis.labelTextColor = UIColor.secondaryLabel
        leftAxis.axisMinimum = 0
        
        trendChartView.addSubview(barChartView)
    }
    
    private func setupCategoryStats() {
        categoryStatsView.backgroundColor = UIColor.systemBackground
        categoryStatsView.layer.cornerRadius = 16
        categoryStatsView.layer.shadowColor = UIColor.black.cgColor
        categoryStatsView.layer.shadowOffset = CGSize(width: 0, height: 2)
        categoryStatsView.layer.shadowRadius = 8
        categoryStatsView.layer.shadowOpacity = 0.1
        contentView.addSubview(categoryStatsView)
        
        categoryTitleLabel.text = "Category Breakdown"
        categoryTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        categoryTitleLabel.textColor = UIColor.label
        categoryStatsView.addSubview(categoryTitleLabel)
        
        categoryTableView.backgroundColor = UIColor.clear
        categoryTableView.separatorStyle = .none
        categoryTableView.isScrollEnabled = false
        categoryTableView.register(CategoryStatisticCell.self, forCellReuseIdentifier: "CategoryStatisticCell")
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryStatsView.addSubview(categoryTableView)
    }
    
    private func setupConstraints() {
        // Disable autoresizing-mask translation
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        periodSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        overviewCardView.translatesAutoresizingMaskIntoConstraints = false
        totalIncomeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalExpenseLabel.translatesAutoresizingMaskIntoConstraints = false
        netIncomeLabel.translatesAutoresizingMaskIntoConstraints = false
        trendChartView.translatesAutoresizingMaskIntoConstraints = false
        trendTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        categoryStatsView.translatesAutoresizingMaskIntoConstraints = false
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Period segmented control
            periodSegmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            periodSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            periodSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            periodSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Overview card
            overviewCardView.topAnchor.constraint(equalTo: periodSegmentedControl.bottomAnchor, constant: 16),
            overviewCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            overviewCardView.heightAnchor.constraint(equalToConstant: 100),
            
            // Overview labels
            totalIncomeLabel.leadingAnchor.constraint(equalTo: overviewCardView.leadingAnchor, constant: 16),
            totalIncomeLabel.centerYAnchor.constraint(equalTo: overviewCardView.centerYAnchor),
            totalIncomeLabel.widthAnchor.constraint(equalTo: overviewCardView.widthAnchor, multiplier: 0.3),
            
            totalExpenseLabel.centerXAnchor.constraint(equalTo: overviewCardView.centerXAnchor),
            totalExpenseLabel.centerYAnchor.constraint(equalTo: overviewCardView.centerYAnchor),
            totalExpenseLabel.widthAnchor.constraint(equalTo: overviewCardView.widthAnchor, multiplier: 0.3),
            
            netIncomeLabel.trailingAnchor.constraint(equalTo: overviewCardView.trailingAnchor, constant: -16),
            netIncomeLabel.centerYAnchor.constraint(equalTo: overviewCardView.centerYAnchor),
            netIncomeLabel.widthAnchor.constraint(equalTo: overviewCardView.widthAnchor, multiplier: 0.3),
            
            // Trend chart container
            trendChartView.topAnchor.constraint(equalTo: overviewCardView.bottomAnchor, constant: 16),
            trendChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trendChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trendChartView.heightAnchor.constraint(equalToConstant: 250),
            
            trendTitleLabel.topAnchor.constraint(equalTo: trendChartView.topAnchor, constant: 16),
            trendTitleLabel.leadingAnchor.constraint(equalTo: trendChartView.leadingAnchor, constant: 16),
            trendTitleLabel.trailingAnchor.constraint(equalTo: trendChartView.trailingAnchor, constant: -16),
            
            barChartView.topAnchor.constraint(equalTo: trendTitleLabel.bottomAnchor, constant: 12),
            barChartView.leadingAnchor.constraint(equalTo: trendChartView.leadingAnchor, constant: 16),
            barChartView.trailingAnchor.constraint(equalTo: trendChartView.trailingAnchor, constant: -16),
            barChartView.bottomAnchor.constraint(equalTo: trendChartView.bottomAnchor, constant: -16),
            
            // Category stats container
            categoryStatsView.topAnchor.constraint(equalTo: trendChartView.bottomAnchor, constant: 16),
            categoryStatsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryStatsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryStatsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            categoryTitleLabel.topAnchor.constraint(equalTo: categoryStatsView.topAnchor, constant: 16),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: categoryStatsView.leadingAnchor, constant: 16),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: categoryStatsView.trailingAnchor, constant: -16),
            
            categoryTableView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 12),
            categoryTableView.leadingAnchor.constraint(equalTo: categoryStatsView.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: categoryStatsView.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: categoryStatsView.bottomAnchor, constant: -16),
            categoryTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupData() {
        // Table view dataSource / delegate are already set in setupCategoryStats()
        // This is left here in case you want to extend initialization logic.
    }
    
    // MARK: - Period Selection
    
    @objc private func periodChanged() {
        switch periodSegmentedControl.selectedSegmentIndex {
        case 0:
            currentPeriod = .week
        case 1:
            currentPeriod = .month
        case 2:
            currentPeriod = .year
        default:
            currentPeriod = .month
        }
        loadStatistics()
    }
    
    // MARK: - Data Loading
    
    private func loadStatistics() {
        DataManager.shared.calculateStatistics(for: currentPeriod) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statistics):
                    self?.statistics = statistics
                    self?.updateUI(with: statistics)
                case .failure(let error):
                    print("StatisticsViewController: Failed to load statistics data: \(error.localizedDescription)")
                    self?.updateUI(with: nil)
                }
            }
        }
        
        // Load trend data for the chart
        loadTrendData()
    }
    
    private func loadTrendData() {
        // Load corresponding trend data based on the current period
        switch currentPeriod {
        case .day:
            // Today – DataManager should calculate hourly or daily trend
            loadDailyData()
        case .week:
            // This week – daily data
            loadDailyData()
        case .month:
            // This month – daily data
            loadDailyData()
        case .year:
            // This year – monthly data
            loadMonthlyData()
        }
    }
    
    private func loadDailyData() {
        // Fetch data for the current period; DataManager provides daily trend as monthlyTrend array
        DataManager.shared.calculateStatistics(for: currentPeriod) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statistics):
                    self?.monthlyData = statistics.monthlyTrend
                    self?.updateTrendChart()
                case .failure(let error):
                    print("StatisticsViewController: Failed to load daily data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadMonthlyData() {
        // Fetch yearly statistics; DataManager should aggregate by month into monthlyTrend
        DataManager.shared.calculateStatistics(for: .year) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statistics):
                    self?.monthlyData = statistics.monthlyTrend
                    self?.updateTrendChart()
                case .failure(let error):
                    print("StatisticsViewController: Failed to load monthly data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI(with statistics: TransactionStatistics?) {
        guard let statistics = statistics else {
            totalIncomeLabel.text = "Total Income\n¥0.00"
            totalExpenseLabel.text = "Total Expense\n¥0.00"
            netIncomeLabel.text = "Net Income\n¥0.00"
            categoryTableView.reloadData()
            return
        }
        
        // Overview card
        totalIncomeLabel.text = String(format: "Total Income\n¥%.2f", statistics.totalIncome)
        totalExpenseLabel.text = String(format: "Total Expense\n¥%.2f", statistics.totalExpense)
        netIncomeLabel.text = String(format: "Net Income\n¥%.2f", statistics.netAmount)
        
        // Category breakdown
        categoryTableView.reloadData()
        
        // Adjust table height constraint based on number of rows
        let rowCount = statistics.categoryBreakdown.count
        let tableHeight = CGFloat(rowCount * 60)
        categoryTableView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = max(tableHeight, 60) // at least one row height
            }
        }
    }
    
    private func updateTrendChart() {
        guard !monthlyData.isEmpty else {
            barChartView.data = nil
            return
        }
        
        var incomeEntries: [BarChartDataEntry] = []
        var expenseEntries: [BarChartDataEntry] = []
        var xAxisLabels: [String] = []
        
        for (index, data) in monthlyData.enumerated() {
            incomeEntries.append(BarChartDataEntry(x: Double(index), y: data.income))
            expenseEntries.append(BarChartDataEntry(x: Double(index), y: data.expense))
            
            // X axis label formatting based on current period
            switch currentPeriod {
            case .week:
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd"
                xAxisLabels.append(formatter.string(from: data.date))
            case .month:
                let formatter = DateFormatter()
                formatter.dateFormat = "dd"
                xAxisLabels.append(formatter.string(from: data.date))
            case .year:
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                xAxisLabels.append(formatter.string(from: data.date))
            case .day:
                // Not used in the current UI, but you can customize if needed
                break
            }
        }
        
        // Income dataset
        let incomeDataSet = BarChartDataSet(entries: incomeEntries, label: "Income")
        incomeDataSet.colors = [UIColor.systemGreen]
        incomeDataSet.valueTextColor = UIColor.label
        incomeDataSet.valueFont = UIFont.systemFont(ofSize: 10)
        
        // Expense dataset
        let expenseDataSet = BarChartDataSet(entries: expenseEntries, label: "Expense")
        expenseDataSet.colors = [UIColor.systemRed]
        expenseDataSet.valueTextColor = UIColor.label
        expenseDataSet.valueFont = UIFont.systemFont(ofSize: 10)
        
        // Chart data
        let chartData = BarChartData(dataSets: [incomeDataSet, expenseDataSet])
        chartData.barWidth = 0.35
        
        // Grouped bars configuration
        let groupSpace = 0.1
        let barSpace = 0.05
        chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        
        // X axis labels
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        barChartView.xAxis.setLabelCount(xAxisLabels.count, force: false)
        
        // Apply data and animate
        barChartView.data = chartData
        barChartView.animate(yAxisDuration: 1.0)
    }
}

// MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statistics?.categoryBreakdown.count ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CategoryStatisticCell",
            for: indexPath
        ) as! CategoryStatisticCell
        
        if let categoryStats = statistics?.categoryBreakdown {
            let categoryStat = categoryStats[indexPath.row]
            cell.configure(with: categoryStat)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension StatisticsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 60
    }
}
