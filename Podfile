# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

def rx_swift
    pod 'RxSwift'
end

def rx_cocoa
    pod 'RxCocoa'
end

def test_pods
    pod 'RxTest'
    pod 'RxBlocking'
    pod 'Nimble'
end

target 'Vocal Voter' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Vocal Voter
  rx_cocoa
  rx_swift
  pod 'QueryKit'
  
  pod 'IQKeyboardManagerSwift'
  pod 'PopupDialog'
  pod 'CropViewController'
  pod 'Material'
  pod 'PhoneNumberKit'
  pod 'SwiftMessages'
  pod 'JGProgressHUD'
  pod 'Kingfisher'
  pod 'CryptoSwift'

end

target 'Domain' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    rx_swift
end

target 'NetworkPlatform' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    rx_swift
    pod 'Alamofire'
    pod 'RxAlamofire'
    pod 'ObjectMapper'
    pod 'AlamofireObjectMapper'
    
    pod 'MicrosoftAzureMobile'
    pod 'AZSClient'
end

