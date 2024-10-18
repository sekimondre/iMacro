import Quartz

struct Routine {
    let name: String = ""
    let timestamp: Date = Date()
    let events: [Event]
    
    static func mock() -> Routine {
        let keyPressN = CGEvent(keyboardEventSource: nil, virtualKey: 45, keyDown: true)!
        let keyPressI = CGEvent(keyboardEventSource: nil, virtualKey: 34, keyDown: true)!
        
        let routine = Routine(events: [
            Event(
                nsEvent: NSEvent(cgEvent: keyPressN)!,
                time: 0.0),
            Event(
                nsEvent: NSEvent(cgEvent: keyPressI)!,
                time: 1.0),
            Event(
                nsEvent: NSEvent(cgEvent: keyPressI)!,
                time: 2.0),
        ])
        return routine
    }
}
