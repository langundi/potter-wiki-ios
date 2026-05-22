//
//  NetworkMonitor.swift
//  PotterWiki
//
//  Created by Ziqa on 21/05/26.
//

import Network

final class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    init() { }
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.potterwiki.networkmonitor")
    
    private(set) var isConnected: Bool = true
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
