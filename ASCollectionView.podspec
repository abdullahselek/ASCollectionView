Pod::Spec.new do |s|

    s.name                = 'ASCollectionView'
    s.version             = '1.0.8'
    s.summary             = 'A Swift collection view inspired by Airbnb'
    s.homepage            = 'https://github.com/abdullahselek/ASCollectionView'
    s.license             = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author              = {
        'Abdullah Selek' => 'abdullahselek@yahoo.com'
    }
    s.source              = {
        :git => 'https://github.com/abdullahselek/ASCollectionView.git',
        :tag => s.version.to_s
    }
    s.ios.deployment_target = '9.0'
    s.source_files        = 'ASCollectionView/Source/*.swift'
    s.requires_arc        = true

end