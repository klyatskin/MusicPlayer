//
//  PlayerCardView.swift
//  Embedded Music Player
//
//  Created by Konstantin Klyatskin on 2025-10-17.
//


// PlayerCardView.swift
import UIKit

final class PlayerCardView: UIView {

    // PUBLIC API
    var onPlayPause: (() -> Void)?
    var onPrev: (() -> Void)?
    var onNext: (() -> Void)?
    var onLike: (() -> Void)?
    var onRepeat: ((_ enabled: Bool) -> Void)?
    var onSeekRatio: ((_ ratio: Double) -> Void)?

    // UI
    private let artView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()

    private let prevButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let repeatButton = UIButton(type: .system)
    private let likeButton = UIButton(type: .system)

    private let slider = UISlider()
    private var sliderInUse: Bool = false

    // STATE
    private var repeatOn = false
    private var liked = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        configureUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    
    // MARK: - Public bindings
    func update(title: String, subtitle: String, isPlaying: Bool, current: TimeInterval, duration: TimeInterval) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        setPlaying(isPlaying)
        setTimes(current: current, duration: duration)
        playPauseButton.isHidden = duration.isZero // hide button if no audio is available
    }

    func setArtwork(_ image: UIImage?) {
        artView.image = image
    }

    // MARK: - Private
    private func configureUI() {
        backgroundColor = Theme.Color.background
        layer.cornerRadius = Theme.Metrics.cardCorner
        clipsToBounds = true

        artView.contentMode = .scaleAspectFill
        artView.layer.cornerRadius = Theme.Metrics.cardCorner / 2.0
        artView.clipsToBounds = true
        artView.backgroundColor = Theme.Color.chip

        titleLabel.font = Theme.Typography.title()
        titleLabel.textColor = Theme.Color.labelPrimary
        titleLabel.numberOfLines = 1

        subtitleLabel.font = Theme.Typography.subtitle()
        subtitleLabel.textColor = Theme.Color.labelSecondary
        subtitleLabel.numberOfLines = 1

        currentTimeLabel.font = Theme.Typography.time()
        durationLabel.font = Theme.Typography.time()
        currentTimeLabel.textColor = Theme.Color.labelSecondary
        durationLabel.textColor = Theme.Color.labelSecondary
        currentTimeLabel.text = "0:00"
        durationLabel.text = "0:00"

        // Apply size to small buttons only
        let smallButtons = [prevButton, nextButton, repeatButton, likeButton]
        smallButtons.forEach {
            $0.tintColor = Theme.Color.labelPrimary.withAlphaComponent(0.9)
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 0
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView?.contentMode = .scaleAspectFit
        }

        // Play/Pause uses a larger size
        playPauseButton.tintColor = Theme.Color.labelPrimary
        playPauseButton.backgroundColor = .clear
        playPauseButton.layer.cornerRadius = 0
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        prevButton.setImage(UIImage.sfsymbol("backward.fill"), for: .normal)
        nextButton.setImage(UIImage.sfsymbol("forward.fill"), for: .normal)
        likeButton.setImage(UIImage.sfsymbol("heart"), for: .normal)
        repeatButton.setImage(UIImage.sfsymbol("repeat"), for: .normal)
        playPauseButton.setImage(UIImage.sfsymbol("pause.fill"), for: .normal)

        prevButton.addTarget(self, action: #selector(tapPrev), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(tapPlayPause), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(tapNext), for: .touchUpInside)
        repeatButton.addTarget(self, action: #selector(tapRepeat), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(tapLike), for: .touchUpInside)

        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(sliderTouchDown), for: [.touchDown])
        slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(sliderChanging), for: .valueChanged)
        slider.minimumTrackTintColor = Theme.Color.labelPrimary
        slider.maximumTrackTintColor = Theme.Color.barTrack
        func trackImage(_ color: UIColor) -> UIImage {
            let h: CGFloat = Theme.Metrics.progressHeight
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 4, height: h), false, 0)
            let rect = CGRect(x: 0, y: 0, width: 4, height: h)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: h/2)
            color.setFill()
            path.fill()
            let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
            UIGraphicsEndImageContext()
            return img.resizableImage(withCapInsets: UIEdgeInsets(top: h/2, left: 2, bottom: h/2, right: 2))
        }
        slider.setMinimumTrackImage(trackImage(Theme.Color.labelPrimary), for: .normal)
        slider.setMaximumTrackImage(trackImage(Theme.Color.barTrack), for: .normal)
        let thumbSize: CGFloat = 18
        UIGraphicsBeginImageContextWithOptions(CGSize(width: thumbSize, height: thumbSize), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        UIColor.white.setFill()
        ctx.fillEllipse(in: CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize))
        let thumb = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        slider.setThumbImage(thumb, for: .normal)
        slider.setThumbImage(thumb, for: .highlighted)
    }

    private func layoutUI() {
        let h = UIStackView()
        h.axis = .horizontal
        h.spacing = Theme.Metrics.spacing
        h.alignment = .center

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical
        labels.spacing = 2
        labels.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        labels.setContentHuggingPriority(.defaultLow, for: .horizontal)

        artView.translatesAutoresizingMaskIntoConstraints = false
        // Lock artwork to a strict 88x88 square so bitmap intrinsic size never changes layout
        NSLayoutConstraint.activate([
            artView.widthAnchor.constraint(equalToConstant: Theme.Metrics.artSize),
            artView.heightAnchor.constraint(equalTo: artView.widthAnchor)
        ])
        // Priorities: prevent intrinsic image size from expanding the stack
        artView.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        artView.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        artView.setContentCompressionResistancePriority(.required, for: .horizontal)
        artView.setContentCompressionResistancePriority(.required, for: .vertical)

        h.addArrangedSubview(artView)
        h.addArrangedSubview(labels)

        let timeSpacer = UIView()
        timeSpacer.isUserInteractionEnabled = false
        let times = UIStackView(arrangedSubviews: [currentTimeLabel, timeSpacer, durationLabel])
        times.axis = .horizontal

        // Symmetric row with equal spacers to keep play/pause perfectly centered
        let s1 = UIView(); let s2 = UIView(); let s3 = UIView(); let s4 = UIView()
        [s1, s2, s3, s4].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [s1, s2, s3, s4].forEach { $0.isUserInteractionEnabled = false }

        func container(_ size: CGFloat, for control: UIView, background: UIColor? = nil, cornerRadius: CGFloat = 0) -> UIView {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.widthAnchor.constraint(equalToConstant: size).isActive = true
            v.heightAnchor.constraint(equalToConstant: size).isActive = true
            v.isUserInteractionEnabled = true
            v.backgroundColor = background
            v.layer.cornerRadius = cornerRadius
            v.clipsToBounds = cornerRadius > 0
            v.addSubview(control)
            control.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                control.leadingAnchor.constraint(equalTo: v.leadingAnchor),
                control.topAnchor.constraint(equalTo: v.topAnchor),
                control.trailingAnchor.constraint(equalTo: v.trailingAnchor),
                control.bottomAnchor.constraint(equalTo: v.bottomAnchor)
            ])
            return v
        }
        let repeatC = container(Theme.Metrics.smallControl, for: repeatButton)
        let prevC   = container(Theme.Metrics.smallControl, for: prevButton)
        let playC   = container(Theme.Metrics.largeControl, for: playPauseButton, background: Theme.Color.selected, cornerRadius: Theme.Metrics.largeControl / 2.0)
        let nextC   = container(Theme.Metrics.smallControl, for: nextButton)
        let likeC   = container(Theme.Metrics.smallControl, for: likeButton)

        let bottomRow = UIStackView(arrangedSubviews: [repeatC, s1, prevC, s2, playC, s3, nextC, s4, likeC])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.distribution = .fill
        bottomRow.spacing = 0
        // Equalize spacer widths to enforce symmetry
        s1.widthAnchor.constraint(equalTo: s2.widthAnchor).isActive = true
        s2.widthAnchor.constraint(equalTo: s3.widthAnchor).isActive = true
        s3.widthAnchor.constraint(equalTo: s4.widthAnchor).isActive = true
        bottomRow.isUserInteractionEnabled = true

        let root = UIStackView(arrangedSubviews: [h, slider, times, bottomRow])
        root.axis = .vertical
        root.spacing = 16
        root.translatesAutoresizingMaskIntoConstraints = false

        addSubview(root)
        // Ensure the view prefers not to be compressed vertically and has a sane minimum height
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        root.setContentCompressionResistancePriority(.required, for: .vertical)

        // Make slider reliably tappable/dragable
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setContentCompressionResistancePriority(.required, for: .vertical)
        slider.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true

        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: topAnchor, constant: Theme.Metrics.contentInset.top),
            root.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Theme.Metrics.contentInset.left),
            root.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Theme.Metrics.contentInset.right),
            root.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Theme.Metrics.contentInset.bottom),
        ])
    }

    private func setPlaying(_ playing: Bool) {
        let symbol = playing ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage.sfsymbol(symbol), for: .normal)
    }

    private func setTimes(current: TimeInterval, duration: TimeInterval) {
        currentTimeLabel.text = Self.format(seconds: current)
        durationLabel.text = Self.format(seconds: duration)
        if duration > 0 {
            if !sliderInUse {
                slider.setValue(Float(current / duration), animated: false)
            }
        }
    }

    private static func format(seconds: TimeInterval) -> String {
        guard seconds.isFinite else { return "--:--" }
        let s = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d", s/60, s%60)
    }

    // MARK: - Actions
    @objc private func tapPrev() { onPrev?() }
    @objc private func tapPlayPause() { onPlayPause?() }
    @objc private func tapNext() { onNext?() }
    @objc private func tapRepeat() {
        repeatOn.toggle()
        repeatButton.tintColor = repeatOn ? Theme.Color.iconAccent : Theme.Color.iconDefault
        onRepeat?(repeatOn)
    }
    @objc private func tapLike() {
        liked.toggle()
        likeButton.setImage(UIImage.sfsymbol(liked ? "heart.fill" : "heart"), for: .normal)
        likeButton.tintColor = liked ? Theme.Color.heartOn : Theme.Color.iconDefault
        onLike?()
    }

    @objc private func sliderTouchDown() { sliderInUse = true }
    @objc private func sliderTouchUp() {
        onSeekRatio?(Double(slider.value))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in // delay to avoid value jump
            sliderInUse = false;
        }
    }
    @objc private func sliderChanging() { }
}
