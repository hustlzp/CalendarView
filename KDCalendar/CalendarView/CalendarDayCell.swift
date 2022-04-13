/*
 * CalendarDayCell.swift
 * Created by Michael Michailidis on 02/04/2015.
 * http://blog.karmadust.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit
import Kingfisher

open class CalendarDayCell: UICollectionViewCell {
    var style: CalendarView.Style = CalendarView.Style.Default {
        didSet {
            // TODO: temp fix
            textLabel.font = style.cellFont
            dotsView.backgroundColor = style.cellEventColor
        }
    }
    
    override open var description: String {
        let dayString = self.textLabel.text ?? " "
        return "<DayCell (text:\"\(dayString)\")>"
    }
    
    var eventsCount = 0 {
        didSet {
            self.dotsView.isHidden = (eventsCount == 0)
            self.setNeedsLayout()
        }
    }
    
    var day: Int? {
        set {
            guard let value = newValue else { return self.textLabel.text = nil }
            self.textLabel.text = String(value)
        }
        get {
            guard let value = self.textLabel.text else { return nil }
            return Int(value)
        }
    }

    var bgImage: Any? = nil {
        didSet {
            if let image = bgImage as? UIImage {
                bgImageView.image = image
            } else if let imageUrl = bgImage as? URL {
                bgImageView.kf.setImage(with: imageUrl)
            } else {
                bgImageView.image = nil
            }
        }
    }
    
    func updateTextColor() {
        if isCustomSelected {
            self.textLabel.textColor = style.cellSelectedTextColor
        } else if isToday {
            self.textLabel.textColor = style.cellTextColorToday
        } else if isOutOfRange {
            self.textLabel.textColor = style.cellTextColorOutOfRange
        } else if isAdjacent {
            self.textLabel.textColor = style.cellTextColorAdjacent
        } else if isWeekend {
            self.textLabel.textColor = style.cellTextColorWeekend
        } else {
            self.textLabel.textColor = style.cellTextColorDefault
        }
    }
    
    var isToday : Bool = false {
        didSet {
            switch isToday {
            case true:
                self.bgView.backgroundColor = style.cellColorToday
            case false:
                self.bgView.backgroundColor = style.cellColorDefault
            }
            
            updateTextColor()
        }
    }
    
    var isOutOfRange : Bool = false {
        didSet {
            updateTextColor()
        }
    }
    
    var isAdjacent : Bool = false {
        didSet {
            updateTextColor()
        }
    }
    
    var isWeekend: Bool = false {
        didSet {
            updateTextColor()
        }
    }
    
    var isCustomSelected: Bool = false {
        didSet {
            if isCustomSelected {
                self.bgView.layer.borderColor = style.cellSelectedBorderColor.cgColor
                self.bgView.layer.borderWidth = style.cellSelectedBorderWidth
                self.bgView.backgroundColor = style.cellSelectedColor
            } else {
                self.bgView.layer.borderColor = style.cellBorderColor.cgColor
                self.bgView.layer.borderWidth = style.cellBorderWidth
                if self.isToday {
                    self.bgView.backgroundColor = style.cellColorToday
                } else {
                    self.bgView.backgroundColor = style.cellColorDefault
                }
            }
            
            updateTextColor()
        }
    }
    
    // MARK: - Public methods
    public func clearStyles() {
        self.bgView.layer.borderColor = style.cellBorderColor.cgColor
        self.bgView.layer.borderWidth = style.cellBorderWidth
        self.bgView.backgroundColor = style.cellColorDefault
        self.textLabel.textColor = style.cellTextColorDefault
        self.eventsCount = 0
    }
    
    
    let textLabel   = UILabel()
    let dotsView    = UIView()
    private lazy var bgImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    let bgView      = UIView()
    
    override init(frame: CGRect) {
        self.textLabel.textAlignment = NSTextAlignment.center
        self.dotsView.backgroundColor = style.cellEventColor
        self.textLabel.font = style.cellFont

        super.init(frame: frame)

        self.addSubview(bgImageView)
        self.addSubview(self.bgView)
        self.addSubview(self.textLabel)
        self.addSubview(self.dotsView)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        var elementsFrame = self.bounds.insetBy(dx: style.cellInsetX, dy: style.cellInsetY)
        
        if style.cellShape.isRound { // square of
            let smallestSide = min(elementsFrame.width, elementsFrame.height)
            elementsFrame = elementsFrame.insetBy(
                dx: (elementsFrame.width - smallestSide) / 2.0,
                dy: (elementsFrame.height - smallestSide) / 2.0
            )
        }

        self.bgImageView.frame = elementsFrame
        self.bgView.frame           = elementsFrame
        self.textLabel.frame        = elementsFrame
        
        let size                            = self.bounds.height * 0.08 // always a percentage of the whole cell
        self.dotsView.frame                 = CGRect(x: 0, y: 0, width: size, height: size)
        self.dotsView.center                = CGPoint(x: self.textLabel.center.x, y: self.bounds.height - (2.5 * size))
        self.dotsView.layer.cornerRadius    = size * 0.5 // round it
        
        switch style.cellShape {
        case .square:
            self.bgView.layer.cornerRadius = 0.0
            bgImageView.layer.cornerRadius = 0
        case .round:
            self.bgView.layer.cornerRadius = elementsFrame.width * 0.5
            bgImageView.layer.cornerRadius = elementsFrame.width * 0.5
        case .bevel(let radius):
            self.bgView.layer.cornerRadius = radius
            bgImageView.layer.cornerRadius = radius
        }
        
        
    }
    
}


