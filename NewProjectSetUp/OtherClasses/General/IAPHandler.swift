//
//  IAPHandler.swift
//  FitFin
//
//  Created by MAC OS 16 on 27/01/22.
//

import Foundation
import UIKit
import StoreKit
enum IAPModel: String,CaseIterable {
    case monthly = "com.app.itpath.monthlyCharged"
    case yearly = "com.app.itpath.yearlyCharged"
}
final class IAPHandler: NSObject {
    
    //MARK: - Declare variable
    var arrProduct: [SKProduct] = []
    static var shared = IAPHandler()

}

//MARK: Fetch Product
extension IAPHandler : SKProductsRequestDelegate {
    
    func fetchProduct(){
        let fetchRequest = SKProductsRequest(productIdentifiers: Set(IAPModel.allCases.map({ product in
            product.rawValue
        })))
        fetchRequest.delegate = self
        fetchRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        arrProduct = response.products
    }
}

//MARK: - Make payment and payment status
extension IAPHandler: SKPaymentTransactionObserver {
    
    func makePayment(typeIAPModel: IAPModel){
        guard SKPaymentQueue.canMakePayments() else {return}
        guard let skProduct = arrProduct.first(where: { product in
            product.productIdentifier == typeIAPModel.rawValue
        })else {return}
        let payment = SKPayment(product: skProduct)
        SKPaymentQueue.default().add(payment)
        SKPaymentQueue.default().add(self)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchasing:
                print("purchasing")
            case .purchased:
                print("purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            case .failed,.deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            case .restored:
                print("restore")
            @unknown default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            }
        }
    }
}
