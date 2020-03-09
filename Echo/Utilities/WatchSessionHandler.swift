//
//  WatchSessionHandler.swift
//  Echo
//
//  Created by Rohini on 09/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchSessionHandler: NSObject, WCSessionDelegate {
    
    static let sharedInstance = WatchSessionHandler()
    private var session = WCSession.default
    
    
    override init() {
        super.init()
        
        if isWatchSessionSupported() {
            session.delegate = self
            session.activate()
        }
        
    }
    
    func getActivationState() -> WCSessionActivationState {
        return WCSession.default.activationState
    }
    
    func notifyWatchAppInstalled() {
        NotificationCenter.default.post(name: .isWatchAppInstalled, object: session.isWatchAppInstalled)
    }
        
    func isWatchSessionSupported() -> Bool {
        return WCSession.isSupported()
    }
    
    func isWatchAppInstalled() -> Bool {
        
        return session.isWatchAppInstalled
    }
    func isWatchAppPaired() -> Bool {
        return session.isPaired
    }
    func isWatchAppReachable() -> Bool {
        return session.isReachable
    }
    
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        NotificationCenter.default.post(name: .isWatchAppPaired, object: session.isPaired)
        session.activate()
        print("watch app installed successfully")
        NotificationCenter.default.post(name: .isWatchAppInstalled, object: session.isWatchAppInstalled)
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("session reachability changed")
        
        if ( session.isWatchAppInstalled) {
            NotificationCenter.default.post(name: .isWatchAppInstalled, object: session.isWatchAppInstalled)
        }
        NotificationCenter.default.post(name: .isWatchAppPaired, object: session.isPaired)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("watch activation completed with activationstate \(activationState) error:\(String(describing: error))")
        print("Session isPaired \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
        NotificationCenter.default.post(name: .isWatchAppInstalled, object: session.isWatchAppInstalled)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
        NotificationCenter.default.post(name: .isWatchAppPaired, object: session.isPaired)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        NotificationCenter.default.post(name: .isWatchAppPaired, object: session.isPaired)
        
        //Reactivate the session
        self.session.activate()
    }
    
    
}
