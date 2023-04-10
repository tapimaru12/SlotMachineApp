class SlotMachine {
    // 投入金額
    var inputedMoney = 0
    // 投入金額の保管
    var setMoney = 0
    
    // 各レーンの絵柄
    var reelMark: [String] = ["🔔", "🔔", "🌺", "🌺", "🍎", "🍎", "👾", "👾", "🍬", "🍬", "🎱", "🎱", "🎁", "🎁", "🦄", "💎", "💰"]
    
    // リールのデフォルト状態
    var leftReel: [String] = ["", "", ""]
    var centerReel: [String] = ["", "", ""]
    var rightReel: [String] = ["", "", ""]
    
    // プレイ可能状態のリール
    let playable: [String] = ["❔", "❔", "❔"]
    
    // ビンゴの総数
    var bingo = 0
    // リーチの総数
    var reach = 0
    
    
    // お金を入れる
    func startPlaying(inputedMoney: Int) {
        if inputedMoney > 1000 {
            // 一度の投入金額が1000円を超えていた場合
            print("投入金額は一度に1000円までとなっております。")
            
        } else if inputedMoney < 100 {
            // 一度の投入金額が100円未満だった場合
            print("無効な硬貨：\(inputedMoney)円")
            
        } else if self.inputedMoney < 1000 {
            // 既に投入された金額が1000円未満かつ、上記2つも網羅した場合
            // 受け入れ可能な硬貨とお釣りを識別する
            var num = Double(inputedMoney) * 0.01
            var change: Int = inputedMoney % 100
            self.inputedMoney += Int(num.rounded(.down) * 100)
            self.setMoney = self.inputedMoney
            
            // お釣りを出す
            if self.inputedMoney > 1000 {
                // 既に投入された金額と今投入した金額が合わせて1000円以上になってしまった場合
                change += self.inputedMoney - 1000
                self.inputedMoney = 1000
                print("無効な硬貨：\(change)円")
            } else if change != 0 {
                // シンプルにお釣りがあった場合
                print("無効な硬貨：\(change)円")
            }
            
            // 投入金額の表示
            print("投入金額：\(self.inputedMoney)円")
        }
    }
    
    
    // プレイ可能状態にする(リール回転スタート)
    func tappedStartButton() {
        if inputedMoney >= 100, leftReel == ["", "", ""] && centerReel == ["", "", ""] && rightReel == ["", "", ""] {
            setMoney = inputedMoney
            inputedMoney -= 100
            leftReel = playable
            centerReel = playable
            rightReel = playable
        }
    }
    
    
    // 左のストップボタン(左レーンの絵柄が確定していない時のみ有効)
    func tappedLeftStopButton() {
        if setMoney >= 100, leftReel == playable {
            // 絵柄を確定する
            leftReel = tappedStopButton(reel: &leftReel)
            // 全レーンの絵柄を表示する
            result()
            // 絵柄が出揃ったら最終結果を表示する
            if leftReel != ["", "", ""] && centerReel != ["", "", ""] && rightReel != ["", "", ""],
               leftReel != playable && centerReel != playable && rightReel != playable {
                score()
            }
        }
    }
    
    // 中央のストップボタン(中央レーンの絵柄が確定していない時のみ有効)
    func tappedCenterStopButton() {
        if setMoney >= 100, centerReel == playable {
            // 絵柄を確定する
            centerReel = tappedStopButton(reel: &centerReel)
            // 全レーンの絵柄を表示する
            result()
            // 絵柄が出揃ったら最終結果を表示する
            if leftReel != ["", "", ""] && centerReel != ["", "", ""] && rightReel != ["", "", ""],
               leftReel != playable && centerReel != playable && rightReel != playable {
                score()
            }
        }
    }
    
    // 右のストップボタン(右レーンの絵柄が確定していない時のみ有効)
    func tappedRightStopButton() {
        if setMoney >= 100, rightReel == playable {
            // 絵柄を確定する
            rightReel = tappedStopButton(reel: &rightReel)
            // 全レーンの絵柄を表示する
            result()
            // 絵柄が出揃ったら最終結果を表示する
            if leftReel != ["", "", ""] && centerReel != ["", "", ""] && rightReel != ["", "", ""],
               leftReel != playable && centerReel != playable && rightReel != playable {
                score()
            }
        }
    }
    
    
    // リセットボタンを押した時の処理(全ての絵柄が出揃っている時のみ有効)
    func tappedResetButton() {
        if leftReel != ["", "", ""] && centerReel != ["", "", ""] && rightReel != ["", "", ""],
           leftReel != playable && centerReel != playable && rightReel != playable {
            if inputedMoney >= 100 {
                setMoney = inputedMoney
                inputedMoney -= 100
                leftReel = playable
                centerReel = playable
                rightReel = playable
            } else {
                leftReel = ["", "", ""]
                centerReel = ["", "", ""]
                rightReel = ["", "", ""]
            }
            
            print("- Reset -")
        }
    }
    
    
    // 返金ボタンを押した時の処理(全ての絵柄が)
    func tappedRefundButton() {
        if inputedMoney >= 100 && leftReel == playable && centerReel == playable && rightReel == playable {
            print("返金額：\(inputedMoney)")
            inputedMoney = 0
        }
    }
    
}


// スロットボタン押下時の処理
extension SlotMachine {
    // ストップボタンを押した時の処理
    func tappedStopButton(reel: inout [String]) -> [String] {
        var reel = reel
        // 一度選ばれた要素のインデックス番号を保管(同じ要素が出力されないよう比較する)
        var stock: [Int] = []
        // レーンの代入先(インデックス)
        var i = 0
        
        // レーンの絵柄に❔がなくなるまでループする(レーンの絵柄が全て確定するまで)
        while reel.contains("❔") {
            // 一つの絵柄(インデックス)を取得
            let num = Int.random(in: 0...reelMark.count - 1)
            
            // 既に取得済みの要素であればループをやり直す else 新しい要素であれば絵柄を確定させる
            if stock.contains(num) {
                continue
            } else {
                // 絵柄を確定する
                reel[i] = reelMark[num]
                // インデックス保管
                stock.append(num)
                // 次の絵柄取得に移行
                i += 1
            }
        }
        return reel
    }
    
    // 全レーンの絵柄を表示する
    func result() {
        print("ーーーーーーーー")
        print("\(leftReel[0])   \(centerReel[0])   \(rightReel[0])")
        print("\(leftReel[1])   \(centerReel[1])   \(rightReel[1])")
        print("\(leftReel[2])   \(centerReel[2])   \(rightReel[2])")
        print("ーーーーーーーー")
    }
    
    // 各ラインのビンゴ&リーチ判定(全ての絵柄が出揃っている時のみ有効)
    func score() {
        // 上段(0)、中段(1)、下段(2)
        for i in 0...2 {
            if leftReel[i] == centerReel[i] || leftReel[i] == rightReel[i] || centerReel[i] == rightReel[i] {
                if leftReel[i] == centerReel[i] && centerReel[i] == rightReel[i] {
                    bingo += 1
                } else {
                    reach += 1
                }
            }
        }
        
        // 斜め＼
        if leftReel[0] == centerReel[1] || leftReel[0] == rightReel[2] || centerReel[1] == rightReel[2] {
            if leftReel[0] == centerReel[1] && centerReel[1] == rightReel[2] {
                bingo += 1
            } else {
                reach += 1
            }
        }
        
        // 斜め／
        if leftReel[2] == centerReel[1] || leftReel[2] == rightReel[0] || centerReel[1] == rightReel[0] {
            if leftReel[2] == centerReel[1] && centerReel[1] == rightReel[0] {
                bingo += 1
            } else {
                reach += 1
            }
        }
        
        // ビンゴの数が1以上の場合にビンゴ数を出力
        if bingo > 0 { print("\(bingo)BINGO！！") }
        
        // リーチの数が1以上の場合にリーチ数を出力
        if reach > 0 { print("\(reach)REACH！") }
        
        // ビンゴもリーチもない場合
        if bingo == 0 && reach == 0 { print("残念！") }
        
        bingo = 0
        reach = 0
        
        setMoney = inputedMoney
        
        print("残金：\(inputedMoney)円")
        
        if inputedMoney == 0 {
            print("プレイ終了！")
            tappedResetButton()
        } else {
            print("あと\(inputedMoney / 100)回プレイ可能")
        }
    }
}





let slotMachine = SlotMachine()

// 金額投入
slotMachine.startPlaying(inputedMoney: 300)
slotMachine.tappedStartButton()

// 左→中→右
slotMachine.tappedLeftStopButton()
slotMachine.tappedCenterStopButton()
slotMachine.tappedRightStopButton()

slotMachine.tappedResetButton()

// 右→中→左
slotMachine.tappedRightStopButton()
slotMachine.tappedCenterStopButton()
slotMachine.tappedLeftStopButton()

slotMachine.tappedResetButton()

// 中→左→右
slotMachine.tappedCenterStopButton()
slotMachine.tappedLeftStopButton()
slotMachine.tappedRightStopButton()

slotMachine.tappedResetButton()

// 中→右→左
slotMachine.tappedCenterStopButton()
slotMachine.tappedRightStopButton()
slotMachine.tappedLeftStopButton()

slotMachine.tappedResetButton()

