#
# Be sure to run `pod lib lint TheRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TheRouter'
  s.version          = '1.1.8'
  s.summary          = 'TheRouter一个用于模块间解耦和通信，基于Swift协议进行动态懒加载注册路由与打开路由的工具。同时支持通过Service-Protocol寻找对应的模块，并用 protocol进行依赖注入和模块通信。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/HuolalaTech/therouter-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mars' => 'mars.yao' }
  s.source           = { :git => 'https://github.com/HuolalaTech/hll-wp-therouter-ios.git', :tag => s.version.to_s } 
  s.source_files = 'TheRouter/Classes/**/*', 'TheRouter/Classes/TheRouter/Sources/TheRouter/*'
  s.exclude_files = 'TheRouter/Classes/TheRouterable/Package.swift'
  s.frameworks = 'UIKit', 'Foundation'
  s.ios.deployment_target = '11.0'
  # swift 支持的版本
  s.swift_version = '5.0'
  s.static_framework = true
  s.xcconfig = {"ENABLE_BITCODE" => "NO"}
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS[config=Debug]' => '-D DEBUG'
  }

  s.subspec 'TheRouterMacro' do |macro|
    macro.source_files = 'TheRouterMacro/Sources/TheRouterMacro/*'
    macro.preserve_paths = 'TheRouterMacro/Package.swift', 'TheRouterMacro/Sources/**/*'

    product_folder = "${PODS_BUILD_DIR}/Products/TheRouterMacroMacros"

    script = <<-SCRIPT.squish
    env -i PATH="$PATH" "$SHELL" -l -c
    "swift build -c release --product TheRouterMacroMacros
    --package-path \\"$PODS_TARGET_SRCROOT/TheRouterMacro\\"
    --scratch-path \\"#{product_folder}\\""
    SCRIPT

    macro.script_phase = {
        :name => 'Build TheRouterMacroMacros macro plugin',
        :script => script,
        :input_files => Dir.glob("{TheRouterMacro/Package.swift,TheRouterMacro/Sources/**/*}").map {
        |path| "$(PODS_TARGET_SRCROOT)/#{path}"
        },
        :output_files => ["#{product_folder}/release/TheRouterMacroMacros"],
        :execution_position => :before_compile
    }

    macro.user_target_xcconfig = {
        'OTHER_SWIFT_FLAGS' => <<-FLAGS.squish
        -Xfrontend -load-plugin-executable
        -Xfrontend #{product_folder}/release/TheRouterMacroMacros#TheRouterMacroMacros
        FLAGS
    }
  end
end

