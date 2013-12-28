//
//  CPTAxis+CustomLabelVisibility.m
//  WeatherFrog
//
//  Created by Kučera Libor on 21.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPTAxis+CustomLabelVisibility.h"

@implementation CPTAxis (CustomLabelVisibility)

-(void)updateCustomTickLabels
{
	CPTMutablePlotRange *range = [[self.plotSpace plotRangeForCoordinate:self.coordinate] mutableCopy];
    
	if ( range ) {
		CPTPlotRange *theVisibleRange = self.visibleRange;
		if ( theVisibleRange ) {
			[range intersectionPlotRange:theVisibleRange];
		}
        
		if ( range.lengthDouble != 0.0 ) {
			CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
			CPTSign direction				   = self.tickDirection;
            
			for ( CPTAxisLabel *label in self.axisLabels ) {
                
                BOOL visible;
                if ( theVisibleRange ) {
                    visible = [range contains:label.tickLocation];
                } else {
                    visible = YES;
                }
                
                label.contentLayer.hidden = !visible;
				if ( visible ) {
					CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
					[label positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:direction];
				}
			}
            
			for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
                
                BOOL visible;
                if ( theVisibleRange ) {
                    visible = [range contains:label.tickLocation];
                } else {
                    visible = YES;
                }
                
				label.contentLayer.hidden = !visible;
				if ( visible ) {
					CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
					[label positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:direction];
				}
			}
		}
	}
}

@end
