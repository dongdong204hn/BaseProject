#
#  Be sure to run `pod spec lint NIPCommonUtilities.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your Utilities, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "NIPCommonUtilities"
  s.version      = "0.1.0"
  s.summary      = "Common Utilities of NSIP iOS team."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                    Common Utilities of NSIP iOS team. Three.
                   DESC

  s.homepage     = "https://git.ms.netease.com/Three/BaseProject"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the Utilities, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "赵松" => "bjzhaosong@corp.netease.com" }
  # Or just: s.author    = "赵松"
  # s.authors            = { "赵松" => "bjzhaosong@corp.netease.com" }
  # s.social_media_url   = "http://twitter.com/赵松"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  s.platform     = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://git.ms.netease.com/Three/BaseProject.git", :tag => "v#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files = "Utilities/nip_common_lib/nip_common_lib.h"
  # s.source_files  = "Utilities/nip_common_lib/nip_basic_additions/*","Utilities/nip_common_lib/nip_basic_utils/*","Utilities/nip_common_lib/nip_controller/*","Utilities/nip_common_lib/nip_controller/nip_controller_url/*","Utilities/nip_common_lib/nip_controller/nip_controller_util/*","Utilities/nip_common_lib/nip_introspection/*","Utilities/nip_common_lib/nip_network/*","Utilities/nip_common_lib/nip_ui/*","Utilities/nip_common_lib/nip_ui/nip_ui_additions/*","Utilities/nip_common_lib/nip_ui/nip_ui_alert/*","Utilities/nip_common_lib/nip_ui/nip_ui_container/*","Utilities/nip_common_lib/nip_ui/nip_ui_layout/*","Utilities/nip_common_lib/nip_ui/nip_ui_popup/*","Utilities/nip_common_lib/nip_ui/nip_ui_util/*","Utilities/nip_common_lib/nip_ui/nip_ui_views/*"
  # s.source_files  = "Classes", "Classes/**/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Utilities/nip_common_lib/nip_common_lib.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your Utilities with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.Utilities   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your Utilities depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your Utilities. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "AFNetworking", "~> 3.1.0"

  s.subspec 'nip_macros' do |nip_macros|
      nip_macros.source_files = 'Utilities/nip_common_lib/nip_macros/*'
      nip_macros.public_header_files = 'Utilities/nip_common_lib/nip_macros/nip_macros.h'
  end

  s.subspec 'nip_basic_additions' do |nip_basic_additions|
      nip_basic_additions.source_files = 'Utilities/nip_common_lib/nip_basic_additions/*',
      nip_basic_additions.public_header_files = 'Utilities/nip_common_lib/nip_basic_additions/*.h'
      nip_basic_additions.dependency 'NIPCommonUtilities/nip_macros'
  end

  s.subspec 'nip_basic_utils' do |nip_basic_utils|
      nip_basic_utils.source_files = 'Utilities/nip_common_lib/nip_basic_utils/*','Utilities/nip_common_lib/nip_basic_utils/nip_pinyin/nip_pinyin_class/*'
      nip_basic_utils.public_header_files = 'Utilities/nip_common_lib/nip_basic_utils/*.h','Utilities/nip_common_lib/nip_basic_utils/nip_pinyin/nip_pinyin_class/*.h'
      nip_basic_utils.dependency 'NIPCommonUtilities/nip_macros'
      nip_basic_utils.dependency 'NIPCommonUtilities/nip_basic_additions'
      nip_basic_utils.resource = "Utilities/nip_common_lib/nip_basic_utils/nip_pinyin/nip_pinyin_resources/unicode_to_hanyu_pinyin.txt",'Utilities/nip_common_lib/resources/*'
  end

  s.subspec 'nip_controller' do |nip_controller|
      nip_controller.source_files = 'Utilities/nip_common_lib/nip_controller/*',"Utilities/nip_common_lib/nip_controller/nip_controller_url/*","Utilities/nip_common_lib/nip_controller/nip_controller_util/*"
      nip_controller.public_header_files = 'Utilities/nip_common_lib/nip_controller/*.h','Utilities/nip_common_lib/nip_controller/nip_controller_url/*.h','Utilities/nip_common_lib/nip_controller/nip_controller_util/*.h'
      nip_controller.dependency 'NIPCommonUtilities/nip_basic_additions'
      nip_controller.dependency 'NIPCommonUtilities/nip_ui'
      nip_controller.dependency 'MBProgressHUD', '~> 1.0.0'
  end

  s.subspec 'nip_introspection' do |nip_introspection|
      nip_introspection.source_files = "Utilities/nip_common_lib/nip_introspection/*"
      nip_introspection.public_header_files = "Utilities/nip_common_lib/nip_introspection/*.h"
  #    nip_introspection.resource = "Pod/Assets/MLSUIKitResource.bundle"
      nip_introspection.dependency 'NIPCommonUtilities/nip_basic_utils'
  end

  s.subspec 'nip_ui' do |nip_ui|
      nip_ui.source_files = "Utilities/nip_common_lib/nip_ui/*","Utilities/nip_common_lib/nip_ui/nip_ui_additions/*","Utilities/nip_common_lib/nip_ui/nip_ui_alert/*","Utilities/nip_common_lib/nip_ui/nip_ui_container/*","Utilities/nip_common_lib/nip_ui/nip_ui_layout/*","Utilities/nip_common_lib/nip_ui/nip_ui_popup/*","Utilities/nip_common_lib/nip_ui/nip_ui_util/*","Utilities/nip_common_lib/nip_ui/nip_ui_views/*"
      nip_ui.public_header_files = 'Utilities/nip_common_lib/nip_ui/*.h','Utilities/nip_common_lib/nip_ui/nip_ui_additions/*.h','Utilities/nip_common_lib/nip_ui/nip_ui_alert/*.h','Utilities/nip_common_lib/nip_ui/nip_ui_container/*.h','Utilities/nip_common_lib/nip_ui/nip_ui_layout/*.h','Utilities/nip_common_lib/nip_ui/nip_ui_popup/*.h','Utilities/nip_common_lib/nip_ui/nip_ui_util/*.h','Utilities/nip_common_lib/nip_ui/nip_ui_views/*.h'
      nip_ui.dependency 'NIPCommonUtilities/nip_basic_utils'
  end

  s.subspec 'nip_network' do |nip_network|
      nip_network.source_files = "Utilities/nip_common_lib/nip_network/*","Utilities/nip_common_lib/nip_network/nip_httpManager/*","Utilities/nip_common_lib/nip_network/nip_request/*","Utilities/nip_common_lib/nip_network/nip_response/*","Utilities/nip_common_lib/nip_network/transcoder&encryptor/*"
      nip_network.public_header_files = 'Utilities/nip_common_lib/nip_network/*.h','Utilities/nip_common_lib/nip_network/nip_httpManager/*.h','Utilities/nip_common_lib/nip_network/nip_request/*.h','Utilities/nip_common_lib/nip_network/nip_response/*.h','Utilities/nip_common_lib/nip_network/transcoder&encryptor/*.h'
      nip_network.dependency 'NIPCommonUtilities/nip_basic_utils'
      nip_network.dependency 'AFNetworking', '~> 3.1.0'
  end

end
