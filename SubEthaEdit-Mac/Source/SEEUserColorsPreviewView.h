//  SEEUserColorsPreviewView.h
//  SubEthaEdit
//
//  Created by Lisa Brodner on 16/04/14.

#import <Cocoa/Cocoa.h>

@interface SEEUserColorsPreviewView : NSView

@property (nonatomic, strong) NSNumber *userColorHue;
@property (nonatomic, strong) NSNumber *changesSaturation;
@property (nonatomic, strong) NSNumber *selectionSaturation;

@property (nonatomic) BOOL showsChangesHighlight;

- (void)updateViewWithUserDefaultsValues;
- (void)updateView;
@end
