/*Copyright (c) 2016, Andrew Walz.
 
 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit

class SwiftyRecordButton: SwiftyCamButton {
    
    private var circleBorder: CALayer!
    private var innerCircle: UIView = UIView()
    
    override var buttonEnabled: Bool {
        get {
            return self.isEnabled
        }
        set {
            self.isEnabled = newValue
            if self.isEnabled {
                growButton()
            }
            else {
                shrinkButton()
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawButton()
        self.addSubview(innerCircle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawButton()
        self.addSubview(innerCircle)
    }
    
    private func drawButton() {
        self.backgroundColor = UIColor.clear
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 6.0
        circleBorder.borderColor = UIColor.white.cgColor
        circleBorder.bounds = self.bounds
        circleBorder.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)

    }
    
    public  func growButton() {
        innerCircle.frame = CGRect(x: 0, y: 0, width: self.bounds.width - 16, height: self.bounds.height - 16)
        innerCircle.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        innerCircle.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        innerCircle.layer.cornerRadius = innerCircle.frame.size.width / 2
        innerCircle.clipsToBounds = true
        innerCircle.isHidden = false
    }
    
    public func shrinkButton() {
        innerCircle.isHidden = true
    }
}
