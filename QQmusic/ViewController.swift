//
//  ViewController.swift
//  QQmusic
//
//  Created by pengge on 16/6/21.
//  Copyright © 2016年 pengge. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songJindu: UIProgressView!
    @IBOutlet weak var songShijian: UILabel!
    @IBOutlet weak var lryView: UITableView!
    var audioPlayer:AVAudioPlayer!
    var timer:NSTimer?
    var lrcTimeArray:[String] = []
    var lrcDictionary:NSMutableDictionary = NSMutableDictionary()
    var currentLine:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        print(111)
        //加载ACAudioPlayer
        createAVAudioPlayer()
        createLrcView()
        //stopButton.removeFromSuperview()
        //增加playButton 监听点击事件
        playButton.userInteractionEnabled = true
        let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ViewController.imageViewTouch))
        playButton.addGestureRecognizer(singleTap)
        //music()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createAVAudioPlayer()
    {
        let url:NSURL = NSBundle.mainBundle().URLForResource("情非得已", withExtension: "mp3")!
        //let str = "http://m1.music.126.net/7ys3rYhxqMcPqdKGEbb1DA==/1103909674294958.mp3"
        
        let configDefault = NSURLSessionConfiguration.defaultSessionConfiguration()
        configDefault.timeoutIntervalForRequest = 15
        let session1 = NSURLSession(configuration: configDefault)
        let dataTask = session1.dataTaskWithURL(url, completionHandler: {(data,response,error)->Void in
            //print(error)
            do
            {
                //try audioPlayer = AVAudioPlayer.init(contentsOfURL: url!)
                try self.audioPlayer = AVAudioPlayer(data: data!)
            }catch
            {
                print(error)
            }
        })
        dataTask.resume()
    }
    //获取歌词
    func createLrcView()
    {
        let lrc_url:NSURL = NSBundle.mainBundle().URLForResource("情非得已", withExtension: "lrc")!
        let lrc_text = try? String(contentsOfURL: lrc_url, encoding: NSUTF8StringEncoding)
        let lrcTextArr = lrc_text!.componentsSeparatedByString("\n")
        var timeStr:String = ""
        var lrcStr:String = ""
        for item in lrcTextArr
        {
            if(item.characters.count > 7)
            {
                let str1:String = (item as NSString).substringWithRange(NSMakeRange(3, 1))
                let str2:String = (item as NSString).substringWithRange(NSMakeRange(6, 1))
                if(str1 == ":" && str2 == ".")
                {
                    timeStr = (item as NSString).substringWithRange(NSMakeRange(1, 5))
                    lrcStr = (item as NSString).substringFromIndex(10)
                }
                lrcTimeArray.append(timeStr)
                lrcDictionary.setValue(lrcStr, forKey: timeStr)
            }
        }
        
        
        
        //print(lrcArray)
        //print(lrcTextArr)
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return lrcTimeArray.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "lrcCell")
        cell.backgroundColor = UIColor.clearColor()
        //let rowData:NSDictionary = lrcArray[indexPath.row] as! NSDictionary
        let lrcKey:String = lrcTimeArray[indexPath.row]
        cell.textLabel?.text = lrcDictionary[lrcKey]! as? String
        cell.textLabel!.backgroundColor = UIColor.clearColor();
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
        //改变 textLabel 的样式;
        if (indexPath.row  == currentLine)
        {
            cell.textLabel!.font = UIFont.systemFontOfSize(15)
            cell.textLabel!.textColor = UIColor.blueColor();
            
            //cell.textLabel!.backgroundColor = UIColor.clearColor();
        } else
        {
            cell.textLabel!.font = UIFont.systemFontOfSize(15);
            cell.textLabel!.textColor = UIColor.blackColor();
        }
        //cell.detailTextLabel?.text =
        //print(cell.textLabel?.text)
        return cell
    }
    
    /*
    
    //改变 textLabel 的样式;
    if (indexPath.row  == self.line) {
    
    cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    cell.textLabel.textColor = [UIColor blueColor];
    } else {
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
 */
    
    

    func imageViewTouch()
    {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.onUpdate), userInfo: nil, repeats: true)
        if(!audioPlayer.playing)
        {
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
            audioPlayer.volume = 1.0
            audioPlayer.numberOfLoops = -1
            //audioPlayer.prepareToPlay()
            audioPlayer.play()
        }else
        {
            playButton.setImage(UIImage(named: "play"), forState: .Normal)
            audioPlayer.pause()
        }
    }
    func onUpdate()
    {
        let currentTime = audioPlayer.currentTime
        //self.currentTImeLabel.text = currentString;
   
        
        if(currentTime>0.0)
        {
            let allTime = audioPlayer.duration
            let persentNum = CFloat(currentTime/allTime)
            songJindu.setProgress(persentNum, animated: true)
        }
        //一个小算法，来实现00：00这种格式的播放时间
        let current:Int=Int(currentTime)
        let all:Int = Int(audioPlayer.duration)
        let all_m:Int = all%60
        let all_f:Int = all/60
        var all_time:String=""
        if all_f<10{
            all_time="0\(all_f):"
        }else {
            all_time="\(all_f)/"
        }
        if all_m<10{
            all_time+="0\(all_m)"
        }else {
            all_time+="\(all_m)"
        }
        let current_m:Int=current % 60
        let current_f:Int=Int(current/60)
        var current_time:String=""
        if current_f<10{
            current_time="0\(current_f):"
        }else {
            current_time="\(current_f)"
        }
        if current_m<10{
            current_time+="0\(current_m)"
        }else {
            current_time+="\(current_m)"
        }
        //print(current_time)
        //判断数组是否包含某个元素;
        if(lrcTimeArray.contains(String(current_time)))
        {
            currentLine = lrcTimeArray.indexOf(String(current_time))!
            //print(currentLine)
            //lryView.reloadData()
            //let indexPath:NSIndexPath = NSIndexPath.indexAtPosition(currentLine)
            //lryView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            lryView.reloadRowsAtIndexPaths(lryView.indexPathsForVisibleRows!, withRowAnimation: UITableViewRowAnimation.Fade)
            let indexPath = NSIndexPath(forRow: currentLine, inSection: 0)
            //拿到角标滚动到哪个位置
            //lryView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
            lryView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        }
        //更新播放时间
        songShijian!.text="\(current_time)/\(all_time)"
    }

}

