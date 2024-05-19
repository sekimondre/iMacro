import Quartz

struct MouseEvent {
    let position: CGPoint
    let timestamp: TimeInterval
}

final class Recorder: ObservableObject {

    private var eventMonitor: Any?
    private var recordedEvents: [MouseEvent] = []
    private var startTime: TimeInterval = 0

    init() {
        print("AX process trusted: \(AXIsProcessTrusted())")
    }

    func startRecording() {
        print("start recording")
        startTime = Date().timeIntervalSince1970
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { event in
            print("- left mouse event")
            let timestamp = Date().timeIntervalSince1970 - self.startTime
            let mouseEvent = MouseEvent(position: event.locationInWindow, timestamp: timestamp)
            self.recordedEvents.append(mouseEvent)
        }
    }

    func stopRecording() {
        print("stop recording")
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }

    func playBack() {
        print("start playback")
        for event in recordedEvents {
            print("event...")
            let delay = event.timestamp - (recordedEvents.first?.timestamp ?? 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                print("click at \(event.position)")
                self.click(at: event.position)
            }
        }
    }

    private func click(at point: CGPoint) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        
        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
}
