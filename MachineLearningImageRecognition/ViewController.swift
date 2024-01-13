/*
Machine Learnings
 -https://developer.apple.com sitesine gidip arama yerine core ml yazdık ilk çıkan CoreML Girdik
 Core ML bir makine öğrenmesidir. Açılan sitede aşağı inip Topics ten Core ML Models ten ilkine tıkladık. Ardından açılan yerde model a tıkladık.Amacımız Image Classification (Görsel sınıflandırma) biz MobileNetV2 den ilerledik onun altındaki View Models and Code Sample tıkladık. Açılan popa ekranı gibi 3 versiyon(8,16,32 bitler) hepsi aynı bit farkı var bitler artınca görseli kadar detaylı işleyebiliriz biz 32 bitliyi kullanıyoruz Download diyip indirdik ve en alttaki dökümandır View Code tıkladık.inceleyebiliriz
 -Core ML framework kullanıcaz eğitilmiş bir makine öğrenimi modelini entegre edicez
 -Indiğimiz dosyayı diğer proje klasörüne Maus ile tutup alabiliriz çıkan pencerede copy items if needed işaretli olucak ve targette işaret li olucak
 
 */
import UIKit
//eklendi
import CoreML
//eklendi
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //resim yerine gitmesi
    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true,completion: nil)
    }
    
    //resim seçildikten sonra sı
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        //eski modellerede plistten resim izni için seçebiliriz yenilerde gerek yok
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        }
        recognizeImage(image : chosenImage)
    }
    
    func recognizeImage(image : CIImage){
        //1. request (istek oluşturmak)
        //2. Handle (ele almak)
        
        resultLabel.text = "Finding..."
        
        //MobileNetV2 indirdiğimiz dosyanın aynı adı
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        //handler oluşturmadna bura çalışmaz
                        DispatchQueue.main.async {
                            //%kaç yapabilme işlediğini vericek
                            let confidencelevel = (topResult?.confidence ?? 0) * 100
                            let rounded = Int(confidencelevel * 100) / 100
                            //bilgisini vericek
                            self.resultLabel.text = "\(rounded) % it's \(topResult!.identifier)"
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            //DispatchQueue.global çok daha hızlı birş ekilde sonuç almak istersek kullanılan dispatch dır
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                }catch{
                    print("Erro")
                }
            }
        }
    }
}

