page 6188529 "Map Settings"
{
    PageType = Card;
    SourceTable = "Map Settings";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Provider; Provider) { }
                field("Account URL"; "Account URL") { }
                field(Username; Username) { }
                field(Password; Password) { }
                field(Token; Token) { }
                field(Profile;Profile) {}
                field(Subdomains;Subdomains) {}
            }
        }
    }


    trigger OnOpenPage();
    begin
        if not get then
            Insert;
    end;

}