import UIKit
import Photos
 
class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
     
    ///取得的资源结果，用了存放的PHAsset
    var assetsFetchResults: PHFetchResult<PHAsset>?
     
    ///缩略图大小
    var assetGridThumbnailSize: CGSize!
     
    /// 带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewLayout = {
            return UICollectionViewLayout()
        }()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NewPostCollectionViewCell.self, forCellWithReuseIdentifier: NewPostCollectionViewCell.identifier)
        return collectionView
    }()

     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        let scale = UIScreen.main.scale
        assetGridThumbnailSize = CGSize(width:300*scale,
                                        height:300*scale)
        //申请权限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
             
            //则获取所有资源
            let allPhotosOptions = PHFetchOptions()
            //按照创建时间倒序排列
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                                 ascending: false)]
            //只获取图片
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                     PHAssetMediaType.image.rawValue)
            
            self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                     options: allPhotosOptions)
             
            // 初始化和重置缓存
            self.imageManager = PHCachingImageManager()
            self.resetCachedAssets()
             
            //collection view 重新加载数据
            DispatchQueue.main.async{
                self.collectionView.reloadData()
            }
        })
    }
     
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
     
    // CollectionView行数
    func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults?.count ?? 0
    }
     
    // 获取单元格
    func collectionView(_ collectionView: UICollectionView,
                    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 获取设计的单元格，不需要再动态添加界面元素
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewPostCollectionViewCell.identifier, for: indexPath) as? NewPostCollectionViewCell else {
            return UICollectionViewCell()
        }
        print(assetsFetchResults)
         
        if let asset = self.assetsFetchResults?[indexPath.row] {
            //获取缩略图
            self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                        contentMode: PHImageContentMode.aspectFill,
                        options: nil) { (image, nfo) in
//                cell.image.image = image
                print(asset)
            }
        }
         
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
