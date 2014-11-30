//
//  GraphView.h
//  WeatherFrog
//
//  Created by Libor Kučera on 28.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OSXGraphView : NSView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* topSpaceToSuperViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* bottomSpaceToSuperViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* leadingSpaceToSuperViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* trailingSpaceToSuperViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* centerXAlignmentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* centerYAlignmentConstraint;

@end
