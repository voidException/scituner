

import Foundation

class Source{
    var onData: (() -> ()) = {}

    var frequency: Double = 0

    var frequency1: Double = 82.41
    var frequency2: Double = 0.05

    var frequencyDeviation: Double = 0.0
    var discreteFrequency: Double = 44100
    var t: Double = 0

    var sample = [Double](count: 2048, repeatedValue: 0)
    var preview = [Double](count: 2500, repeatedValue: 0)
    
    var lock = NSLock()

    init(sampleRate: Int, sampleCount: Int) {
        self.discreteFrequency = Double(sampleRate)
        sample = [Double](count: sampleCount, repeatedValue: 0)
        
        var interval = Double(sample.count) / discreteFrequency

        let timer = NSTimer(timeInterval: interval, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }

    @objc func update(){
        if !lock.tryLock() {
            return
        }
        
        var dt: Double = Double(1) / discreteFrequency

        var df: Double = frequencyDeviation * sin(2 * M_PI * frequency2 * t)
        frequency = frequency1 + df
        
        //NSLog("source freq %f ", frequency);
        
        var t2 = dt;
        source_generate(&sample, size_t(sample.count), &t, dt, frequency)
        source_generate(&preview, size_t(preview.count), &t2, dt, frequency)
        
        onData()
        
        lock.unlock()
    }

    func getFreqText() -> String {
        return String(format: "%6.2f Hz", frequency)
    }

    func rand() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX)
    }
}
