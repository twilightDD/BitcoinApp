//
//  SOXNewSocket_BitcoinDE_Core.swift
//  BitcoinApp
//
//  Created by Peter Hauke on 28.03.21.
//  Copyright © 2021 2sox / Peter Hauke. All rights reserved.
//

import Foundation

import SocketIO

//MARK: - SOXNewSocket_BitcoinDE_Core
@objc
open class SOXNewSocket_BitcoinDE_Core: NSObject {
    
    //MARK: Lets and Vars
    @objc
    static var isConnected = { socketManager?.status == .connected }
    
    private static var socketManager: SocketManager?
    private static let socketURL = URL.init(string: "https://ws-mig.bitcoin.de:443")!
    private static let socketNamespace = "/market"
    
    private static let ConnectKey = "connect"
    private static let DisconnectKey = "disconnect"
    private static let AddOrderKey    = "add_order"
    private static let RemoveOrderKey = "remove_order"
    private static let UpdateOrderKey = "refresh_express_option"
    
    //MARK: - Public Class Methods
    @objc
    class func startWebSocketCore() {

        // Avoid re-connecting while socket is alive.
        if socketManager != nil {
            return
        }

        // Create SocketManager
        let socketIOClientConfiguration = SocketIOClientConfiguration() // not used at the moment
        socketManager = SocketManager.init(socketURL: socketURL,
                                           config: socketIOClientConfiguration)
        
        guard let socketManager = socketManager else {
            return }
        
        // Create Socket
        let newSocket = socketManager.socket(forNamespace: socketNamespace)
        addCallbacks(to: newSocket)
        newSocket.connect()
    }
    
    
    @objc
    class func stopWebSocketCore() {
        socketManager?.disconnect()
        socketManager = nil
    }
    
}


//MARK: - Extension - Socket Callbacks
extension SOXNewSocket_BitcoinDE_Core {
    
    private class func addCallbacks(to socket: SocketIOClient) {
        
        socket.on(ConnectKey) { (data, socketAckEmitter) in
            SOXSocketIO_BitcoinDE_Core.socketDidConnect()
        }
        
        socket.on(AddOrderKey) { (datas, socketAckEmitter) in
            for data in datas {
                if let dictionary = data as? [String: Any] {
                    SOXSocketIO_BitcoinDE_Core.addOrder(dictionary)
                }
            }
        }
        
        socket.on(RemoveOrderKey) { (datas, socketAckEmitter) in
            for data in datas {
                if let dictionary = data as? [String: Any] {
                    SOXSocketIO_BitcoinDE_Core.removeOrder(dictionary)
                }
            }
        }
        
        
        socket.on(UpdateOrderKey) { (datas, socketAckEmitter) in
            for data in datas {
                if let dictionary = data as? [String: Any] {
                    SOXSocketIO_BitcoinDE_Core.updateOrder(dictionary)
                }
            }
        }
        
        socket.on(DisconnectKey) { (data, socketAckEmitter) in
            SOXSocketIO_BitcoinDE_Core.socketDidDisconnect()
        }
        
        
        // For debugging
        //        socket.onAny { (socketAnyEvent) in
        //            let eventName = socketAnyEvent.event
        //            if eventName != "connect"
        //                && eventName != "add_order"
        //                && eventName != "remove_order"
        //            && eventName != "refresh_express_option" {
        //                print("SPECIAL EVENT named: \(eventName) - \(socketAnyEvent)")
        //            }
        //        }
    }
    
}
