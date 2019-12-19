table 6188529 "Map Settings"
{
    Caption = 'Map Settings Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }

        field(10; Provider; Option) // New Name: Map Provider ???
        {
            Caption = '';
            DataClassification = ToBeClassified;
            OptionMembers = PTV,"Open Streetmaps";
        }

        field(20; "Account URL"; Text[250]) // New Name: Map Base URL ???
        {
            Caption = '';
            DataClassification = ToBeClassified;
        }

        field(21; "Username"; Text[250])
        {
            Caption = 'Username';
            DataClassification = ToBeClassified;
        }

        field(22; Password; Text[30])
        {
            Caption = 'Password';
            DataClassification = ToBeClassified;
            ExtendedDatatype = Masked;
        }

        field(23; Token; Text[36]) // Description ???
        {
            Caption = '';
            DataClassification = ToBeClassified;
            ExtendedDatatype = Masked;

            //providerSettings.Add('token', '5D1D3D5C-50D0-415B-98EE-8FF4D61FB255');
            // OPTIONAL. Token for the map.
        }

        field(24; "Profile"; Text[32]) // Description ???
        {
            Caption = '';
            DataClassification = ToBeClassified;

            // Profile for the map. PTV specific.
        }

        field(25; Subdomains; Text[32]) // Description ???
        {
            Caption = '';
            DataClassification = ToBeClassified;

            // Comma separated subdomains.
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure SetDefaultSettings()
    begin
        Provider := Provider::PTV;
        "Account URL" := 'https://s0{s}-xserver2-europe.cloud.ptvgroup.com/services/rest/XMap/tile/{z}/{x}/{y}?storedProfile={profile}&xtok={token}';
        Username := 'D3B61519-68F6-4177-B613-01BB1F707496';
        Password := 'GS04m!5M.K';
        Token := '5D1D3D5C-50D0-415B-98EE-8FF4D61FB255';
        Profile := 'sandbox';
        Subdomains := '1,2,3,4';
        Insert();
    end;

    procedure SettingsToJSON() Settings: JsonObject
    begin
        if not Get() then
            SetDefaultSettings();

        Settings.Add('type', Provider);
        Settings.Add('baseUrl', "Account URL");

        if Username <> '' then
            Settings.Add('username', Username);

        if Password <> '' then
            Settings.Add('password', Password);

        if Token <> '' then
            Settings.Add('token', Token);

        if "Profile" <> '' then
            Settings.Add('profile', "Profile");

        if Subdomains <> '' then
            Settings.Add('subdomains', Subdomains);

        Settings.Add('providerSettings', Settings);

        /*** EXAMPLE OF PROVIDER SETTINGS FOR OPENSTREETMAPS ***/
        // Settings.Add('type', 1);
        // Settings.Add('baseUrl', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png');
    end;

}