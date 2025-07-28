<#
.SYNOPSIS
    Converts a number of bytes into a human-readable size (KB, MB, GB, TB).
.DESCRIPTION
    This private helper function takes a numerical value representing bytes
    and converts it into a more readable format, appending the appropriate
    unit (KB, MB, GB, TB).
.PARAMETER Bytes
    The number of bytes to convert.
.OUTPUTS
    System.String
.EXAMPLE
    Convert-BytesToReadableSize -Bytes 1024
    # Output: 1.00 KB
.EXAMPLE
    Convert-BytesToReadableSize -Bytes 104857600
    # Output: 100.00 MB
#>
function Convert-BytesToReadableSize {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [long]$Bytes
    )

    # Define units and their byte values
    $Units = @("Bytes", "KB", "MB", "GB", "TB")
    $Threshold = 1024 # 1 KB = 1024 Bytes

    # Handle zero bytes explicitly
    if ($Bytes -eq 0) {
        return "0 Bytes"
    }

    # Determine the appropriate unit
    $i = 0
    $Size = [double]$Bytes
    while ($Size -ge $Threshold -and $i -lt ($Units.Length - 1)) {
        $Size /= $Threshold
        $i++
    }

    # Format the output to two decimal places
    return "{0:N2} {1}" -f $Size, $Units[$i]
}

<#
.SYNOPSIS
    Gets the full path to the zypline configuration file.
.DESCRIPTION
    This private helper function constructs the full path to the
    'config.json' file within the user's Documents\zypline directory.
    It also ensures that the directory exists, creating it if necessary.
.OUTPUTS
    System.String
.EXAMPLE
    Get-ZyplineConfigPath
    # Output: C:\Users\YourUser\Documents\zypline\config.json
#>
function Get-ZyplineConfigPath {
    [CmdletBinding()]
    param()

    # Define the directory for zypline configuration
    $ZyplineConfigDir = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\zypline"
    $ZyplineConfigFile = Join-Path -Path $ZyplineConfigDir -ChildPath "config.json"

    # Ensure the directory exists
    if (-not (Test-Path -Path $ZyplineConfigDir -PathType Container)) {
        [Console]::Write("$(csole -s "📁 Creating zypline configuration directory: $ZyplineConfigDir" -c Cyan)`n")
        New-Item -Path $ZyplineConfigDir -ItemType Directory -Force | Out-Null
    }

    return $ZyplineConfigFile
}

Export-ModuleMember -Function 'Convert-BytesToReadableSize', 'Get-ZyplineConfigPath'