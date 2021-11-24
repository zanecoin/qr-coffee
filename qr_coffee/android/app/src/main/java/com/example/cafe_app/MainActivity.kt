package cz.pankaci.qr_coffee

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "cz.pankaci.qr_coffee/payment"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        // Note: this method is invoked on the main thread.
        call,
        result ->
      if (call.method == "flutterToNative") {
        val passedName = call.argument<String>("name")
        val passedPrice = call.argument<String>("price")
        val name = testFunction(passedName!!)
        val price = testFunction(passedPrice!!)
        result.success(listOf(name, price))
        val intent = Intent(this, MainScreen::class.java)
        startActivity(intent)
        // if (batteryLevel != -1) {
        //   result.success(batteryLevel)
        // } else {
        //   result.error("UNAVAILABLE", "Battery level not available.", null)
        // }
      } else {
        result.notImplemented()
      }
    }
  }

  private fun testFunction(str: String): String {
    return str
  }

  private fun getBatteryLevel(): Int {
    val batteryLevel: Int
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    } else {
      val intent =
          ContextWrapper(applicationContext)
              .registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
      batteryLevel =
          intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 /
              intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
    }

    return batteryLevel
  }
}
