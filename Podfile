
platform :ios, '9.0'
use_frameworks!


def shared_pods
	pod 'CoreValue'
	pod 'Dip'
	pod 'Dip-UI'
end

target 'Core Value Movies' do
   shared_pods	
   
   post_install do |installer|
       installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
           config.build_settings['SWIFT_VERSION'] = '3.0'
         end
       end
     end
	 
end

target 'Core Value MoviesTests' do
    inherit! :search_paths
    shared_pods
end
