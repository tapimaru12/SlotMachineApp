class SlotMachine {
    // 投入金額
    var inputedMoney = 0
    
    // ストップボタンが押せるかどうか
    // setMoneyからシンプルなフラグに変更
    var tappableStopButton = false
    
    // 絵柄
    let reelMark: [String] = ["🔔", "🔔", "🌺", "🌺", "🍎", "🍎", "👾", "👾", "🍬", "🍬", "🎱", "🎱", "🎁", "🎁", "🦄", "💎", "💰"]
    
    // 各リールのデフォルト状態
    let defaultReel: [String] = ["", "", ""]
    
    // 各リールのデフォルト状態
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
            print("投入上限金額は1000円までとなっております。")
            
        } else if inputedMoney < 100 {
            // 一度の投入金額が100円未満だった場合
            print("無効な硬貨：\(inputedMoney)円")
            
        } else {
            // 投入された金額が100円以上1000円未満だった場合
            // 投入可能な硬貨かどうかを識別する
            var change = inputedMoney % 100 // changeは99円以下
            self.inputedMoney = inputedMoney - change
            
            // お釣りを出す
            if self.inputedMoney > 1000 {
                // 既に投入された金額と追加で投入した金額が合わせて1000円を超えてしまった場合
                change += self.inputedMoney - 1000
                self.inputedMoney = 1000
                print("投入上限金額の1000円を超えたため返金します：\(change)円")
                
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
        if inputedMoney >= 100, leftReel == defaultReel && centerReel == defaultReel && rightReel == defaultReel {
            inputedMoney -= 100
            leftReel = playable
            centerReel = playable
            rightReel = playable
            tappableStopButton = true
        }
    }
    
    
    // ストップボタン
    func tappedStopButton(target: String) {
        // 当メソッドの引数にinoutを適用すると、メソッド呼び出し時に各リールを引数に取れなかった(スコープ外)ため、ワンクッション入れる
        var targetReel = defaultReel
        
        // 下のif文で、押されたボタンのリールがプレイ可能状態かどうかを判別するため、switch文で引数を用いて判別対象を決めている
        switch target {
        case "left": targetReel = leftReel
        case "center": targetReel = centerReel
        case "right": targetReel = rightReel
        default: targetReel = leftReel
        }
        
        if tappableStopButton, targetReel == playable {
            // 絵柄を確定する
            // 変数targetReelを用意しワンクッション入れたため、getResultReelメソッドを呼び出した際に代入先となる変数が各リールではなく、targetReelになってしまっている。
            // そのため再度引数のtargetを用いてswitch文で代入先を判別し、メソッドを呼び出している。
            switch target {
            case "left": leftReel = getResultReel(reel: &targetReel)
            case "center": centerReel = getResultReel(reel: &targetReel)
            case "right": rightReel = getResultReel(reel: &targetReel)
            default: leftReel = getResultReel(reel: &targetReel)
            }
            // 全リールの絵柄を表示する
            result()
            // 絵柄が出揃ったら最終結果を表示する
            if leftReel != defaultReel && centerReel != defaultReel && rightReel != defaultReel,
               leftReel != playable && centerReel != playable && rightReel != playable {
                score()
            }
        }
    }
    
    
    // リセットボタンを押した時の処理(全ての絵柄が出揃っている時のみ有効)
    func tappedResetButton() {
        if leftReel != defaultReel && centerReel != defaultReel && rightReel != defaultReel,
           leftReel != playable && centerReel != playable && rightReel != playable {
            if inputedMoney >= 100 {
                // 投入金額が100円以上の場合は再プレイ
                inputedMoney -= 100
                leftReel = playable
                centerReel = playable
                rightReel = playable
            } else {
                // 投入金額が0円の場合はリールを初期値の戻す
                leftReel = defaultReel
                centerReel = defaultReel
                rightReel = defaultReel
                tappableStopButton = false
            }
            
            print("- Reset -")
        }
    }
    
    
    // 返金ボタンを押した時の処理(全ての絵柄が)
    func tappedRefundButton() {
        if inputedMoney != 0, leftReel != defaultReel && centerReel != defaultReel && rightReel != defaultReel,
           leftReel == playable && centerReel == playable && rightReel == playable {
            print("返金額：\(inputedMoney)")
            inputedMoney = 0
        }
    }
}


// ストップボタンを押した時の処理
extension SlotMachine {
    func getResultReel(reel: inout [String]) -> [String] {
        // 一度選ばれた要素のインデックス番号を保管(同じ要素が出力されないよう比較する)
        var stock: [Int] = []
        // リールの代入先(インデックス)
        var i = 0
        
        // リールの絵柄に❔がなくなるまでループする(リールの絵柄が全て確定するまで)
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
    
    
    // 全リールの絵柄を表示する
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
        
        // ビンゴとリーチの値をリセット
        bingo = 0
        reach = 0
        
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
slotMachine.startPlaying(inputedMoney: 200)
slotMachine.tappedStartButton()


// 左→中→右
slotMachine.tappedStopButton(target: "left")
slotMachine.tappedStopButton(target: "center")
slotMachine.tappedStopButton(target: "right")

slotMachine.tappedResetButton()


// 右→中→左
slotMachine.tappedStopButton(target: "right")
slotMachine.tappedStopButton(target: "center")
slotMachine.tappedStopButton(target: "left")

