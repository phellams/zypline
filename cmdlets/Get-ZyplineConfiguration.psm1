using module ..\libs\core-functions.psm1

<#
.SYNOPSIS
    Retrieves the zypline module's configuration.
.DESCRIPTION
    This function loads the configuration from 'config.json'. If the file
    does not exist, it creates a default configuration and saves it.
    The default configuration includes common search paths.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.EXAMPLE
    $Config = Get-ZyplineConfiguration
    $Config.SearchPaths
.NOTES
    The default search paths are retrieved from the module manifest's PrivateData.
#>
function Get-ZyplineConfiguration {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [alias("zypconfig")]
    param()

    # global hashtable functions
    $kvinc = $global:__zypline.kvinc
    $logname = $global:__zypline.utility.logName
    $sublog = $global:__zypline.utility.sublog

    $ConfigFile = Get-ZyplineConfigPath

    if (Test-Path -Path $ConfigFile -PathType Leaf) {
        try {
            $Config = Get-Content -Path $ConfigFile | ConvertFrom-Json
            [Console]::Write("$logname 📝 $(csole -s "Configuration loaded from: $($kvinc.invoke('path',$ConfigFile))" -c Green)`n")
        }
        catch {
            [Console]::Write("$logname ❌ $(csole -s "Error loading configuration from '$($kvinc.invoke('path',$ConfigFile))'. Creating default config." -c Red)`n")
            $Config = [PSCustomObject]@{
                SearchPaths = $global:__zypline.DefaultSearchPaths
            }
            Set-ZyplineConfiguration -Configuration $Config
        }
    }
    else {
        [Console]::Write("$logname ✨ $(csole -s "No configuration file found. Creating default configuration." -c Yellow)`n")
        $Config = [PSCustomObject]@{
            SearchPaths = $global:__zypline.DefaultSearchPaths
        }
        Set-ZyplineConfiguration -Configuration $Config
    }

    return $Config
}

$cmdlet_config = @{
    function = @('Get-ZyplineConfiguration')
    alias    = @('zypconfig')
}

Export-ModuleMember @cmdlet_config