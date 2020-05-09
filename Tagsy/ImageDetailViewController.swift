//
//  ImageDetailViewController.swift
//  Tagsy
//
//  Created by Sebastian Murgu on 2020-03-09.
//  Copyright © 2020 Sebastian Murgu. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var colorsCollectionView: UICollectionView!
  @IBOutlet weak var tagsCollectionView: UICollectionView!
  
  var uploadedImage: UploadedImage?

  override func viewDidLoad() {
      super.viewDidLoad()

      colorsCollectionView.delegate = self
      tagsCollectionView.delegate = self

      colorsCollectionView.dataSource = self
      tagsCollectionView.dataSource = self
  }

  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      loadDataIntoUI()
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      if collectionView == tagsCollectionView {
          return uploadedImage?.tags.count ?? 0
      }

      if collectionView == colorsCollectionView {
          return uploadedImage?.colors.count ?? 0
      }

      return 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      switch collectionView {
      case tagsCollectionView:
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? TagCell

          cell?.textLabel.text = uploadedImage?.tags[indexPath.row]

          return cell!
      case colorsCollectionView:
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)

          if let color: ImageColor = uploadedImage?.colors[indexPath.row] {
              cell.contentView.backgroundColor = UIColor(red: CGFloat(color.red) / 255.0, green: CGFloat(color.green) / 255.0, blue: CGFloat(color.blue) / 255.0, alpha: 1.0)
          }

          return cell
      default:
          let cell = colorsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
          return cell
      }
  }

  func loadDataIntoUI() {
      guard let uploaded = uploadedImage else { return }

      imageView.image = uploaded.image

      tagsCollectionView.reloadData()
      colorsCollectionView.reloadData()
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
