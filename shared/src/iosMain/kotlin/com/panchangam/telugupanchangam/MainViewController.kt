package com.panchangam.telugupanchangam

import androidx.compose.ui.window.ComposeUIViewController
import com.panchangam.telugupanchangam.ui.AppSettings
import com.panchangam.telugupanchangam.ui.theme.ThemeMode
import kotlinx.cinterop.ExperimentalForeignApi
import kotlinx.cinterop.useContents
import platform.CoreGraphics.CGRectMake
import platform.Foundation.NSBundle
import platform.Foundation.NSUserDefaults
import platform.UIKit.UIActivityViewController
import platform.UIKit.UIApplication
import platform.UIKit.UIUserInterfaceStyle
import platform.UIKit.UIViewController
import platform.UIKit.UIWindow
import platform.UIKit.popoverPresentationController

/** Entry point called from Swift: `MainViewControllerKt.MainViewController()`. */
@Suppress("FunctionName", "unused")
fun MainViewController(): UIViewController = ComposeUIViewController {
    PanchangamRoot(
        store = UserDefaultsSettingsStore,
        onShare = ::shareText,
        versionName = NSBundle.mainBundle.objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?: "",
        // Make the status bar follow the in-app theme, not only the system one.
        onDarkThemeChange = { dark ->
            keyWindow()?.overrideUserInterfaceStyle =
                if (dark) UIUserInterfaceStyle.UIUserInterfaceStyleDark
                else UIUserInterfaceStyle.UIUserInterfaceStyleLight
        }
    )
}

private object UserDefaultsSettingsStore : SettingsStore {
    private val defaults = NSUserDefaults.standardUserDefaults

    override fun load() = AppSettings(
        cityId = defaults.stringForKey("city") ?: AppSettings().cityId,
        theme = runCatching { ThemeMode.valueOf(defaults.stringForKey("theme") ?: "") }.getOrDefault(ThemeMode.SYSTEM),
        use24Hour = defaults.boolForKey("use24h")
    )

    override fun save(settings: AppSettings) {
        defaults.setObject(settings.cityId, "city")
        defaults.setObject(settings.theme.name, "theme")
        defaults.setBool(settings.use24Hour, "use24h")
    }
}

@Suppress("DEPRECATION")
private fun keyWindow(): UIWindow? =
    UIApplication.sharedApplication.keyWindow
        ?: UIApplication.sharedApplication.windows.firstOrNull { (it as? UIWindow)?.isKeyWindow() == true } as? UIWindow

@OptIn(ExperimentalForeignApi::class)
private fun shareText(text: String) {
    var top = keyWindow()?.rootViewController ?: return
    while (top.presentedViewController != null) top = top.presentedViewController!!
    val sheet = UIActivityViewController(activityItems = listOf(text), applicationActivities = null)
    // iPad presents the share sheet as a popover, which needs an anchor.
    sheet.popoverPresentationController?.let { popover ->
        popover.sourceView = top.view
        top.view.bounds.useContents {
            popover.sourceRect = CGRectMake(size.width / 2, size.height / 2, 0.0, 0.0)
        }
    }
    top.presentViewController(sheet, animated = true, completion = null)
}
