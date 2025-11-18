import Foundation
import FirebaseFirestore
import FirebaseAuth

class DataManager {
    static let shared = DataManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Collections
    private var transactionsCollection: CollectionReference {
        return db.collection("transactions")
    }
    
    private var categoriesCollection: CollectionReference {
        return db.collection("categories")
    }
    
    private var merchantsCollection: CollectionReference {
        return db.collection("merchants")
    }
    
    private var budgetsCollection: CollectionReference {
        return db.collection("budgets")
    }
    
    // MARK: - Transaction Operations
    
    func addTransaction(_ transaction: Transaction, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }

        var transactionData = transaction
        transactionData.userId = userId
        
        do {
            let documentRef = try transactionsCollection.addDocument(from: transactionData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // Post notification after successfully saving
                    NotificationCenter.default.post(name: .transactionAdded, object: transactionData)
                }
            }
            completion(.success(documentRef.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchTransactions(limit: Int = 50, completion: @escaping (Result<[Transaction], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        transactionsCollection
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let transactions = try documents.compactMap { document in
                        try document.data(as: Transaction.self)
                    }
                    // Sort and limit on the client side
                    let sortedTransactions = transactions.sorted { $0.date > $1.date }
                    let limitedTransactions = Array(sortedTransactions.prefix(limit))
                    completion(.success(limitedTransactions))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func fetchTransactions(for period: StatisticsPeriod, completion: @escaping (Result<[Transaction], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        let (startDate, endDate) = getDateRange(for: period)
        
        transactionsCollection
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let transactions = try documents.compactMap { document in
                        try document.data(as: Transaction.self)
                    }
                    // Filter by date and sort on the client side
                    let filteredTransactions = transactions.filter { transaction in
                        return transaction.date >= startDate && transaction.date <= endDate
                    }
                    let sortedTransactions = filteredTransactions.sorted { $0.date > $1.date }
                    completion(.success(sortedTransactions))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func updateTransaction(_ transaction: Transaction, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let transactionId = transaction.id else {
            completion(.failure(DataError.invalidTransactionId))
            return
        }
        
        var updatedTransaction = transaction
        updatedTransaction.updatedAt = Date()
        
        do {
            try transactionsCollection.document(transactionId).setData(from: updatedTransaction) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                    NotificationCenter.default.post(name: .transactionUpdated, object: updatedTransaction)
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteTransaction(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        transactionsCollection.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
                NotificationCenter.default.post(name: .transactionDeleted, object: id)
            }
        }
    }
    
    // MARK: - Category Operations
    
    func initializeDefaultCategories(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        // Check whether default categories have already been initialized
        categoriesCollection
            .whereField("userId", isEqualTo: userId)
            .whereField("isDefault", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // If default categories already exist, no need to re-initialize
                if let documents = snapshot?.documents, !documents.isEmpty {
                    completion(.success(()))
                    return
                }
                
                // Initialize default categories
                self?.addDefaultCategories(userId: userId, completion: completion)
            }
    }
    
    private func addDefaultCategories(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let allCategories = Category.defaultCategories
        let group = DispatchGroup()
        var errors: [Error] = []
        
        for category in allCategories {
            group.enter()
            var categoryWithUser = category
            categoryWithUser.userId = userId
            
            do {
                try categoriesCollection.addDocument(from: categoryWithUser) { error in
                    if let error = error {
                        errors.append(error)
                    }
                    group.leave()
                }
            } catch {
                errors.append(error)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(()))
                NotificationCenter.default.post(name: .categoriesUpdated, object: nil)
            } else {
                completion(.failure(errors.first!))
            }
        }
    }
    
    func fetchCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        categoriesCollection
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let categories = try documents.compactMap { document in
                        try document.data(as: Category.self)
                    }
                    completion(.success(categories))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func addCategory(_ category: Category, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        var categoryWithUser = category
        categoryWithUser.userId = userId
        
        do {
            let documentRef = try categoriesCollection.addDocument(from: categoryWithUser) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    NotificationCenter.default.post(name: .categoriesUpdated, object: categoryWithUser)
                }
            }
            completion(.success(documentRef.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteCategory(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        categoriesCollection.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
                NotificationCenter.default.post(name: .categoriesUpdated, object: nil)
            }
        }
    }
    
    // MARK: - Merchant Operations
    
    func fetchMerchants(searchText: String = "", completion: @escaping (Result<[Merchant], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        var query: Query = merchantsCollection
            .whereField("userId", isEqualTo: userId)
            .order(by: "stats.visitCount", descending: true)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                var merchants = try documents.compactMap { document in
                    try document.data(as: Merchant.self)
                }
                
                // If search text is provided, filter locally
                if !searchText.isEmpty {
                    merchants = merchants.filter { merchant in
                        merchant.merchantDisplayName.localizedCaseInsensitiveContains(searchText) ||
                        merchant.merchantKey.localizedCaseInsensitiveContains(searchText) ||
                        (merchant.note.category?.localizedCaseInsensitiveContains(searchText) ?? false)
                    }
                }
                
                completion(.success(merchants))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func addMerchant(_ merchant: Merchant, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        var merchantWithUser = merchant
        merchantWithUser.userId = userId
        
        do {
            let documentRef = try merchantsCollection.addDocument(from: merchantWithUser) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    NotificationCenter.default.post(name: .merchantsUpdated, object: merchantWithUser)
                }
            }
            completion(.success(documentRef.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateMerchant(_ merchant: Merchant, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let merchantId = merchant.id else {
            completion(.failure(DataError.invalidTransactionId))
            return
        }
        
        var updatedMerchant = merchant
        updatedMerchant.updatedAt = Date()
        
        do {
            try merchantsCollection.document(merchantId).setData(from: updatedMerchant) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    NotificationCenter.default.post(name: .merchantsUpdated, object: updatedMerchant)
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteMerchant(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        merchantsCollection.document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                NotificationCenter.default.post(name: .merchantsUpdated, object: nil)
                completion(.success(()))
            }
        }
    }
    
    func fetchMerchantById(_ merchantId: String, completion: @escaping (Result<Merchant, Error>) -> Void) {
        print(" Start fetching merchant, ID: \(merchantId)")
        
        merchantsCollection.document(merchantId).getDocument { document, error in
            if let error = error {
                print("Failed to fetch merchant document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                print("Merchant document does not exist")
                completion(.failure(DataError.dataCorrupted))
                return
            }
            
            do {
                let merchant = try document.data(as: Merchant.self)
                print("Successfully parsed merchant, recent transaction count: \(merchant.recentTransactions.count)")
                completion(.success(merchant))
            } catch {
                print("Failed to parse merchant data: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func findOrCreateMerchant(merchantKey: String, merchantDisplayName: String, completion: @escaping (Result<Merchant, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(DataError.userNotAuthenticated))
            return
        }
        
        // First try to find an existing merchant
        merchantsCollection
            .whereField("userId", isEqualTo: userId)
            .whereField("merchantKey", isEqualTo: merchantKey)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // If found, return the first matched merchant
                if let documents = snapshot?.documents, !documents.isEmpty {
                    do {
                        if let existingMerchant = try documents.first?.data(as: Merchant.self) {
                            completion(.success(existingMerchant))
                            return
                        }
                    } catch {
                        completion(.failure(error))
                        return
                    }
                }
                
                // If not found, create a new merchant
                let newMerchant = Merchant(userId: userId, merchantKey: merchantKey, merchantDisplayName: merchantDisplayName)
                self?.addMerchant(newMerchant) { result in
                    switch result {
                    case .success(let merchantId):
                        var merchantWithId = newMerchant
                        merchantWithId.id = merchantId
                        completion(.success(merchantWithId))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
    }
        
    // Update merchant's recent transactions list
    func updateMerchantRecentTransactions(
        merchantId: String,
        transactionId: String,
        amount: Double,
        date: Date,
        categoryName: String,
        categoryId: String,
        type: Transaction.TransactionType,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("Start updating merchant recent transactions - merchantId: \(merchantId), transactionId: \(transactionId)")
        let merchantRef = merchantsCollection.document(merchantId)
        
        merchantRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Failed to fetch merchant document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists,
                  var merchant = try? document.data(as: Merchant.self) else {
                print("Merchant does not exist or parsing failed - merchantId: \(merchantId)")
                completion(.failure(NSError(
                    domain: "DataManager",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Merchant not found"]
                )))
                return
            }
            
            print("Current merchant recent transaction count: \(merchant.recentTransactions.count)")
            
            // Create new recent transaction
            let recentTransaction = RecentTransaction(
                id: transactionId,
                amount: amount,
                date: date,
                categoryName: categoryName,
                categoryId: categoryId,
                type: type
            )
            print("Created new recent transaction: amount=\(amount), category=\(categoryName), type=\(type.displayName)")
            
            // Remove existing transaction with same id (if updating)
            let beforeCount = merchant.recentTransactions.count
            merchant.recentTransactions.removeAll { $0.id == transactionId }
            let afterRemoveCount = merchant.recentTransactions.count
            if beforeCount != afterRemoveCount {
                print("Removed existing transaction, count changed from \(beforeCount) to \(afterRemoveCount)")
            }
            
            // Insert new transaction at the beginning
            merchant.recentTransactions.insert(recentTransaction, at: 0)
            print("Added new transaction at the beginning, current count: \(merchant.recentTransactions.count)")
            
            // Keep at most 5 recent transactions
            if merchant.recentTransactions.count > 5 {
                merchant.recentTransactions = Array(merchant.recentTransactions.prefix(5))
                print("Trimmed to first 5 records, final count: \(merchant.recentTransactions.count)")
            }
            
            merchant.updatedAt = Date()
            
            // Update stats
            merchant.stats.totalSpending += amount
            merchant.stats.visitCount += 1
            merchant.stats.lastVisitDate = date
            merchant.updatedAt = Date()

            do {
                try merchantRef.setData(from: merchant) { error in
                    if let error = error {
                        print("Failed to save merchant data: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("Successfully updated merchant recent transactions, final count: \(merchant.recentTransactions.count)")
                        completion(.success(()))
                        NotificationCenter.default.post(name: .merchantsUpdated, object: nil)
                    }
                }
            } catch {
                print("Failed to serialize merchant data: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
        
    // MARK: - Statistics Operations
    
    func calculateStatistics(for period: StatisticsPeriod, completion: @escaping (Result<TransactionStatistics, Error>) -> Void) {
        fetchTransactions(for: period) { result in
            switch result {
            case .success(let transactions):
                let statistics = self.processTransactionStatistics(transactions, period: period)
                completion(.success(statistics))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func processTransactionStatistics(_ transactions: [Transaction], period: StatisticsPeriod) -> TransactionStatistics {
        let totalIncome = transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        let totalExpense = transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        let netAmount = totalIncome - totalExpense
        
        // Category breakdown
        let categoryBreakdown = calculateCategoryBreakdown(transactions)
        
        // Monthly trend
        let monthlyTrend = calculateMonthlyTrend(transactions)
        
        return TransactionStatistics(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            netAmount: netAmount,
            transactionCount: transactions.count,
            categoryBreakdown: categoryBreakdown,
            monthlyTrend: monthlyTrend,
            period: period
        )
    }
    
    private func calculateCategoryBreakdown(_ transactions: [Transaction]) -> [CategoryStatistic] {
        let groupedTransactions = Dictionary(grouping: transactions) { $0.categoryId }
        let totalAmount = transactions.reduce(0) { $0 + $1.amount }
        
        return groupedTransactions.compactMap { (categoryId, categoryTransactions) in
            guard let firstTransaction = categoryTransactions.first else { return nil }
            
            let categoryAmount = categoryTransactions.reduce(0) { $0 + $1.amount }
            let percentage = totalAmount > 0 ? categoryAmount / totalAmount : 0
            
            return CategoryStatistic(
                categoryId: categoryId,
                categoryName: firstTransaction.categoryName ?? "",
                categoryIcon: "📊", // Default icon; ideally read from category data
                categoryColor: firstTransaction.type.color,
                amount: categoryAmount,
                percentage: percentage,
                transactionCount: categoryTransactions.count,
                type: firstTransaction.type
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private func calculateMonthlyTrend(_ transactions: [Transaction]) -> [MonthlyStatistic] {
        let calendar = Calendar.current
        let groupedByMonth = Dictionary(grouping: transactions) { transaction in
            calendar.dateInterval(of: .month, for: transaction.date)?.start ?? transaction.date
        }
        
        return groupedByMonth.compactMap { (monthStart, monthTransactions) in
            let income = monthTransactions
                .filter { $0.type == .income }
                .reduce(0) { $0 + $1.amount }
            
            let expense = monthTransactions
                .filter { $0.type == .expense }
                .reduce(0) { $0 + $1.amount }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            
            return MonthlyStatistic(
                month: formatter.string(from: monthStart),
                income: income,
                expense: expense,
                net: income - expense,
                date: monthStart
            )
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Helper Methods
    
    private func getDateRange(for period: StatisticsPeriod) -> (Date, Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .day:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return (startOfDay, endOfDay)
            
        case .week:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
            return (startOfWeek, endOfWeek)
            
        case .month:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            return (startOfMonth, endOfMonth)
            
        case .year:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
            return (startOfYear, endOfYear)
        }
    }
}

// MARK: - Data Errors
enum DataError: LocalizedError {
    case userNotAuthenticated
    case invalidTransactionId
    case networkError
    case dataCorrupted
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .invalidTransactionId:
            return "Invalid transaction ID"
        case .networkError:
            return "Network connection error"
        case .dataCorrupted:
            return "Data is corrupted"
        }
    }
}
