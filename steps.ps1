# JHP prep
Remove-Item -Path ./DscWorkshop -Recurse -Force -ErrorAction SilentlyContinue
$progressPreference = 'SilentlyContinue'

# Start here and fork the repo. Alternatively, Clone and change the remote to
# your own repo.
git clone https://github.com/dsccommunity/dscworkshop
Set-Location -Path ./dscworkshop
git remote set-url origin git@ssh.dev.azure.com:v3/nyanhp/dsc/dsc
git push --all origin --force

<#
Let's start with a build while we explore
- The build process with build.yml
- The build task model
- The portable nature of it all
- The depedency system
- The output folder
#>
./build.ps1 -ResolveDependency

# That's all nice, but we have more than three nodes. How can we add more?
Copy-Item ./source/AllNodes/Dev/DscFile01.yml ./source/AllNodes/Dev/DscFile04.yml

# But is it that easy? Let's see what happens when we build
./build.ps1 -Tasks build

# Some node-specific data is indeed unique - like the node's IP address
code ./source/AllNodes/Dev/DscFile04.yml
./build.ps1 -Tasks build

# Nice. But the node should be in a new location. How do we do that?
Copy-Item ./source/Locations/Singapore.yml ./source/Locations/Phantasialand.yml # Yeah, this time that is allright

# Time to update the node - this time: PowerShell style
$nodeData = Get-Content -Raw -path ./source/AllNodes/Dev/DscFile04.yml | ConvertFrom-Yaml -Ordered
$nodeData.Location = 'Phantasialand'
$nodeData | ConvertTo-Yaml -OutFile (Join-Path $pwd.Path source/AllNodes/Dev/DscFile04.yml) -Force
.\build.ps1 -Tasks build

# Let's examine the creation of a new role as well
# Programatically, this can be a hashtable - ordered casts it to an ordered dictionary
[ordered]@{
    Configurations   = 'WindowsFeatures', 'ComputerSettings' # Hold on, where do those actually come from?
    WindowsFeatures  = @{
        Names = '+FS-DFS-Replication', '+FS-DFS-Namespaces', '-SMB1Protocol'
    }
    ComputerSettings = @{
        JoinOU = 'OU=LegacyStuff,OU=Servers,DC=contoso,DC=com'
    }
} | ConvertTo-Yaml -OutFile (Join-Path $pwd.Path source/Roles/DfsNode.yml) -Force

# Update the node role
$nodeData = Get-Content -Raw -path ./source/AllNodes/Dev/DscFile04.yml | ConvertFrom-Yaml -Ordered
$nodeData.Role = 'DfsNode'
$nodeData | ConvertTo-Yaml -OutFile (Join-Path $pwd.Path source/AllNodes/Dev/DscFile04.yml) -Force
.\build.ps1 -Tasks build

# The source for your configuration blocks (full, production-ready module: https://github.com/dsccommunity/commontasks)
Get-DscResource -Module DscConfig.Demo | Select-Object -ExpandProperty Name

# What can we use?
Get-DscResource -Name ComputerSettings -Module DscConfig.Demo -Syntax

# Time to rebuild!
./build.ps1 -Tasks build

# To finish off: The Pipeline!
# JHP hops to the Azure Portal and talks about service connections
# Let's reuse the sample pipeline
Remove-Item -Path ./azure-pipelines.yml
Rename-Item -Path './azure-pipelines Guest Configuration.yml' -NewName azure-pipelines.yml
