Configuration website
{
    param(

        [Parameter(Mandatory=$true)]
        [string]
        $nodeName,

        [Parameter(Mandatory=$true)]
        [string]
        $sourcePath,

        [Parameter(Mandatory=$true)]
        [string]
        $destinationPath,

        [Parameter(Mandatory=$true)]
        [string]
        $webSiteName

    )

    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration

    Node $nodeName{
        WindowsFeature IIS{
            Ensure = "Present"
            Name = "Web-Server"
        }
        WindowsFeature AspNet45{
            Ensure = "Present"
            Name = "Web-Asp-Net45"
        }
        WindowsFeature WebServerManagementConsole
        {
            Ensure = "Present"
            Name = "Web-Mgmt-Console"
        }
        xWebsite DefaultSite 
        {
            Ensure          = 'Present'
            Name            = 'Default Web Site'
            State           = 'Stopped'
            PhysicalPath    = 'C:\inetpub\wwwroot'
            DependsOn       = '[WindowsFeature]IIS'
        }

        # Copy the website content
        File WebContent
        {
            Ensure          = 'Present'
            SourcePath      = $sourcePath
            DestinationPath = $destinationPath
            Recurse         = $true
            Type            = 'Directory'
            DependsOn       = '[WindowsFeature]AspNet45'
        }       

        # Create the new Website
        xWebsite NewWebsite
        {
            Ensure          = 'Present'
            Name            = $webSiteName
            State           = 'Started'
            PhysicalPath    = $destinationPath
            DependsOn       = '[File]WebContent'
        }
    }
}