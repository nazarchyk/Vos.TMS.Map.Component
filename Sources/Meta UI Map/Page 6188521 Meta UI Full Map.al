page 6188521 "Meta UI Full Map"
{
    Caption = 'Meta UI Full Map';
    PageType = Card;

    layout
    {
        area(Content)
        {
            usercontrol(MapControl; MetaUIMapAddIn)
            {
                ApplicationArea = All;

            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }
}