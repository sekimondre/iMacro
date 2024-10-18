import Quartz

@Observable final class Engine: ObservableObject {
    
    var targetPID: String = ""
    
    var addNoise = true
    
    private(set) var isPlaying: Bool = false
    
    private let maxNoise: TimeInterval = 0.1
    
    var PID: pid_t {
        Int32(targetPID)!
    }
    
    func playbackHard() {
        playback(Routine.mock(), loop: true)
    }
    
    func playback(_ routine: Routine, loop: Bool = false) {
        guard !isPlaying else { return }
        isPlaying = true
        play(routine.events, from: 0, infinite: loop)
    }
    
    func stopPlayback() {
        isPlaying = false
    }
    
    private func play(_ events: [Event], from index: Int, infinite: Bool) {
        assert(index >= 0 && index < events.count)
        guard isPlaying else { return }
        
        let event = events[index]
        
        let nextTimestamp = if index == events.count - 1 {
            event.time
        } else {
            events[index + 1].time
        }
        var wait = nextTimestamp - event.time
        if addNoise {
            wait += (TimeInterval.random(in: 0..<1) + 1.0) * maxNoise
        }
        
        event.nsEvent.cgEvent?.postToPid(PID)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
            if index < events.count - 1 {
                self.play(events, from: index + 1, infinite: infinite)
            } else if infinite {
                self.play(events, from: 0, infinite: infinite)
            }
        }
    }
}
