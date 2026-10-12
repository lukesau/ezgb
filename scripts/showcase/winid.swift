// Print the on-screen window id of the running SameBoy SDL window.
// AppleScript can't see SDL windows; CGWindowList can. Used by
// make-showcase-banner.sh to target `screencapture -l <id>`.
// Usage: winid [pid]. With a pid, only that process's window (other
// SameBoy windows may be open); without one, every SameBoy window.
import CoreGraphics
import Foundation
let pid = CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1]) : nil
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as! [[String: Any]]
for w in list {
    if let pid = pid {
        if (w[kCGWindowOwnerPID as String] as? Int) == pid {
            print(w[kCGWindowNumber as String] as! Int)
            break
        }
    } else if ((w[kCGWindowOwnerName as String] as? String) ?? "").lowercased().contains("sameboy") {
        print(w[kCGWindowNumber as String] as! Int)
    }
}
