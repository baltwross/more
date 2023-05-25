//
//  CreateSignalViewController.swift
//  More
//
//  Created by Luko Gjenero on 26/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

private let signalDraft: String = "com.more.simpleStore.signal.draft"
private let titleSize: Int = 35

class CreateSignalViewController: UIViewController {
    
    class CreateSignalStoreItem: SimpleStoreService.StoreItem {
        
        required init(from decoder: Decoder) throws {
            try super.init(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            value = try container.decode(CreateExperienceViewModel.self, forKey: .value)
        }
        
        override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value as! CreateExperienceViewModel, forKey: .value)
        }
        
        override init(key: String, value: Codable?) {
            super.init(key: key, value: value)
        }
        
    }
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var previewButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var moodLabel: HorizontalGradientLabel!
    @IBOutlet private weak var moodButton: UIButton!
    @IBOutlet private weak var titleView: AutoGrowingTextView!
    @IBOutlet private weak var titleCountView: UILabel!
    @IBOutlet private weak var descriptionView: AutoGrowingTextView!
    @IBOutlet private weak var photosView: CreateSignalMediaView!
    @IBOutlet private weak var placeView: CreateSignalPlaceItem!
    @IBOutlet private weak var scheduleView: CreateSignalScheduleItem!
    @IBOutlet private weak var nowLabel: HorizontalGradientLabel!
    @IBOutlet private weak var nowSwitch: GradientSwitch!
    @IBOutlet private weak var privateLabel: HorizontalGradientLabel!
    @IBOutlet private weak var privateSwitch: GradientSwitch!
    @IBOutlet private weak var tierLabel: HorizontalGradientLabel!
    @IBOutlet private weak var tierButton: UIButton!
    
    @IBOutlet private weak var placeHeight: NSLayoutConstraint!
    @IBOutlet private weak var placeDelimiter: UIView!
    @IBOutlet private weak var scheduleHeight: NSLayoutConstraint!
    @IBOutlet private weak var scheduleDelimiter: UIView!
    
    var cancelTap: (()->())?
    var finished: ((_ experience: Experience, _ claimed: Bool)->())?
    
    private var model: CreateExperienceViewModel!
    private var doNow: Bool = false
    private var isPrivate: Bool = false
    private var keyboardVisible: Bool = false
    private var isFirst: Bool = true
    private var experience: Experience? = nil
    
    private let keyboardManager = KeyboardManager()
    
    private var pauseKeyboardEvents: Bool {
        if let firstResponder = UIResponder.currentFirstResponder(),
            firstResponder == titleView || firstResponder == descriptionView {
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let draft: CreateSignalStoreItem = SimpleStoreService.shared.get(forKey: signalDraft),
            let signalDraft = draft.value as? CreateExperienceViewModel {
            model = signalDraft
        } else {
            model = CreateExperienceViewModel()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        for constraint in view.constraints {
            if constraint.firstAnchor == scrollView.bottomAnchor ||
                constraint.secondAnchor == scrollView.bottomAnchor {
                bottomContraint = constraint
                break
            }
        }
        trackKeyboardAndPushUp()
        trackKeyboard(onlyFor: [])
        
        moodLabel.textColor = .lightPeriwinkle
        
        titleView.placeholderLabel.text = "Title"
        titleView.placeholderLabel.font = titleView.font
        titleView.placeholderLabel.textColor = .lightPeriwinkle
        
        descriptionView.placeholderLabel.text = "Describe the experience. What makes it special? Why is it unforgettable?"
        descriptionView.placeholderLabel.font = descriptionView.font
        descriptionView.placeholderLabel.textColor = UIColor(red: 191, green: 195, blue: 202)
        descriptionView.placeholderLabel.numberOfLines = 0
        
        let done = KeyboardManager.createToolbar()
        done.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        
        titleView.inputAccessoryView = done
        descriptionView.inputAccessoryView = done
        
        keyboardManager.manageTextView(titleView, withMaxLength: titleSize, showDone: false)
        keyboardManager.manageTextView(descriptionView, withMaxLength: 0, showDone: false)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(titleTextChanged),
            name: UITextView.textDidChangeNotification,
            object: titleView)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(descriptionTextChanged),
            name: UITextView.textDidChangeNotification,
            object: descriptionView)
        
        photosView.addTap = { [weak self] in
            self?.showPhotoSelector()
        }
        
        photosView.photoTap = { [weak self] (photo) in
            self?.showDeletePhoto(photo)
        }
        
        photosView.rearranged = { [weak self] (photos) in
            self?.model.images = photos
            self?.setupUI()
        }
        
        placeView.tap = { [weak self] in
            self?.showLocationSelector()
        }
        
        scheduleView.tap = { [weak self] in
            self?.showScheduleSelector()
        }
        
        nowSwitch.colors = [UIColor(red: 3, green: 255, blue: 191), .brightSkyBlue, UIColor(red: 48, green: 183, blue: 255), .lightPeriwinkle]
        nowSwitch.locations = [0, 0.32, 0.6, 1]
        nowSwitch.addTarget(self, action: #selector(nowSwitchChanged(_:)), for: .valueChanged)
        
        privateSwitch.colors = [UIColor(red: 3, green: 255, blue: 191), .brightSkyBlue, UIColor(red: 48, green: 183, blue: 255), .lightPeriwinkle]
        privateSwitch.locations = [0, 0.32, 0.6, 1]
        privateSwitch.addTarget(self, action: #selector(privateSwitchChanged(_:)), for: .valueChanged)
        
        tierButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        setupWhenAndWhere()
        
        setupUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        // checkForInput()
    }
    
    @objc private func keyboardDidShow() {
        guard !pauseKeyboardEvents else { return }
        keyboardVisible = true
    }
    
    @objc private func keyboardDidHide() {
        guard !pauseKeyboardEvents else { return }
        keyboardVisible = false
    }
    
    @objc private func closeKeyboard() {
        titleView.resignFirstResponder()
        descriptionView.resignFirstResponder()
    }
    
    @objc private func titleTextChanged() {
        titleCountView.text = "\(titleSize - titleView.text.count)"
        model.title = titleView.text
    }
    
    @objc private func descriptionTextChanged() {
        model.text = descriptionView.text
    }
    
    private var canSave: Bool {
        return model.type != nil ||
            !model.title.isEmpty ||
            !model.text.isEmpty ||
            !model.images.isEmpty ||
            model.somewhere ||
            model.destination != nil ||
            model.destinationNeighbourhood != nil ||
            model.destinationCity != nil ||
            model.destinationState != nil ||
            model.sometime ||
            model.schedule != nil
    }
    
    @IBAction private func cancelTouch(_ sender: Any) {
        
        guard canSave else {
            cancelTap?()
            return
        }
        
        guard experience == nil else {
            cancelTap?()
            return
        }
        
        let alert = UIAlertController(title: nil, message: "Do you want to save your draft or discard your progress?", preferredStyle: .actionSheet)
        
        let save = UIAlertAction(title: "Save draft", style: .default, handler: { [weak self] _ in
            self?.save()
            self?.cancelTap?()
        })
        
        let discard = UIAlertAction(title: "Discard", style: .destructive, handler: { [weak self] _ in
            self?.reset()
            self?.cancelTap?()
        })
        
        alert.addAction(save)
        alert.addAction(discard)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func previewTouch(_ sender: Any) {
        showPreview()
    }
    
    @IBAction private func moodTouch(_ sender: Any) {
        showMoodSelector()
    }
    
    @objc private func nowSwitchChanged(_ sender: Any) {
        doNow = nowSwitch.isOn
        setupUI()
    }
    
    @objc private func privateSwitchChanged(_ sender: Any) {
        isPrivate = privateSwitch.isOn
        setupUI()
    }
    
    // MARK: - API
    
    func setup(for experience: Experience) {
        self.experience = experience
        
        model.type = experience.type
        model.title = experience.title
        model.text = experience.text
        
        model.images = []
        loadImagesAndVideos(experience.images)
        
        isPrivate = experience.isPrivate ?? false
        model.tier = experience.tier
        
        model.somewhere = experience.anywhere ?? false
        model.destination = experience.destination
        model.destinationName = experience.destinationName
        model.destinationAddress = experience.destinationAddress
        model.destinationNeighbourhood = experience.neighbourhood
        model.destinationCity = experience.city
        model.destinationState = experience.state
    
        model.sometime = experience.schedule == nil
        model.schedule = experience.schedule
            
        model.radius = experience.radius

        setupUI()
    }
    
    func save() {
        if canSave {
            SimpleStoreService.shared.store(item: CreateSignalStoreItem(key: signalDraft, value: model))
        }
    }
    
    func reset() {
        SimpleStoreService.shared.remove(forKey: signalDraft, type: CreateSignalStoreItem.self)
    }
    
    // MARK: - when and where
    
    private func setupWhenAndWhere() {
        if ConfigService.shared.removeWhenAndWhereFromCreate {
            placeHeight.constant = 0
            placeView.isHidden = true
            placeDelimiter.isHidden = true
            scheduleHeight.constant = 0
            scheduleView.isHidden = true
            scheduleDelimiter.isHidden = true
            
            model.somewhere = true
            model.sometime = true
        }
    }
    
    // MARK: - UI setup
    
    private func setupUI() {
        
        // preview button
        previewButton.isEnabled =
            model.type != nil &&
            !model.title.isEmpty &&
            !model.text.isEmpty &&
            !model.images.isEmpty &&
            (model.somewhere || model.destination != nil || model.destinationNeighbourhood != nil || model.destinationCity != nil || model.destinationState != nil) &&
            (model.sometime || model.schedule != nil)
        
        // mood
        if let type = model.type {
            moodLabel.gradientColors = [type.gradient.0.cgColor, type.gradient.1.cgColor]
            moodLabel.text = type.rawValue.uppercased()
        } else {
            moodLabel.gradientColors = nil
            moodLabel.text = "MOOD"
        }
        
        // title
        titleView.text = model.title
        
        // description
        descriptionView.text = model.text
        
        // photos
        photosView.setup(for: model)
        
        // where
        placeView.setup(for: model)
        
        // when
        scheduleView.setup(for: model)
        
        // do now
        if doNow {
            nowLabel.gradientColors = [UIColor.brightSkyBlue.cgColor, UIColor(red: 76, green: 171, blue: 255).cgColor]
            nowLabel.setNeedsDisplay()
            nowSwitch.isOn = true
        } else {
            nowLabel.gradientColors = nil
            nowLabel.setNeedsDisplay()
            nowSwitch.isOn = false
        }
        
        // private
        if isPrivate {
            privateLabel.gradientColors = [UIColor.brightSkyBlue.cgColor, UIColor(red: 76, green: 171, blue: 255).cgColor]
            privateLabel.setNeedsDisplay()
            privateSwitch.isOn = true
            
            tierLabel.isHidden = false
            tierButton.isHidden = false
            
            if let tier = model.tier {
                if let skProduct = InAppPurchaseService.shared.skProduct(for: tier.id) {
                    tierButton.setTitle(skProduct.localizedPrice, for: .normal)
                } else {
                    tierButton.setTitle("??", for: .normal)
                }
            } else {
                tierButton.setTitle("Free", for: .normal)
            }
        } else {
            privateLabel.gradientColors = nil
            privateLabel.setNeedsDisplay()
            privateSwitch.isOn = false
            
            tierLabel.isHidden = true
            tierButton.isHidden = true
        }
    }
    
    // MARK: - locations
    
    private func showLocationSelector() {
        UIResponder.resignAnyFirstResponder()
        
        let vc = CreateSignalPlaceViewController()
        
        vc.back = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.selected = { [weak self] (location, name, address, neighbourhood, city, state) in
            self?.model.somewhere = location == nil
            self?.model.destination = location
            self?.model.destinationName = name
            self?.model.destinationAddress = address
            self?.model.destinationNeighbourhood = neighbourhood
            self?.model.destinationCity = city
            self?.model.destinationState = state
            self?.setupUI()
            self?.dismiss(animated: true, completion: nil)
        }
        present(vc, animated: true, completion: nil)
        
        if let location =  model.destination,
            let name = model.destinationName,
            let address = model.destinationAddress {
            vc.setup(location: location, name: name, address: address, neighbourhood: model.destinationNeighbourhood, city: model.destinationCity, state: model.destinationState)
        } else if model.somewhere {
            vc.setupForAnywhere()
        }
    }
    
    // MARK: - schedule
    
    private func showScheduleSelector() {
        UIResponder.resignAnyFirstResponder()
        
        let vc = CreateSignalScheduleViewController()
        
        vc.back = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.selected = { [weak self] (schedule) in
            self?.model.sometime = schedule == nil
            self?.model.schedule = schedule
            self?.setupUI()
            self?.dismiss(animated: true, completion: nil)
        }
        present(vc, animated: true, completion: nil)
        
        if let schedule =  model.schedule {
            vc.setup(schedule: schedule)
        } else if model.sometime {
            vc.setupForAnytime()
        }
    }
    
    
    // MARK: - photos
    
    private func showPhotoSelector() {
        UIResponder.resignAnyFirstResponder()
        
        let vc = CreateSignalPhotoViewController()
        _ = vc.view
        vc.setup(for: model)
        vc.selected = { [weak self] (images, urls, videos, previews) in
            DispatchQueue.main.async {
                var setup = false
                if let videos = videos, !videos.isEmpty {
                    var newVideos: [CreateExperienceViewModel.Photo] = []
                    for (idx, video) in videos.enumerated() {
                        let preview = (previews?.count ?? 0) > idx ? previews?[idx] : nil
                        newVideos.append(CreateExperienceViewModel.Photo(video: video, videoPreview: preview))
                    }
                    self?.model.images.append(contentsOf: newVideos)
                    setup = true
                }
                if let images = images, !images.isEmpty {
                    let newPhotos = images.map { CreateExperienceViewModel.Photo(image: $0) }
                    self?.model.images.append(contentsOf: newPhotos)
                    setup = true
                }
                if let urls = urls {
                    self?.loadImages(urls)
                }
                if setup { self?.setupUI() }
                self?.dismiss(animated: true, completion: nil)
            }
        }
        present(vc, animated: true, completion: nil)
    }
    
    private func loadImages(_ urls: [String]) {
        for url in urls {
            let photoObj = CreateExperienceViewModel.Photo(url: url)
            model.images.append(photoObj)
            SDWebImageDownloader.shared.downloadImage(
                with: URL(string: url),
                options: .highPriority,
                progress: nil,
                completed: { [weak self] (photo, _, _, _) in
                    if let photo = photo {
                        if let idx = self?.model.images.firstIndex(of: photoObj) {
                            self?.model.images[idx].image = photo
                        }
                        self?.setupUI()
                    }
            })
        }
        setupUI()
    }
    
    private func showDeletePhoto(_ photo: CreateExperienceViewModel.Photo) {
        let alert = UIAlertController(title: "Remove Image?", message: "Would you like to remove this image from the signal?", preferredStyle: .actionSheet)
        
        let yes = UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
            if let idx = self?.model.images.firstIndex(of: photo) {
                self?.model.images.remove(at: idx)
                self?.setupUI()
            }
        })
        
        alert.addAction(yes)
        alert.addAction(UIAlertAction(title: "Leave it", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - mood
    
    private func showMoodSelector() {
        UIResponder.resignAnyFirstResponder()
        
        let vc = CreateSignalMoodViewController()
        
        vc.back = { [weak self] type in
            self?.model.type = type
            self?.setupUI()
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(vc, animated: true, completion: nil)
        
        if let type =  model.type {
            vc.setup(type: type)
        }
    }
    
    // MARK: - tier
    
    @IBAction private func tierTouch(_ sender: Any) {
        
        let tiers = InAppPurchaseService.shared.products.filter { $0.enabled }
            .sorted { (lhs, rhs) -> Bool in
                let lhsPrice = InAppPurchaseService.shared.skProduct(for: lhs.id)?.price ?? 0
                let rhsPrice = InAppPurchaseService.shared.skProduct(for: rhs.id)?.price ?? 0
                return lhsPrice.doubleValue < rhsPrice.doubleValue
            }
        
        let alert = UIAlertController(title: "Price Tier", message: "Please choose a price tier for the experience?", preferredStyle: .actionSheet)
        
        let free = UIAlertAction(title: "Free", style: .default, handler: { [weak self] _ in
            self?.model.tier = nil
            self?.setupUI()
        })
        alert.addAction(free)
        
        for tier in tiers {
            let price = InAppPurchaseService.shared.skProduct(for: tier.id)?.localizedPrice ?? "??"
            let tierAction = UIAlertAction(title: price, style: .default, handler: { [weak self] _ in
                self?.model.tier = tier
                self?.setupUI()
            })
            alert.addAction(tierAction)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - preview
    
    private func showPreview() {
        let vc = CreateSignalPreviewViewController()
        vc.backTap = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.shareTap = { [weak self] in
            self?.createExperience()
        }
        _ = vc.view
        vc.setup(for: model)
        present(vc, animated: true, completion: nil)
    }
    
    private func createExperience() {
        if PushNotificationService.shared.permissionsRequested {
            createExperienceProcess()
        } else {
            PushNotificationService.shared.requestPersmissions { [weak self] in
                DispatchQueue.main.async {
                    self?.createExperience()
                }
            }
        }
    }
    
    private func createExperienceProcess() {
        if LocationService.shared.currentLocation != nil {
            internalCreateExperienceProcess()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: LocationService.Notifications.LocationUpdate, object: nil)
        }
    }
    
    private var preview: CreateSignalPreviewViewController? {
        return presentedViewController as? CreateSignalPreviewViewController
    }
    
    @objc private func locationUpdated() {
        NotificationCenter.default.removeObserver(self, name: LocationService.Notifications.LocationUpdate, object: nil)
        internalCreateExperienceProcess()
    }
    
    private var stepCount: Float = 0
    private var step: Float = 0
    
    private func internalCreateExperienceProcess() {
        if let experience = experience {
            internalUpdateExperienceProcess(experience)
        } else {
            internalCreateNewExperienceProcess()
        }
    }
        
    private func internalCreateNewExperienceProcess() {
        
        stepCount = Float(model.images.count) + 2
        step = 1
        
        preview?.setProgress(step/stepCount)
        
        uploadImages(model.images) { [weak self] (success) in
            
            guard success else { return }
            guard let experience = self?.model.experience(id: "", isPrivate: self?.isPrivate ?? false) else { return }
            
            ExperienceService.shared.createExperience(from: experience) { (experienceId, errorMsg) in
                
                self?.preview?.setProgress(1)
                
                if let experienceId = experienceId {
                    
                    // experience
                    let experienceWithId = experience.experienceWithId(experienceId)
                    
                    // claim
                    if self?.nowSwitch.isOn == true {
                        self?.claim(experience)
                    } else {
                        self?.close(experienceWithId, false)
                    }
                } else {
                    self?.preview?.removeProgress()
                    self?.errorAlert(text: errorMsg ?? "Unknown error")
                }
            }
        }
    }
    
    private func internalUpdateExperienceProcess(_ experience: Experience) {
        
        let imagesToDelete = experience.images.filter { (ei) in !model.images.contains(where:{ (mi) in mi.url == ei.url }) }
        let imagesToUpload = model.images.filter { !$0.isUploaded }
        
        // ordering
        for (idx, image) in model.images.enumerated() {
            if let webImage = image.webImage {
                model.images[idx].webImage = webImage.imageWithOrder(idx + 1)
            }
        }
        
        stepCount = Float(imagesToUpload.count) + 2
        step = 1
        
        deleteImages(imagesToDelete, true) { [weak self] _ in
            
            self?.step += 1
            self?.preview?.setProgress((self?.step ?? 1) / (self?.stepCount ?? 1))
            
            self?.uploadImages(imagesToUpload, true, { (success) in
                
                guard success else { return }
                guard let update = self?.model.experience(id: experience.id, isPrivate: self?.isPrivate ?? false) else { return }

                self?.updateExperience(update, { (success) in
                    
                    self?.preview?.setProgress(1)
                    if success {
                        self?.close(experience, false)
                    } else {
                        self?.preview?.removeProgress()
                        self?.errorAlert(text: "Error while updating")
                    }
                })
            })
        }
    }
    
    // MARK: - claim
    
    private func claim(_ experience: Experience) {
        if ProfileService.shared.profile?.isAdmin == true {
            let alert = UIAlertController(title: "Silent", message: "Do you want this claim to NOT trigger notifications?", preferredStyle: .actionSheet)
            
            let silent = UIAlertAction(title: "Yes, make silent", style: .default, handler: { [weak self] _ in
                self?.executeClaim(experience, true)
            })
            let notSilent = UIAlertAction(title: "No", style: .cancel, handler: { [weak self] _ in
                self?.executeClaim(experience, false)
            })
            
            alert.addAction(silent)
            alert.addAction(notSilent)
            present(alert, animated: true, completion: nil)
            
        } else {
            executeClaim(experience, false)
        }
    }
    
    private func executeClaim(_ experience: Experience, _ silent: Bool) {
        guard let user = ProfileService.shared.profile?.user else { return }
        
        let post = ExperiencePost.create(experience: experience, user: user, isSilent: silent)
            .postWithLocation(LocationService.shared.currentLocation?.geoPoint())
        
        ExperienceService.shared.createExperiencePost(for: experience, post: post) { [weak self] (postId, error) in
            if postId != nil {
                self?.close(experience, true)
            } else {
                self?.preview?.removeProgress()
                self?.errorAlert(text: (error as NSError?)?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    private func uploadImages(_ images:  [CreateExperienceViewModel.Photo],
                              _ success: Bool = true,
                              _ complete: ((_ success: Bool)->())?) {
        
        guard success, let first = images.first else {
            complete?(success)
            return
        }
        
        let restOfImages = Array(images.suffix(from: 1))
        if let video = first.video {
            uploadVideo(video, first.videoPreview, first, restOfImages, success, complete)
        } else if let image = first.image {
            uploadImage(image, first, restOfImages, success, complete)
        }
    }
        
    private func uploadImage(_ image: UIImage,
                             _ photo: CreateExperienceViewModel.Photo,
                             _ rest:  [CreateExperienceViewModel.Photo],
                             _ success: Bool = true,
                             _ complete: ((_ success: Bool)->())?) {
        
        let name = MediaService.newSignalImageFilename()
        MediaService.shared.uploadImage(to: MediaService.Buckets.Signals, name: name, image: image) { [weak self] (imageSuccess, url, path, errorMsg) in
            
            var nextSuccess = success
            if let url = url, let path = path {
                if let idx = self?.model.images.firstIndex(of: photo) {
                    self?.model.images[idx].webImage = Image(
                        id: "\(abs(url.hashValue))",
                        url: url,
                        path: path,
                        order: idx)
                }
            } else {
                nextSuccess = false
            }
            
            self?.step += 1
            self?.preview?.setProgress((self?.step ?? 1) / (self?.stepCount ?? 1))
            
            self?.uploadImages(rest, nextSuccess, complete)
        }
    }
    
    private func uploadVideo(_ data: Data,
                             _ preview: UIImage?,
                             _ photo: CreateExperienceViewModel.Photo,
                             _ rest:  [CreateExperienceViewModel.Photo],
                             _ success: Bool = true,
                             _ complete: ((_ success: Bool)->())?) {
        
        let name = MediaService.newSignalVideoFilename()
        MediaService.shared.uploadVideo(to: MediaService.Buckets.Signals, name: name, data: data) { [weak self] (videoSuccess, url, path, errorMsg) in
            
            var nextSuccess = success
            if let url = url, let path = path {
                if let preview = preview {
                    let previewName = MediaService.newSignalVideoPreviewFilename()
                    MediaService.shared.uploadImage(to: MediaService.Buckets.Signals, name: previewName, image: preview, compression: 0.5) { [weak self] (success, previewUrl, previewPath, errorMsg) in
                        
                        if let idx = self?.model.images.firstIndex(of: photo) {
                            self?.model.images[idx].webImage = Image(
                                id: "\(abs(url.hashValue))",
                                url: url,
                                path: path,
                                order: idx,
                                isVideo: true,
                                previewUrl: previewUrl,
                                previewPath: previewPath)
                        }
                        
                        self?.step += 1
                        self?.preview?.setProgress((self?.step ?? 1) / (self?.stepCount ?? 1))
                        
                        self?.uploadImages(rest, nextSuccess, complete)
                    }
                    return
                }
                
                if let idx = self?.model.images.firstIndex(of: photo) {
                    self?.model.images[idx].webImage = Image(
                        id: "\(abs(url.hashValue))",
                        url: url,
                        path: path,
                        order: idx,
                        isVideo: true)
                }
            } else {
                nextSuccess = false
            }
            
            self?.step += 1
            self?.preview?.setProgress((self?.step ?? 1) / (self?.stepCount ?? 1))
            
            self?.uploadImages(rest, nextSuccess, complete)
        }
    }
    
    private func close(_ experience: Experience, _ claimed: Bool) {
        reset()
        dismiss(animated: true, completion: { [weak self] in
            self?.finished?(experience, claimed)
        })
    }
    
    // MARK: - edit
    
    private func loadImagesAndVideos(_ images: [Image]) {
        for image in images {
            guard let url = URL(string: image.url) else { continue }
            var photoObj = CreateExperienceViewModel.Photo(url: image.url, isUploaded: true)
            photoObj.webImage = image
            model.images.append(photoObj)
            
            if image.isVideo == true {
                let session = URLSession.shared
                let task = session.dataTask(with: url) { [weak self] (data, _, _) in
                    if let data = data {
                        if let idx = self?.model.images.firstIndex(of: photoObj) {
                            self?.model.images[idx].video = data
                            DispatchQueue.main.async {
                                self?.setupUI()
                            }
                        }
                        if let previewUrl = URL(string: image.previewUrl ?? "") {
                            SDWebImageDownloader.shared.downloadImage(
                                with: previewUrl,
                                options: .highPriority,
                                progress: nil,
                                completed: { [weak self] (photo, _, _, _) in
                                    if let photo = photo {
                                        if let idx = self?.model.images.firstIndex(of: photoObj) {
                                            self?.model.images[idx].videoPreview = photo
                                        }
                                    }
                            })
                        }
                    }
                }
                task.resume()
            } else {
                SDWebImageDownloader.shared.downloadImage(
                    with: url,
                    options: .highPriority,
                    progress: nil,
                    completed: { [weak self] (photo, _, _, _) in
                        if let photo = photo {
                            if let idx = self?.model.images.firstIndex(of: photoObj) {
                                self?.model.images[idx].image = photo
                                self?.setupUI()
                            }
                        }
                })
            }
        }
    }
    
    private func deleteImages(_ images:  [Image],
                              _ success: Bool = true,
                              _ complete: ((_ success: Bool)->())?) {
        
        guard success, let first = images.first else {
            complete?(success)
            return
        }
        
        let restOfImages = Array(images.suffix(from: 1))
        Storage.storage().reference(withPath: first.path).delete { [weak self] (error) in
            if let path = first.previewPath {
                Storage.storage().reference(withPath: path).delete { (error) in
                    self?.deleteImages(restOfImages, true, complete)
                }
            } else {
                self?.deleteImages(restOfImages, true, complete)
            }
        }
    }
    
    private func updateExperience(_ experience:  Experience,
                                  _ complete: ((_ success: Bool)->())?) {
        
        guard let data = experience.json else {
            complete?(false)
            return
        }
        
        Firestore.firestore().document(ExperienceService.Paths.experience(experience.id))
            .setData(data) { (error) in
                
                if let point = experience.destination {
                    ExperienceService.shared.updateExperienceDestination(experienceId: experience.id, destination: point)
                }
                
                complete?(error == nil)
            }
    }
}
