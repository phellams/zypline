using module ..\libs\core-functions.psm1
<#
.SYNOPSIS
    Adds one or more paths to the zypline search configuration.
.DESCRIPTION
    This function retrieves the current zypline configuration, adds the specified
    paths to the 'SearchPaths' array, and then saves the updated configuration.
    It ensures that only unique, existing paths are added.
.PARAMETER Path
    One or more paths to add to the search configuration.
.EXAMPLE
    Add-ZyplineSearchPath -Path "C:\NewFolder"
.EXAMPLE
    Add-ZyplineSearchPath -Path "C:\Folder1", "D:\Folder2"
#>
function Add-ZyplineSearchPath {
    [CmdletBinding()]
    [alias("zypadd")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Path
    )

    # global hashtable functions
    $kvinc = $global:__zypline.kvinc
    $logname = $global:__zypline.utility.logName
    $sublog = $global:__zypline.utility.sublog

    $Config = Get-ZyplineConfiguration
    $CurrentPaths = [System.Collections.Generic.List[string]]$Config.SearchPaths

    foreach ($p in $Path) {
        if (Test-Path -Path $p) {
            if (-not ($CurrentPaths -contains $p)) {
                $CurrentPaths.Add($p)
                [Console]::Write("$logname ✅ $(csole -s "Added search path: '$($kvinc.invoke('Path',$p))'" -c Green)`n")
            }
            else {
                [Console]::Write("$logname ℹ️ $(csole -s "Path already exists in configuration: '$($kvinc.invoke('Path',$p))'" -c Yellow)`n")
            }
        }
        else {
            [Console]::Write("$logname ❌ $(csole -s "Path does not exist or is invalid: '$($kvinc.invoke('Path',$p))'" -c Red)`n")
        }
    }

    $Config.SearchPaths = $CurrentPaths | Sort-Object -Unique
    Set-ZyplineConfiguration -Configuration $Config

    # Output changes
    Get-ZyplineConfiguration
}

$cmdlet_config = @{
    function = @('Add-ZyplineSearchPath')
    alias    = @('azsp')
}

Export-ModuleMember @cmdlet_config