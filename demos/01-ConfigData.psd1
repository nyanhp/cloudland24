@{
    AllNodes  = @(
        @{
            NodeName  = 'MS'
            IPAddress = '192.168.1.2/24'
            Role      = 'WebServer'
        }
        @{
            NodeName  = 'MS1'
            IPAddress = '1.1.1.1/24'
            Role      = 'FileServer'
        }
    )

    WebServer = @{
        Sites           = 'Site1', 'Site2'
        WindowsFeatures = 'Web-Server'
    }

    Baseline  = @{
        DefaultGateway = '192.168.1.10'
    }
}