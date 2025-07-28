using module ..\libs\core-functions.psm1
<#
.SYNOPSIS
    Removes one or more paths from the zypline search configuration.
.DESCRIPTION
    This function retrieves the current zypline configuration, removes the specified
    paths from the 'SearchPaths' array, and then saves the updated configuration.
.PARAMETER Path
    One or more paths to remove from the search configuration.
.EXAMPLE
    Remove-ZyplineSearchPath -Path "C:\OldFolder"
.EXAMPLE
    Remove-ZyplineSearchPath -Path "C:\Folder1", "D:\Folder2"
#>
function Remove-ZyplineSearchPath {
    [CmdletBinding()]
    [alias("zyprm")]
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
        if ($CurrentPaths -contains $p) {
            [void]$CurrentPaths.Remove($p)
            [Console]::Write("$logname 🗑️ $(csole -s "Removed search path: '$($kvinc.invoke('path',$p))'" -c Yellow)`n")
        }
        else {
            [Console]::Write("$logname ℹ️ $(csole -s "Path not found in configuration: '$($kvinc.invoke('path',$p))'" -c Cyan)`n")
        }
    }

    $Config.SearchPaths = $CurrentPaths | Sort-Object -Unique
    Set-ZyplineConfiguration -Configuration $Config
}

$cmdlet_config = @{
    function = @('Remove-ZyplineSearchPath')
    alias    = @('zyprm')
}

Export-ModuleMember @cmdlet_config