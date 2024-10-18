import Quartz

struct MouseEvent {
    let position: CGPoint
    let timestamp: TimeInterval
}

struct Event {
    let nsEvent: NSEvent
    let time: TimeInterval
}

final class Recorder: ObservableObject {

    private var eventMonitor: Any?
//    private var recordedEvents: [MouseEvent] = []
    private var events: [Event] = []
    private var startTime: TimeInterval = 0
    
    private var maxRandDelay: TimeInterval = 0.1
    
//    nnn@Published var routines: [Routine] = []

    init() {
        print("AX process trusted: \(AXIsProcessTrusted())")
    }

    func startRecording() {
        print("start recording")
        startTime = Date().timeIntervalSince1970
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .keyDown, .keyUp]) { event in
            print("--- Event: \(event.type), location: \(event.locationInWindow)")
            if event.type == .keyDown {
                print("--- KEYCODE: \(event.keyCode)")
            }
            
            let timestamp = Date().timeIntervalSince1970 - self.startTime
            let recordedEvent = Event(nsEvent: event, time: timestamp)
            self.events.append(recordedEvent)
        }
    }

    func stopRecording() {
        print("stop recording")
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
//        let newRoutine = Routine()
//        newRoutine.events = events
//        routines.append(newRoutine)
        
        events.removeAll()
    }

    func playBack() {
//        let randomDelay = TimeInterval.random(in: 0...1) * maxRandDelay
        
        print("start playback")
        for event in events {
            let delay = event.time - (events.first?.time ?? 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                print("--- playing back: \(event.nsEvent.type)")
                self.trigger(event)
            }
        }
    }
    
    var isPlaying: Bool = false
    
    func stopInfinitePlayback() {
        isPlaying = false
    }
    
    func infinitePlayback() {
        isPlaying = true
        repeatHard()
    }
    
    private func repeatHard() {
        let PID: pid_t = 40061
        
        let keyPressN = CGEvent(keyboardEventSource: nil, virtualKey: 45, keyDown: true)
        let keyPressI = CGEvent(keyboardEventSource: nil, virtualKey: 34, keyDown: true)
        
        if isPlaying {
            let delay1 = TimeInterval.random(in: 0...1) * 0.1
            let delay2 = 1.0 + TimeInterval.random(in: 0...1) * 0.1
            let delay3 = 1.0 + TimeInterval.random(in: 0...1) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay1) {
                keyPressN?.postToPid(PID)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay2) {
                    keyPressI?.postToPid(PID)
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay3) {
                        keyPressI?.postToPid(PID)
                        if self.isPlaying {
                            self.repeatHard()
                        }
                    }
                }
            }
        }
    }
    
    private func trigger(_ event: Event) {
//        let cgEvent = event.nsEvent.cgEvent
//        cgEvent?.postToPid(34767)
    }

    private func click(at point: CGPoint) {
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)
        
        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
}
