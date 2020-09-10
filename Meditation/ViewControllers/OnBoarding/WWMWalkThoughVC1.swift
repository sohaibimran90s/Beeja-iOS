//
//  WWMWalkThoughVC1.swift
//  Meditation
//
//  Created by Prema Negi on 20/04/2020.
//  Copyright © 2020 Cedita. All rights reserved.
//

import UIKit
import Reachability

class WWMWalkThoughVC1: WWMBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblLoginText: UILabel!
    
    var thisWidth:CGFloat = 0
    let appPreffrence = WWMAppPreference()
    let reachable = Reachabilities()
    var onBoardingDataModel: [OnBoardingDataModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.underLineLbl()
        thisWidth = CGFloat(self.view.frame.width)

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: thisWidth, height: 370)
        
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        
        if !reachable.isConnectedToNetwork() {
            self.offlineJsonFileCall()
            return
        }
        
        apiCall()
    }
    
    func apiCall(){
        
        if !self.appPreffrence.getOnBoardingData().isEmpty{
            //print("not empty")
            self.decodeModel(json: self.appPreffrence.getOnBoardingData() as AnyObject)
            
            return
        }
        
        self.getOnBoardingAPI()
    }
    
    func getOnBoardingAPI(){
        
        self.offlineJsonFileCall()
        
        WWMWebServices.requestAPIWithBody(param: [:], urlString: URL_ONBOARDING, context: "WWMSplashLoaderVC", headerType: kGETHeader, isUserToken: false) { (result, error, sucess) in
           
            if sucess {
                self.appPreference.setOnBoardingData(value: result)
                if !self.appPreffrence.getOnBoardingData().isEmpty{
                    DispatchQueue.main.async {
                        self.decodeModel(json: self.appPreffrence.getOnBoardingData() as AnyObject)
                    }
                }
            }
        }
    }
    
    func underLineLbl(){
    
        let underLineColor: UIColor = UIColor.init(red: 0.0/255.0, green: 235.0/255.0, blue: 169.0/255.0, alpha: 1.0)
        let underLineStyle = NSUnderlineStyle.single.rawValue

        let labelAtributes:[NSAttributedString.Key : Any]  = [NSAttributedString.Key.underlineStyle: underLineStyle,
            NSAttributedString.Key.underlineColor: underLineColor
        ]

        let underlineAttributedString = NSAttributedString(string: "Already have an account?", attributes: labelAtributes)

        lblLoginText.attributedText = underlineAttributedString
    }
    
    @objc func moveToNextPage (){

        let pageWidth:CGFloat = thisWidth
        let maxWidth:CGFloat = pageWidth * CGFloat(self.onBoardingDataModel.count)
        let contentOffset:CGFloat = self.collectionView.contentOffset.x

        //print("..contentOffset + pageWidth...\(contentOffset + pageWidth) maxwidth...\(maxWidth)")

        var slideToX = contentOffset + pageWidth
        if  contentOffset + pageWidth == maxWidth {
            slideToX = 0

        }
        
        self.collectionView.scrollRectToVisible(CGRect(x: slideToX, y: 0, width: pageWidth, height:self.collectionView.frame.height), animated: true)
    }
    
    @IBAction func btnSignUpAction(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMSignupEmailVC") as! WWMSignupEmailVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnLoginAction(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "WWMLoginWithEmailVC") as! WWMLoginWithEmailVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func offlineJsonFileCall(){
        
        guard let path = Bundle.main.path(forResource: "OnBoardingFile", ofType: "txt") else{
            return
        }
        print(path)
        
        let url = URL(fileURLWithPath: path)
        do{
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            self.decodeModel(json: json as AnyObject)
   
        }catch{
            print(error)
        }
    }
    
    func decodeModel(json: AnyObject){
        do{
            let decoder = JSONDecoder()
            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: json , options: .prettyPrinted)
            let moods = try decoder.decode(OnBoardingModel.self, from: jsonData!)
            //print("+++ \(moods.data ?? [])")
            self.onBoardingDataModel = moods.data ?? []
            self.collectionView.reloadData()
            pageControl.numberOfPages = self.onBoardingDataModel.count
            _ = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
        }catch let error{
            //print("error found \(error)")
        }
    }
}

extension WWMWalkThoughVC1: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.onBoardingDataModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let sliderImg = cell.viewWithTag(1) as! UIImageView
        let lblTitle = cell.viewWithTag(2) as! UILabel
        let lblDes = cell.viewWithTag(3) as! UILabel
        
        if !reachable.isConnectedToNetwork() {
            sliderImg.image = UIImage(named: self.onBoardingDataModel[indexPath.item].image ?? "onboardingImg1" )
            print()
        }else{
            sliderImg.sd_setImage(with: URL(string: self.onBoardingDataModel[indexPath.item].image ?? ""), placeholderImage: UIImage(named: "onboardingImg1"))
        }
        
        lblTitle.text = self.onBoardingDataModel[indexPath.item].title ?? ""
        lblDes.text = self.onBoardingDataModel[indexPath.item].description ?? ""
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        thisWidth = CGFloat(self.collectionView.frame.width)
        return CGSize(width: thisWidth, height: 370)
    }
    
    //UIScrollView INT TO COUNT
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let pageWidth : CGFloat = thisWidth
        self.pageControl.currentPage = Int(self.collectionView.contentOffset.x/pageWidth)
    }
}



