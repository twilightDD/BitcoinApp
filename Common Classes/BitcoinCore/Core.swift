//
//  SOXSocketIO_BitcoinDE_NewCore_Swift.swift
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.21.
//  Copyright © 2021 2sox / Peter Hauke. All rights reserved.
//

import Foundation

import SocketIO

@objc
open class Core: NSObject {
    
//    private(set) static var shared = SOXSocketIO_BitcoinDE_NewCore_Swift()
    private static var socketManager: SocketManager?
    
    @objc
    open class func testMe() {
//        return
        
        
        guard let socketURL = URL.init(string: "https://ws-mig.bitcoin.de:443") else {
            fatalError() }
        
        let socketIOClientConfiguration = SocketIOClientConfiguration()
        
        Core.socketManager = SocketManager.init(socketURL: socketURL,
                                                                               config: socketIOClientConfiguration)
        
        guard let socketManager = Core.socketManager else {
            fatalError() }
        
        let newSocket = socketManager.socket(forNamespace: "/market")
        newSocket.onAny { (socketAnyEvent) in
            let eventName = socketAnyEvent.event
            if eventName != "connect"
                && eventName != "add_order"
                && eventName != "remove_order"
            && eventName != "refresh_express_option" {
                print("SPECIAL EVENT named: \(eventName) - \(socketAnyEvent)")
            }
        }
        
        newSocket.on("connect") { (data, socketAckEmitter) in
            print("connected")
        }
        newSocket.on("add_order") { (datas, socketAckEmitter) in
            print("add_order")
            
            for data in datas {
                if data is [String: Any] {
                    print("dict")
                }
            }
            
            
        }
        newSocket.on("remove_order") { (data, socketAckEmitter) in
            print("remove_order")
        }
        
        
        newSocket.on("refresh_express_option") { (data, socketAckEmitter) in
            print("refresh_express_option")
        }
        newSocket.on("disconnect") { (data, socketAckEmitter) in
            print("disconnect")
        }
        
        newSocket.connect(timeoutAfter: 0, withHandler: {
            print("newSocket.connect")
        })
    }
    
}
