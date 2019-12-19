page 6188529 "Map Settings Setup"
{
    PageType = Card;
    SourceTable = "Map Settings";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Provider; Provider)
                {
                    ApplicationArea = All;
                }

                field("Account URL"; "Account URL")
                {
                    ApplicationArea = All;
                }

                field(Username; Username)
                {
                    ApplicationArea = All;
                }

                field(Password; Password)
                {
                    ApplicationArea = All;
                }

                field(Token; Token)
                {
                    ApplicationArea = All;
                }

                field(Profile; Profile)
                {
                    ApplicationArea = All;
                }

                field(Subdomains; Subdomains)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Get() then
            SetDefaultSettings();
    end;
}