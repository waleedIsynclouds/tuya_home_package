package com.innovationcodes.tuya_home_sdk_flutter

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink


class DeviceDiscoveryStreamHandler : EventChannel.StreamHandler {
    var discoverySink: EventSink? = null
    override fun onListen(arguments: Any?, events: EventSink?) {
        this.discoverySink = events
    }

    override fun onCancel(arguments: Any?) {
        this.discoverySink = null
    }
}