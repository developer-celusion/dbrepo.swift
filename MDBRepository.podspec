#
# Be sure to run `pod lib lint MDBRepository.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MDBRepository'
  s.version          = '1.0.0'
  s.summary          = 'Database Repository Pattern on GRDB with cipher'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Our main focus to remove boilderplate code for Database Operation in iOS. This is comes with database repository pattern on GRDB
                       DESC

  s.homepage         = 'https://github.com/developer-celusion/dbrepo.swift.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'swapnil.nandgave@celusion.com' => 'swapnil.nandgave@celusion.com' }
  s.source           = { :git => 'https://github.com/developer-celusion/dbrepo.swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MDBRepository/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MDBRepository' => ['MDBRepository/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'GRDB.swift'
    s.dependency 'GRDBCipher'
end
