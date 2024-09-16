//
//  RemoteConfigsProvider.swift
//  ThemesManagerDemo
//
//  Created by Tharindu Ketipearachchi on 2024-09-16.
//
import Foundation
import Firebase
import FirebaseAnalytics
/**
 Use this enum to refer the variables that you need to fetch and control remotely
 from Firebase Remote config console.
 */
enum RemoteConfigValueKey: String {
    case theme
}
/**
 Provider for communicate with firebase remote configs and fetch config values
 */
final class RemoteConfigProvider {
    static let shared = RemoteConfigProvider()
    var loadingDoneCallback: (() -> Void)?
    var fetchComplete = false
    var isDebug = true
    
    private var remoteConfig = RemoteConfig.remoteConfig()
    
    private init() {
        setupConfigs()
        loadDefaultValues()
        setupListener()
    }
    
    func setupConfigs() {
        let settings = RemoteConfigSettings()
        // fetch interval that how frequent you need to check updates from the server
        settings.minimumFetchInterval = isDebug ? 0 : 43200
        remoteConfig.configSettings = settings
    }
    
    /** 
     In case firebase failed to fetch values from the remote server due to internet failure
     or any other circumstance, In order to run our application without any issues
     we have to set default values for all the variables that we fetches
     from the remote server. 
     If you have higher number of variables in use, you can use info.plist file
     to define the defualt values as well.
     */
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            RemoteConfigValueKey.theme.rawValue: 1
        ]
        remoteConfig.setDefaults(appDefaults as? [String: NSObject])
    }
    
    /**
     Setup listner functions for frequent updates
     */
    func setupListener() {
        remoteConfig.addOnConfigUpdateListener { configUpdate, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard configUpdate != nil else {
                print("REMOTE CONFIG ERROR")
                return
            }
            
            self.remoteConfig.activate { changed, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("REMOTE CONFIG activation state change \(changed)")
                }
            }
        }
    }
    
    /**
         Function for fectch values from the cloud
     */
    func fetchCloudValues() {
        remoteConfig.fetch { [weak self] (status, error) -> Void in
            guard let self = self else { return }
            
            if status == .success {
                self.remoteConfig.activate { _, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.fetchComplete = true
                    print("Remote config fetch success")
                    DispatchQueue.main.async {
                        self.loadingDoneCallback?()
                    }
                }
            } else {
                print("Remote config fetch failed")
                DispatchQueue.main.async {
                    self.loadingDoneCallback?()
                }
            }
        }
    }
}

// MARK: Basic remote config value access methods

extension RemoteConfigProvider {
    func bool(forKey key: RemoteConfigValueKey) -> Bool {
        return remoteConfig[key.rawValue].boolValue
    }
    
    func string(forKey key: RemoteConfigValueKey) -> String {
        return remoteConfig[key.rawValue].stringValue 
    }
    
    func double(forKey key: RemoteConfigValueKey) -> Double {
        return remoteConfig[key.rawValue].numberValue.doubleValue
    }
    
    func int(forKey key: RemoteConfigValueKey) -> Int {
        return remoteConfig[key.rawValue].numberValue.intValue
    }
}

// MARK: Getters for config values

extension RemoteConfigProvider {
    func theme() -> Int {
        return int(forKey: .theme)
    }
}
