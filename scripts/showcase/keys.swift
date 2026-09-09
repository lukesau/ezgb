// Inject `n` presses of a macOS virtual key code into a target pid.
// System Events keystrokes don't reach SDL; CGEvent.postToPid does.
// Usage: keys <pid> <keycode> <count>.  Select (SameBoy default) = Backspace = 51.
import CoreGraphics
import Foundation
let a = CommandLine.arguments
let pid = pid_t(a[1])!
let code = CGKeyCode(UInt16(a[2])!)
let n = Int(a[3])!
for _ in 0..<n {
    CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: true)!.postToPid(pid)
    usleep(60000)
    CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: false)!.postToPid(pid)
    usleep(120000)
}
