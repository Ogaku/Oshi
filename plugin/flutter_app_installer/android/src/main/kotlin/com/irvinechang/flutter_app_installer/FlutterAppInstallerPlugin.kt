package com.irvinechang.flutter_app_installer

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.File
import java.io.IOException
import java.util.*


/** FlutterAppInstallerPlugin */
class FlutterAppInstallerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  // Log tag
  private val tag = "FlutterAppInstaller"

  private lateinit var applicationContext: Context
  private var mActivity: Activity? = null
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_app_installer")
    channel.setMethodCallHandler(this)

    applicationContext = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    mActivity = binding.activity
  }

  override fun onDetachedFromActivity() {
    mActivity = null
  }

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    mActivity = binding.activity
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${Build.VERSION.RELEASE}")
      }
      "getVersionName" -> {
        result.success(applicationContext.packageManager.getPackageInfo(applicationContext.packageName, 0).versionName)
      }
      "getVersionCode" -> {
        result.success(if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) applicationContext.packageManager.getPackageInfo(applicationContext.packageName, 0).longVersionCode else applicationContext.packageManager.getPackageInfo(applicationContext.packageName, 0).versionCode)
      }
      "isDeviceRooted" -> isDeviceRooted(call, result)
      "isSystemApplication" -> result.success(isSystemApplication(applicationContext.packageManager, applicationContext.packageName))
      "checkShellRootPermission" -> result.success(checkRootPermission())
      "installApk" -> installApk(call, result)
      "verifyApk" -> verifyApk(call, result)
      else -> {
        result.notImplemented()
      }
    }
  }


  /**
   * Detect if the device has root permission
   *
   * @return Boolean
   **/
  private fun isDeviceRooted(@NonNull call: MethodCall, @NonNull result: Result) {
    val su = "su"
    val locations = arrayOf(
      "/system/bin/", "/system/xbin/", "/sbin/", "/system/sd/xbin/",
      "/system/bin/failsafe/", "/data/local/xbin/", "/data/local/bin/", "/data/local/"
    )
    var resultReplied = false
    for (location in locations) {
      if (File(location + su).exists()) {
        result.success(true)
        resultReplied = true
        break
      }
    }

    if (!resultReplied) result.success(false)
  }

  /**
   * Detect if the application has the same signature as the android system.
   *
   * @return Boolean
   **/
  private fun isSystemApplication(packageManager : PackageManager?, packageName : String): Boolean {
    if (packageManager == null || packageName.isEmpty()) {
      return false
    }

    val getPackageInfoFlag : Int = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
      PackageManager.GET_SIGNATURES
    } else {
      PackageManager.GET_SIGNING_CERTIFICATES
    }

    // Get PackageInfo for target application
    val targetPkgInfo: PackageInfo = packageManager.getPackageInfo(
      packageName, getPackageInfoFlag
    )

    // Get PackageInfo for system package
    val sysPackageInfo: PackageInfo = packageManager.getPackageInfo(
      "android", getPackageInfoFlag
    )

    // Match both PackageInfo for there signatures
    return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
      val sysSigs = sysPackageInfo.signatures
      val targetSigs = targetPkgInfo.signatures
      if (sysSigs != null && targetSigs != null && sysSigs.isNotEmpty() && targetSigs.isNotEmpty()) {
        sysSigs[0] == targetSigs[0]
      } else {
        false
      }
    } else {
      targetPkgInfo.signingInfo == sysPackageInfo.signingInfo
    }
  }

  /**
   * Check if the application has the root permission to execute command in the shell.
   *
   * @return Boolean
   **/
  private fun checkShellRootPermission(): Boolean {
    var os : DataOutputStream? = null
    var process : Process? = null
    try {
      process = Runtime.getRuntime().exec("su")
      os = DataOutputStream(process.outputStream)

      os.write("echo root".toByteArray())
      os.writeBytes("\n")
      os.flush()

      os.writeBytes("exit\n")
      os.flush()

      val result : Int = process.waitFor()

      return result == 0
    } catch (e: IOException) {
      e.printStackTrace()
    } catch (e: Exception) {
      e.printStackTrace()
    } finally {
      try {
        os?.close()
      } catch (e: IOException) {
        e.printStackTrace()
      }

      process?.destroy()
    }

    return false;
  }

  /**
   * Install the APK at the inputted file path.
   * If install silently, then the app need to fulfil one of the condition
   * 1. The app is a system application.
   * 2. The app has root permission during shell execution.
   *
   * @return void
   **/
  private fun installApk(@NonNull call: MethodCall, @NonNull result: Result) {
    val filePath : String? = call.argument<String>("filePath")
    val silently : Boolean? = call.argument<Boolean>("silently")
    var resultReplied = false

    if (filePath == null) {
      result.error("MISSING_ARGUMENT", "Missing filePath argument.", "Please call this method with filePath argument.");
      resultReplied = true
    }
    filePath as String

    if (silently == null) {
      result.error("MISSING_ARGUMENT", "Missing silently argument.", "Please call this method with silently argument.");
      resultReplied = true
    }
    silently as Boolean

    if (silently == true) {
      if (isSystemApplication(applicationContext.packageManager, applicationContext.packageName)
        || checkShellRootPermission()) {
        result.success(installApkSilently(filePath))
        resultReplied = true
      }

    } else {
      result.success(installNormal(filePath))
      resultReplied = true
    }

    if(!resultReplied) result.success(false)
  }

  /**
   * Compare a downloaded apk with the currently installed app, so the caller can explain
   * why Android would reject the update ("App not installed") before even trying to install it.
   *
   * Replies with a map: valid, packageName, packageMatches, versionCode, installedVersionCode,
   * isNewer, signatureMatches (or valid=false and error when the file cannot be inspected).
   **/
  @Suppress("DEPRECATION")
  private fun verifyApk(@NonNull call: MethodCall, @NonNull result: Result) {
    val filePath = call.argument<String>("filePath")
    if (filePath == null || !File(filePath).exists()) {
      result.success(mapOf("valid" to false, "error" to "missing_file"))
      return
    }

    try {
      val pm = applicationContext.packageManager
      val flags = PackageManager.GET_SIGNING_CERTIFICATES
      val archive = pm.getPackageArchiveInfo(filePath, flags)
      if (archive == null) {
        result.success(mapOf("valid" to false, "error" to "unreadable"))
        return
      }

      val installed = pm.getPackageInfo(applicationContext.packageName, flags)

      fun signers(info: PackageInfo): Set<String> {
        val signing = info.signingInfo ?: return emptySet()
        val all = (signing.apkContentsSigners ?: emptyArray<android.content.pm.Signature>()) + (signing.signingCertificateHistory ?: emptyArray<android.content.pm.Signature>())
        return all.map { it.toCharsString() }.toSet()
      }

      val archiveSigners = signers(archive)
      val installedSigners = signers(installed)

      result.success(mapOf(
        "valid" to true,
        "packageName" to archive.packageName,
        "packageMatches" to (archive.packageName == applicationContext.packageName),
        "versionCode" to archive.longVersionCode,
        "installedVersionCode" to installed.longVersionCode,
        "isNewer" to (archive.longVersionCode > installed.longVersionCode),
        "signatureMatches" to archiveSigners.intersect(installedSigners).isNotEmpty()
      ))
    } catch (e: Exception) {
      result.success(mapOf("valid" to false, "error" to (e.message ?: "unknown")))
    }
  }

  /**
   * Install the apk with Android Intent.
   *
   * @param filePath String
   * @return Boolean
   **/
  private fun installNormal(filePath: String) : Boolean {
    val file = File(filePath)
    if (!file.exists()) {
      return false
    }

    val intent = Intent(Intent.ACTION_VIEW)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
      val contentUri: Uri = FileProvider.getUriForFile(
        applicationContext,
        applicationContext.packageName + ".fileProvider", file
      )
      intent.setDataAndType(contentUri, "application/vnd.android.package-archive")
    } else {
      intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive")
    }

    mActivity?.startActivity(intent)

    return true
  }

  /**
   * Install the apk silently with pm command execution.
   *
   * @param filePath String
   * @return Boolean
   **/
  private fun installApkSilently(@NonNull filePath: String) : Boolean {
    return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
      installAppSilentBelow24(filePath);
    } else {
      installAppSilentAbove24(applicationContext.packageName, filePath);
    }
  }

  /**
   * Install the apk silently with pm command execution below API level 24.
   *
   * @param filePath String
   * @return Boolean
   **/
  private fun installAppSilentBelow24(@NonNull filePath: String): Boolean {
    val file = File(filePath)
    if (!file.exists()) {
      return false
    }

    val command = "pm install -r ${file.path.replace(" ", "\\ ")}"
    val commandResult: CommandResult = execCommand(
      command, !isSystemApplication(applicationContext.packageManager, applicationContext.packageName), true
    )

    return (commandResult.successMsg != null
            && commandResult.successMsg!!.lowercase(Locale.ROOT).contains("success"))
  }

  /**
   * Install the apk silently with pm command execution above API level 24 (include).
   *
   * @param packageName String
   * @param filePath String
   * @return Boolean
   **/
  private fun installAppSilentAbove24(packageName: String, filePath: String): Boolean {
    val file = File(filePath)
    if (!file.exists()) {
      return false
    }

    val command = "pm install -i $packageName $filePath"
    val commandResult: CommandResult = execCommand(command, isRoot = true, isNeedResultMsg = false)
    return (commandResult.successMsg != null
            && commandResult.successMsg!!.lowercase(Locale.ROOT).contains("success"))
  }

  /**
   * Check if the app has root permission during shell execution
   *
   * @return Boolean
   **/
  private fun checkRootPermission() : Boolean {
    val commandResult = execCommand("echo root", isRoot = true, isNeedResultMsg = true)
    return commandResult.result == 0
  }

  /**
   * Execute the command
   *
   * @param command
   * @param isRoot Execute the command with root permission or not.
   * @param isNeedResultMsg Do the result need to be return or not.
   * @return CommandResult
   **/
  private fun execCommand(command : String, isRoot : Boolean, isNeedResultMsg : Boolean) : CommandResult {
    var result : Int? = null;
    if (command.isEmpty()) {
      return CommandResult(result, null, null)
    }

    var process : Process? = null;
    var successMsg : String? = null;
    var errorMsg : String? = null;

    try {
      process = if (isRoot)
        Runtime.getRuntime().exec(arrayOf("su", "-c", command))
      else
        Runtime.getRuntime().exec(command)

      result = process.waitFor();
      // get command result
      if (isNeedResultMsg) {
        successMsg = process.inputStream.bufferedReader().use(BufferedReader::readText)
        errorMsg = process.errorStream.bufferedReader().use(BufferedReader::readText)
      }
    } catch (e : IOException) {
      e.printStackTrace();
    } catch (e : Exception) {
      e.printStackTrace();
    } finally {
      process?.destroy();
    }

    return CommandResult(result, successMsg, errorMsg);
  }

  class CommandResult(result: Int?, successMsg: String?, errorMsg: String?) {
    /**
     * Command Result
     **/
    var result : Int? = result

    /**
     * Success Message
     **/
    var successMsg : String? = successMsg

    /**
     * Error Message
     **/
    var errorMsg : String? = errorMsg
  }
}
