platform :ios, '10.0'

def testing_pods
    pod 'Quick'
    pod 'Nimble', :inhibit_warnings => true
end

target 'ASCollectionView' do
  use_frameworks!

  target 'ASCollectionViewTests' do
    inherit! :search_paths
    testing_pods
  end

end
