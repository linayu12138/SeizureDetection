//
//  ControllerModeViewController.swift
//  Bluefruit Connect
//
//  Created by Antonio García on 12/02/16.
//  Copyright © 2016 Adafruit. All rights reserved.
//

import UIKit

class ControllerModeViewController: PeripheralModeViewController {

    // Constants
    fileprivate static let kPollInterval = 0.25

    // UI
    @IBOutlet weak var baseTableView: UITableView!
    @IBOutlet weak var uartWaitingLabel: UILabel!

    // Data
    fileprivate var controllerData: ControllerModuleManager!
    fileprivate var contentItems = [Int]()
    fileprivate weak var controllerPadViewController: ControllerPadViewController?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Title
        let localizationManager = LocalizationManager.shared
        let name = blePeripheral?.name ?? LocalizationManager.shared.localizedString("scanner_unnamed")
        self.title = traitCollection.horizontalSizeClass == .regular ? String(format: localizationManager.localizedString("controller_navigation_title_format"), arguments: [name]) : localizationManager.localizedString("controller_tab_title")
        
        // Init
        assert(blePeripheral != nil)
        controllerData = ControllerModuleManager(blePeripheral: blePeripheral!, delegate: self)

        updateUartUI(isReady: false)

        //
        updateContentItemsFromSensorsEnabled()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isMovingToParent {       // To keep streaming data when pushing a child view
            controllerData.start(pollInterval: ControllerModeViewController.kPollInterval) { [unowned self] in
                self.baseTableView.reloadData()
            }

        } else {
            // Disable cache if coming back from Control Pad
            controllerData.isUartRxCacheEnabled = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {     // To keep streaming data when pushing a child view
            controllerData.stop()

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        DLog("ControllerModeViewController deinit")
    }

    // MARK: - UI
    fileprivate func updateUartUI(isReady: Bool) {
        // Setup UI
        uartWaitingLabel.isHidden = isReady
        baseTableView.isHidden = !isReady
    }

    fileprivate let kDetailItemOffset = 100
    fileprivate func updateContentItemsFromSensorsEnabled() {
        // Add to contentItems the current rows (ControllerType.rawValue for each sensor and kDetailItemOffset+ControllerType.rawValue for a detail cell)
        
        let availableControllers: [ControllerModuleManager.ControllerType]
        #if targetEnvironment(macCatalyst)
        // Only location is available on macCatalyst
        availableControllers = [.location]
        #else
        availableControllers = ControllerModuleManager.ControllerType.allCases
        #endif
        
        var items = [Int]()
        availableControllers.forEach { controllerType in
            
            let isSensorEnabled = controllerData.isSensorEnabled(controllerType: controllerType)
            items.append(controllerType.rawValue)
            if isSensorEnabled {
                items.append(controllerType.rawValue+kDetailItemOffset)
            }
        }

        contentItems = items
    }


    // MARK: - Send Data

    func sendTouchEvent(tag: Int, isPressed: Bool) {
        let message = "!B\(tag)\(isPressed ? "1" : "0")"
        if let data = message.data(using: String.Encoding.utf8) {
            controllerData.sendCrcData(data)
        }
    }
}

// MARK: - ControllerPadViewControllerDelegate
extension ControllerModeViewController: ControllerPadViewControllerDelegate {
    func onSendControllerPadButtonStatus(tag: Int, isPressed: Bool) {
        sendTouchEvent(tag: tag, isPressed: isPressed)
    }
}

// MARK: - UITableViewDataSource
extension ControllerModeViewController : UITableViewDataSource {
    fileprivate static let kSensorTitleKeys: [String] = ["controller_sensor_quaternion", "controller_sensor_accelerometer", "controller_sensor_gyro", "controller_sensor_magnetometer", "controller_sensor_location"]
    fileprivate static let kModuleTitleKeys: [String] = ["controller_module_pad", "controller_module_colorpicker"]
    
    enum ControllerSection: Int {
        case sensorData = 0
        case module = 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ControllerSection(rawValue: section)! {
        case .sensorData:
            //let enabledCount = sensorsEnabled.filter{ $0 }.count
            //return ControllerModeViewController.kSensorTitleKeys.count + enabledCount
            return contentItems.count
        case .module:
            return ControllerModeViewController.kModuleTitleKeys.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var localizationKey: String!

        switch ControllerSection(rawValue: section)! {
        case .sensorData:
            localizationKey = "controller_sensor_title"
        case .module:
            localizationKey = "controller_module_title"
        }

        return LocalizationManager.shared.localizedString(localizationKey)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let localizationManager = LocalizationManager.shared
        var cell: UITableViewCell!
        switch ControllerSection(rawValue: indexPath.section)! {

        case .sensorData:
            let item = contentItems[indexPath.row]
            let isDetailCell = item>=kDetailItemOffset

            if isDetailCell {
                let controllerType = ControllerModuleManager.ControllerType(rawValue: item - kDetailItemOffset)!
                let reuseIdentifier = "ComponentsCell"
                let componentsCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ControllerComponentsTableViewCell
                
                if let sensorData = controllerData.getSensorData(controllerType: controllerType) {
                    let componentNameId: [String]
                    if controllerType == ControllerModuleManager.ControllerType.location {
                        componentNameId = ["controller_component_lat", "controller_component_long", "controller_component_alt"]
                    } else {
                        componentNameId = ["controller_component_x", "controller_component_y", "controller_component_z", "controller_component_w"]
                    }
                    
                    var i=0
                    for subview in componentsCell.componentsStackView.subviews {
                        let hasComponent = i<sensorData.count
                        subview.isHidden = !hasComponent
                        if let label = subview as? UILabel, hasComponent {
                            let componentName = LocalizationManager.shared.localizedString(componentNameId[i])
                            let attributedText = NSMutableAttributedString(string: "\(componentName): \(sensorData[i])")
                            let titleLength = componentName.lengthOfBytes(using: String.Encoding.utf8)
                            attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium), range: NSMakeRange(0, titleLength))
                            label.attributedText = attributedText
                        }

                        i += 1
                    }
                } else {
                    for subview in componentsCell.componentsStackView.subviews {
                        subview.isHidden = true
                    }
                }

                cell = componentsCell
            }

        case .module:
            let reuseIdentifier = "ModuleCell"
            cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            }
            cell.accessoryType = .disclosureIndicator
            cell.textLabel!.text = localizationManager.localizedString(ControllerModeViewController.kModuleTitleKeys[indexPath.row])
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ControllerSection(rawValue: indexPath.section)! {
        case .sensorData:
            let item = contentItems[indexPath.row]
            let isDetailCell = item>=kDetailItemOffset
            return isDetailCell ? 120: 44
        default:
            return 44
        }
    }
}

// MARK: UITableViewDelegate
extension ControllerModeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch ControllerSection(rawValue: indexPath.section)! {
        case .module:
            if indexPath.row == 0 {
                if let viewController = storyboard!.instantiateViewController(withIdentifier: "ControllerPadViewController") as? ControllerPadViewController {
                    controllerPadViewController = viewController
                    viewController.delegate = self
                    navigationController?.show(viewController, sender: self)

                    // Enable cache for control pad
                    controllerData.uartRxCacheReset()
                    controllerData.isUartRxCacheEnabled = true
                }
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ControllerModuleManagerDelegate
extension ControllerModeViewController: ControllerModuleManagerDelegate {
    func onControllerUartIsReady(error: Error?) {
        DispatchQueue.main.async {
            self.updateUartUI(isReady: error == nil)
            guard error == nil else {
                DLog("Error initializing uart")
                self.dismiss(animated: true, completion: { [weak self] in
                    guard let context = self else { return }
                    let localizationManager = LocalizationManager.shared
                    showErrorAlert(from: context, title: localizationManager.localizedString("dialog_error"), message: localizationManager.localizedString("uart_error_peripheralinit"))
                    
                    if let blePeripheral = context.blePeripheral {
                        BleManager.shared.disconnect(from: blePeripheral)
                    }
                })
                return
            }

            // Uart Ready
            self.baseTableView.reloadData()
        }
    }

    func onUarRX() {
        // Uart data recevied

        // Only reloadData when controllerPadViewController is loaded
        guard controllerPadViewController != nil else { return }

        self.enh_throttledReloadData()      // it will call self.reloadData without overloading the main thread with calls
    }

    @objc func reloadData() {
        // Refresh the controllerPadViewController uart text
        self.controllerPadViewController?.setUartText(self.controllerData.uartTextBuffer())

    }
}
