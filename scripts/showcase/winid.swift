// Print the on-screen window id of the running SameBoy SDL window.
// AppleScript can't see SDL windows; CGWindowList can. Used by
// make-showcase-banner.sh to target `screencapture -l <id>`.
import CoreGraphics
import Foundation
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as! [[String: Any]]
for w in list {
    if ((w[kCGWindowOwnerName as String] as? String) ?? "").lowercased().contains("sameboy") {
        print(w[kCGWindowNumber as String] as! Int)
    }
}
