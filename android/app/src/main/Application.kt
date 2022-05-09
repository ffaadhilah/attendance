package id.co.msg.attendance

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;


class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
    }

    override fun registerWith(registry: PluginRegistry?) {
        io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin.registerWith(
                registry?.registrarFor(
                        "io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
    }
}