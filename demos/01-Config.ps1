configuration WebServer
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xWebAdministration
    Import-DscResource -ModuleName NetworkingDsc

    node $AllNodes.NodeName
    {
        if ($Node.Role -eq 'WebServer') {
            foreach ($site in $ConfigurationData.WebServer.Sites) {
                $fileResourceName = "[File]$site"
                File $site {
                    SourcePath      = "C:\PShell\Labs\$site"
                    DestinationPath = "C:\$site"
                    Type            = 'Directory'
                    Ensure          = 'Present'
                }

                xWebSite $site {
                    Name         = $Site
                    PhysicalPath = "C:\$Site"
                    DependsOn    = $fileResourceName
                }
            }

            foreach ($windowsFeature in $ConfigurationData.WebServer.WindowsFeatures) {
                WindowsFeature $windowsFeature {
                    Name   = $windowsFeature
                    Ensure = 'Present'
                }
            }
        }
        elseif ($Node.Role -eq 'FileServer') {
            File TestFile1 {
                DestinationPath = 'C:\TestFile1.txt'
                Type            = 'File'
                Ensure          = 'Present'
                Contents        = '123'
            }
        }

        NetIPInterface "DisableDhcp_Ethernet"
        {
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disabled'
        }

        IPAddress "NetworkIp_Ethernet"
        {
            IPAddress      = $Node.IPAddress
            AddressFamily  = 'IPv4'
            InterfaceAlias = 'Ethernet'
        }

        DefaultGatewayAddress DefaultGateway_Ethernet
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = 'Ethernet'
            Address        = $ConfigurationData.Baseline.DefaultGateway
        }
    }
}
