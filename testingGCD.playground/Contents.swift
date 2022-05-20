import UIKit
import PlaygroundSupport

/*Все действия по дефолту выполняются в main потоке, поэтому сначала загружается firstViewController, 
выставляются все его настройки вроде title, background color и по нажатию на кнопку он переходит во вторую SecondViewController
и ждет пока загрузится фотография и только потом происходит сам переходит, но если там будет огромное видео или много фотографий 
и если интернет будет слабым, то будет казаться что приложение сломано, так как после нажатия на кнопку не будут происходит никакие действия. 
Для исправления этого мы создали глобальную очередь с высоким приоритетом и в ней получили данные асинхронно, а затем все это вернули в главную очередь. 
Теперь по нажатию на кнопку мы проваливаемся во второй SecondViewController  и только потом прогружаются данные в виде фотографий в данном случае  */

class FirstViewController: UIViewController {
    
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "vc 1"
        self.view.backgroundColor = .white
        
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        paintingButtonOnView()
    }
    
    @objc func buttonPressed() {
        let vc2 = SecondViewController()
        self.navigationController?.pushViewController(vc2, animated: true)
    }
    
    func paintingButtonOnView() {
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = self.view.center
        button.backgroundColor = .cyan
        button.setTitle("Press me", for: .normal)
        button.titleColor(for: .normal)
        self.view.addSubview(button)
    }
}
class SecondViewController: UIViewController {
    
    let image = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "vc 2"
        self.view.backgroundColor = .white
        
        loadPhotoAsync()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializingImageViewOnDisplay()
    }
    
    //Для размещения UIImageView с определенным размером по центру экрана
    func initializingImageViewOnDisplay() {
        image.frame = CGRect(x: 0, y: 0, width: 400, height: 300)
        image.center = self.view.center
        self.view.addSubview(image)
    }
    
    func loadPhotoAsync() {
        let urlToTakePhoto = "https://picsum.photos/300/400"
        let imageURL : URL = URL(string: urlToTakePhoto)!
        //Создаем очередь и задаем ей приоритет .utility один из высоких приоритетов, чтобы действия выполнялилсь здесь и сейчас, а не в фоне или еще где-то
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            if let data = try? Data(contentsOf: imageURL){
                //так как data получается в глобальной очереди, а для отображения image нам нужно находится в main потоке, поэтому возвращаем ее в main
                DispatchQueue.main.async {
                    self.image.image = UIImage(data: data)
                }
                
            }
        }
    }
}
//Создаем экземпляр класса FirstViewController чтобы его передать в navigation bar
let vc = FirstViewController()

let navbar = UINavigationController(rootViewController: vc)
//Задаем определенный размер, так как расширялся на весь экран и кнопки для нагигейшн бара были не доступны
navbar.view.frame = CGRect(x: 0, y: 0, width: 300, height: 600)
PlaygroundPage.current.liveView = navbar
PlaygroundPage.current.needsIndefiniteExecution = true




