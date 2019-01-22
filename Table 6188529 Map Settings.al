table 6188529 "Map Settings"
{

    fields
    {
        field(1; "Primary Key"; Code[1]) { }
        field(10; Provider; Option) { OptionMembers = PTV, "Open Streetmaps"; }
        field(20; "Account URL"; Text[250]) { } //providerSettings.Add('baseUrl', 'https://s0{s}-xserver2-europe-test.cloud.ptvgroup.com/services/rest/XMap/tile/{z}/{x}/{y}?storedProfile={profile}&xtok={token}');   // REQUIRED. Map provider URL
        field(21; "Username"; Text[250]) { } //providerSettings.Add('username', 'D3B61519-68F6-4177-B613-01BB1F707496');            // OPTIONAL. Username for the map.
        field(22; Password; Text[30]) { ExtendedDatatype = Masked; } //providerSettings.Add('password', 'GS04m!5M.K');                                      // OPTIONAL. Password for the map.
        field(23; Token; Text[36]) { ExtendedDatatype = Masked; } //providerSettings.Add('token', '5D1D3D5C-50D0-415B-98EE-8FF4D61FB255');               // OPTIONAL. Token for the map.

        // Need to add more fields for settings
        field(24; "Profile"; Text[32]) { }         // Profile for the map. PTV specific.

        field(25; Subdomains; Text[32]) { }         // Comma separated subdomains.
    }

    keys { key(PK; "Primary Key") { Clustered = true; } }
}