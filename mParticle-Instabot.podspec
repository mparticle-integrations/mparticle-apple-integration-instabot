Pod::Spec.new do |s|
    s.name             = "mParticle-Instabot"
    s.version          = "7.5.1"
    s.summary          = "Instabot integration for mParticle"

    s.description      = <<-DESC
                       This is the Instabot integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-instabot.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/rokolabs"

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-Instabot/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 7.5.0'
    s.ios.dependency 'ROKO.Mobi'
    s.ios.pod_target_xcconfig = {
        'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/ROKO.Mobi/**',
        'OTHER_LDFLAGS' => '$(inherited) -framework "ROKOMobi"'
    }
end
