//
//  DeviceDiscoveryStreamHandler.swift
//  Pods
//
//  Created by Basem Abduallah on 06/08/2025.
//
import Flutter

class DeviceDiscoveryStreamHandler: NSObject, FlutterStreamHandler{
    var discoverySink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.discoverySink = events
        
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.discoverySink = nil
        
        return nil
    }

   
}
