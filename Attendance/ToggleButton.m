//
//  ToggleButton.m
//  Attendance
//
//  Created by heppokoact on 2013/05/18.
//
//

#import "ToggleButton.h"

/**
 * SegmentedControlでは複数の選択肢を同時に選択できないようなので、ボタンを利用して擬似的に実現するためのクラス。
 * 一度押下するとそのまま押下状態になり、そこでもう一度押下すると押下状態が解除される。
 */
@implementation ToggleButton

/**
 * StoryBoardからインスタンス化されるときに呼び出されるイニシャライザ。
 * オーバーライドしてボタンの見た目などの初期化処理を追加している。
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    ENTER_METHOD
    
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    
    LEAVE_METHOD
    
    return self;
}

/**
 * ボタンがタッチされた時に呼ばれるメソッド。
 * オーバーライドして選択/非選択の状態を保持するようにしてある。
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    ENTER_METHOD
    
    [super touchesBegan:touches withEvent:event];
    self.selected = !self.selected;
    
    ENTER_METHOD
}

@end
