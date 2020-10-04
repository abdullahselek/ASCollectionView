Pod::Spec.new do |s|

    s.name                  = 'ASCollectionView'
    s.version               = '1.3.0'
    s.summary               = 'Lightweight custom collection view inspired by Airbnb.'
    s.homepage              = 'https://github.com/abdullahselek/ASCollectionView'
    s.license               = {
        :type => 'MIT',
        :file => 'LICENSE'
    }
    s.author                = {
        'Abdullah Selek' => 'abdullahselek@gmail.com'
    }
    s.source                = {
        :git => 'https://github.com/abdullahselek/ASCollectionView.git',
        :tag => s.version.to_s
    }
    s.ios.deployment_target = '10.0'
    s.source_files          = 'ASCollectionView/Source/*.swift'
    s.requires_arc          = true
    s.swift_versions        = ['5.0', '5.1', '5.2', '5.3']

end
