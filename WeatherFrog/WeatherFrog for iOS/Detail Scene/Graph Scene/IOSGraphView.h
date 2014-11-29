//
//  IOSGraphView.h
//  WeatherFrog
//
//  Created by Libor Kučera on 29.11.14.
//  Copyright (c) 2014 IC Servis, s.r.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IOSGraphView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* topSpaceToSuperViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* bottomSpaceToSuperViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* leadingSpaceToSuperViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* trailingSpaceToSuperViewConstraint;

@end
