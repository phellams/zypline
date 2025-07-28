using module ..\libs\core-functions.psm1
<#
.SYNOPSIS
    Saves the zypline module's configuration to a JSON file.
.DESCRIPTION
    This function takes a configuration object and serializes it to JSON,
    saving it to the 'config.json' file in the user's Documents\zypline directory.
.PARAMETER Configuration
    The configuration object to save. This should be a PSCustomObject or a Hashtable.
.EXAMPLE
    $NewConfig = @{ SearchPaths = @("C:\Projects", "D:\Data") }
    Set-ZyplineConfiguration -Configuration $NewConfig
.NOTES
    This function will overwrite the existing config.json file.
#>
function Set-ZyplineConfiguration {
    [CmdletBinding()]
    [alias("zypset")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$Configuration
    )
    # global hashtable functions
    $kvinc = $global:__zypline.kvinc
    $logname = $global:__zypline.utility.logName
    $sublog = $global:__zypline.utility.sublog

    $ConfigFile = Get-ZyplineConfigPath

    try {
        $Configuration | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigFile -Force
        [Console]::Write("$logname 💾 $(csole -s "Configuration saved to: $($kvinc.invoke('path',$ConfigFile))" -c Green)`n")
    }
    catch {
        [Console]::Write("$logname ❌ $(csole -s "Error saving configuration to '$($kvinc.invoke('path',$ConfigFile))': $($_.Exception.Message)" -c Red)`n")
    }
}

$cmdlet_config = @{
    function = @('Set-ZyplineConfiguration')
    alias    = @('zypset')
}

Export-ModuleMember @cmdlet_config