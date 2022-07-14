//
//  TransactionListViewModel.swift
//  ExpenseTracker
//
//  Created by João Carlos Magalhães on 14/07/22.
//

import Foundation
import Combine

final class TransactionListViewModel: ObservableObject {
    // ObservableObject is part of the Combine framework that turns any object into a publisher and will notify its subscribers of its state changes, so they can refresh their views.
    
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getTransactions()
    }
    
    func getTransactions() {
        guard let url = URL(string: "http://designcode.io/data/transaction.json") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    dump(response)
                    throw URLError(.badServerResponse)
                }

                return data
            }
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching transactions", error.localizedDescription)
                case .finished:
                    print("Finished fetching transactions")
                }
            } receiveValue: { [weak self] result in
                self?.transactions = result
                
            }
            .store(in: &cancellables)
    }
}
