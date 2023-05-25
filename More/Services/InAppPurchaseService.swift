//
//  InAppPurchaseService.swift
//  More
//
//  Created by Luko Gjenero on 02/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import Firebase
import StoreKit

class InAppPurchaseService {
    
    struct Notifications {
        static let ProductsLoaded = NSNotification.Name(rawValue: "com.more.products.loaded")
    }
    
    static let shared = InAppPurchaseService()
    
    init() {
        initialize()
    }
    
    private (set) var products: Set<Product> = []
    private var listener: ListenerRegistration?
    
    private func initialize() {
        
        // User login / logout
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: ProfileService.Notifications.ProfileLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: ProfileService.Notifications.ProfileLogout, object: nil)

        login()
        
//        IAPHelper.shared.restoreProductsWithCompletion { (queue, error) in
//            queue.transactions.forEach { IAPHelper.shared.finishTransaction($0) }
//        }
    }
    
    @objc private func login() {
        guard ProfileService.shared.profile != nil else { return }
        
        listener =
        Firestore.firestore().collection("products")
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let snapshot = snapshot else { return }
                snapshot.documentChanges.forEach { diff in
                    if let product = Product.fromSnapshot(diff.document) {
                        if (diff.type == .added) {
                            self?.products.insert(product)
                        }
                        if (diff.type == .modified) {
                            self?.products.remove(product)
                            self?.products.insert(product)
                        }
                        if (diff.type == .removed) {
                            self?.products.remove(product)
                        }
                    }
                }
                self?.updateSKProducts()
            }
    }
    
    @objc private func logout() {
        listener?.remove()
        listener = nil
    }
    
    private func updateSKProducts() {
        IAPHelper.shared.productIdentifiers = Set(products.map { $0.sku })
        IAPHelper.shared.requestProductsWithCompletion { [weak self] in
            NotificationCenter.default.post(name: Notifications.ProductsLoaded, object: self)
        }
    }
    
    // MARK: - api
    
    func product(for tier: String) -> Product? {
        return products.first(where: { $0.id == tier })
    }
    
    func skProduct(for tier: String) -> SKProduct? {
        if let product = product(for: tier) {
            return IAPHelper.shared.products.first(where: { $0.productIdentifier == product.sku })
        }
        return nil
    }
    
    func purchase(tier: String, complete: ((_ success: Bool, _ transaction: SKPaymentTransaction?, _ errorMsg: String?)->())?) {
        guard ProfileService.shared.profile != nil else {
            complete?(false, nil, "Not logged in")
            return
        }
        
        guard let skProduct = skProduct(for: tier) else {
            complete?(false, nil, "Unknown product")
            return
        }
        
//        complete?(true, nil)
//        return
        
        IAPHelper.shared.buyProduct(skProduct) { [weak self] (transaction) in
            if transaction.transactionState == .purchased {
                self?.purchased(skProduct, transaction, complete)
            } else {
                self?.purchaseFailed(transaction, complete)
            }
        }
    }
    
    private func purchaseFailed(_ transaction: SKPaymentTransaction, _ complete: ((_ success: Bool, _ transaction: SKPaymentTransaction?, _ errorMsg: String?)->())?) {
        if let error = transaction.error as? SKError, error.code == SKError.paymentCancelled {
            complete?(false, nil, "Purchase cancelled")
        } else {
            complete?(false, nil, "Issue with In app purchase")
        }
    }
    
    private func purchased(_ skProduct: SKProduct,
                           _ transaction: SKPaymentTransaction,
                           _ complete: ((_ success: Bool, _ transaction: SKPaymentTransaction?, _ errorMsg: String?)->())?) {
        
        // --- TEST ---
        complete?(true, transaction, nil)
        return
        //

        var usingTransaction = transaction

        // check if restored
        if usingTransaction.transactionState == .restored,
            let restored = usingTransaction.original {
            usingTransaction = restored
        }

        // receipt
        guard let receipt = getReceipt() else { complete?(false, nil, "Issue with In app purchase"); return }

        // TODO: - validation
        
        complete?(true, transaction, nil)
    }
    
    
    private func getReceipt() -> String? {
        guard
            let url = Bundle.main.appStoreReceiptURL,
            let receiptData: Data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return receiptData.base64EncodedString(options: [])
    }
    
}


/**
 Products loaded from iTunes closure
 */
typealias IAPProductsResponseBlock = () -> Void

/**
 Buy Product completed closure
 - parameter transaction: Store Kit purchae transaction
 */
typealias IAPBuyProductCompleteResponseBlock = (_ transaction: SKPaymentTransaction) -> Void

/**
 Products restore completed closure
 - parameter payment: Store Kit restore purchases payment queue
 - parameter error: Possible Error that might have occured during restoring In app purchases
 */
typealias IAPRestoreProductsCompleteResponseBlock = (_ payment: SKPaymentQueue, _ error: NSError?) -> Void

/// In App Purchse helper object
class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    /// Singleton instance
    static let shared = IAPHelper()

    /// Product identifiers
    var productIdentifiers: Set<String> = [] {
        didSet {
            requestProductsWithCompletion(nil)
        }
    }

    /// Products
    private (set) var products: Set<SKProduct> = []

    /// Closure for processing lingering purchase transactions
    var lingeringProductCompleteBlock: IAPBuyProductCompleteResponseBlock?

    /// buy product callback closure
    private var buyProductCompleteBlock: IAPBuyProductCompleteResponseBlock?

    /// restore purchases callback closure
    private var restoreCompletedBlock: IAPRestoreProductsCompleteResponseBlock?

    /// request products callback closures
    private var requestCompletedBlocks: [IAPProductsResponseBlock] = []

    /// product list is being loaded
    private var requestProductsRetry: Int = 0

    override init() {
        super.init()

        // transaction observer
        SKPaymentQueue.default().add(self)

        // reload on app start
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBackToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    deinit {
        SKPaymentQueue.default().remove(self)
        NotificationCenter.default.removeObserver(self)
    }

    /**
     App is back to foreground trigger action.
     */
    @objc fileprivate func appBackToForeground() {
        if products.count == 0, productIdentifiers.count > 0 {
            requestProductsWithCompletion(nil)
        }
    }

    /**
     Requests Product definitions from iTunes.
     - parameter completion: Completion callback
     */
    func requestProductsWithCompletion(_ completion: IAPProductsResponseBlock?) {
        synced(self) {
            if let block = completion {
                requestCompletedBlocks.append(block)
            }
            requestProductsRetry = 50
        }
        requestProducts()
    }

    /// Requests Product definitions from iTunes.
    private func requestProducts() {
        var proceed = false
        synced(self) {
            requestProductsRetry -= 1
            if requestProductsRetry > 0 {
                proceed = true
            }
        }

        if proceed {
            let request = SKProductsRequest(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        } else {
            clearRequests()
        }
    }

    /**
     Clears current Store Kit request.
     */
    private func clearRequests() {
        synced(self) {
            requestCompletedBlocks.removeAll()
            requestProductsRetry = 0
        }
    }

    /**
     Transaction competed.
     - parameter transaction: Store Kit payment transaction.
     */
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        let block = buyProductCompleteBlock
        buyProductCompleteBlock = nil

        if let block = block {
            block(transaction)
        } else if let block = lingeringProductCompleteBlock {
            block(transaction)
        }
    }

    /**
     Finishes the transaction. To be called when the pruchased itme has been delivered.
     In our case this is called after the receipt has been verified by our backend service.
     - parameter transaction: Store Kit payment transaction.
     */
    func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    /**
     Restores the transaction.
     - parameter transaction: Store Kit payment transaction.
     */
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    /**
     Payment transaction failed.
     - parameter transaction: Store Kit payment transaction.
     */
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)

        let block = buyProductCompleteBlock
        buyProductCompleteBlock = nil
        block?(transaction)
    }

    /**
     Buys an In app purchase product.
     - parameter productIdentifier: Store Kit payment transaction.
     - parameter completion: Purchase completed callback.
     */
    func buyProduct(_ productIdentifier: SKProduct, completion: @escaping IAPBuyProductCompleteResponseBlock) {
        buyProductCompleteBlock = completion
        let payment = SKPayment(product: productIdentifier)
        SKPaymentQueue.default().add(payment)
    }

    /**
     Restores purchased products.
     - parameter completion: Restore completed callback.
     */
    func restoreProductsWithCompletion(_ completion: @escaping IAPRestoreProductsCompleteResponseBlock) {
        restoreCompletedBlock = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - SKProductsRequestDelegate

    func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = Set(response.products)
    }

    func requestDidFinish(_: SKRequest) {
        let skus = productIdentifiers
        let productSkus = products.map { $0.productIdentifier }
        let missing = skus.filter { !productSkus.contains($0) }
        if missing.isEmpty {
            let blocks = requestCompletedBlocks
            for block in blocks {
                block()
            }
            clearRequests()
        } else {
            requestProducts()
        }
    }

    func request(_: SKRequest, didFailWithError _: Error) {
        requestProducts()
    }

    // MARK: - SKPaymentTransactionObserver

    func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completeTransaction(transaction)
            case .failed:
                failedTransaction(transaction)
            case .restored:
                restoreTransaction(transaction)
            default:
                break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        let block = restoreCompletedBlock
        restoreCompletedBlock = nil
        block?(queue, error as NSError?)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let block = restoreCompletedBlock
        restoreCompletedBlock = nil
        block?(queue, nil)
    }

    @available(iOS 11.0, *)
    func paymentQueue(_: SKPaymentQueue, shouldAddStorePayment _: SKPayment, for _: SKProduct) -> Bool {
        return true
    }
}


extension SKProduct {
    
    class func localizePrice(_ price: NSDecimalNumber, withPriceLocale locale: Locale) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.locale = locale
        numberFormatter.currencySymbol = ""

        if let formattedString: String = numberFormatter.string(from: price),
            let currency = (locale as NSLocale).object(forKey: .currencySymbol) as? String {
            return "\(currency)\(formattedString)".trimmingCharacters(in: .whitespaces)
        }
        return ""
    }

    var localizedPrice: String {
        return SKProduct.localizePrice(price, withPriceLocale: priceLocale)
    }

    var localizedCurrency: String {
        return (priceLocale as NSLocale).object(forKey: .currencyCode) as? String ?? ""
    }

    var localizedCurrencySymbol: String {
        return (priceLocale as NSLocale).object(forKey: .currencySymbol) as? String ?? ""
    }

    var localizedIntroductoryPrice: String? {
        if #available(iOS 11.2, *) {
            guard let introPrice = introductoryPrice?.price else { return nil }
            return SKProduct.localizePrice(introPrice, withPriceLocale: priceLocale)
        } else {
            return nil
        }
    }
}
