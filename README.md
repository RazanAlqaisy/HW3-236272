Dry questions

1. Widgets usually expose controllers to allow the developer granular control
   over certain features. You’ve already used one when you implemented
   TextFields in the previous assignment (Remember?).
   Read this thread and then go to snapping_sheet’s documentation.
   Answer: What class is used to implement the controller pattern in this library?
   What features does it allow the developer to control?

Answer:
    snappingSheetController class, 
    used to control the position of the snapping sheet.

2. The library allows the bottom sheet to snap into position with various different
   animations. What parameter controls this behavior?

Answer:
    snappingCurve, snappingDuration parameters.
    
    
3. [This question does not directly relate to the previous ones] Read the
   documentation of InkWell and GestureDetector. Name one advantage of
   InkWell over the latter and one advantage of GestureDetector over the first.

Answer:
    Inkwell provides a ripple effect tap which GestureDetector doesn't have.
    GestureDetector does not require a Material Widget as an ancestor while Inkwell does.