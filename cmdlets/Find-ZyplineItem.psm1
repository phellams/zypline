using module ..\libs\core-functions.psm1
<#
.SYNOPSIS
    Searches for files and folders based on specified criteria.
.DESCRIPTION
    This is the main function of the zypline module. It allows you to search
    configured paths (or explicit paths) for files and folders, applying
    various filters such as name patterns (match or regex), excluded extensions,
    and last write time. Results are output as PSCustomObjects with readable sizes.
.PARAMETER Path
    One or more root paths to start the search from. If not specified, the
    paths configured in 'config.json' will be used.
.PARAMETER IncludePattern
    A string pattern to include items whose names match. Can be a wildcard
    pattern (e.g., "*.log") or a regular expression if -UseRegex is specified.
.PARAMETER ExcludePattern
    A string pattern to exclude items whose names match. Can be a wildcard
    pattern or a regular expression if -UseRegex is specified.
.PARAMETER ExcludeExtension
    An array of file extensions (e.g., "txt", "log", "bak") to exclude from results.
    Case-insensitive. Do not include the dot (e.g., "txt" not ".txt").
.PARAMETER OlderThan
    A DateTime object. Only items with a LastWriteTime older than this date
    will be included.
.PARAMETER SearchFolders
    If specified, folders will be included in the search results. By default,
    only files are searched unless -SearchFiles is explicitly set to $false.
.PARAMETER SearchFiles
    If specified, files will be included in the search results. By default,
    files are searched. If both -SearchFiles and -SearchFolders are omitted,
    only files are searched.
.PARAMETER Recurse
    If specified, the search will include subdirectories recursively.
.PARAMETER UseRegex
    If specified, -IncludePattern and -ExcludePattern will be treated as
    regular expressions instead of simple wildcard patterns.
.OUTPUTS
    System.Management.Automation.PSCustomObject
.EXAMPLE
    Find-ZyplineItem -IncludePattern "report*" -Recurse -SearchFiles
    # Searches configured paths for files starting with "report" recursively.

.EXAMPLE
    Find-ZyplineItem -Path "C:\Logs" -ExcludeExtension "bak", "tmp" -OlderThan (Get-Date).AddDays(-30)
    # Searches C:\Logs for files (excluding .bak and .tmp) older than 30 days.

.EXAMPLE
    Find-ZyplineItem -IncludePattern "^\d{4}-\d{2}-\d{2}.log$" -UseRegex -SearchFiles -Recurse
    # Searches for files matching the YYYY-MM-DD.log regex pattern.

.EXAMPLE
    Find-ZyplineItem -SearchFolders -IncludePattern "Project*"
    # Searches configured paths for folders starting with "Project".
#>
function Find-ZyplineItem {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType('System.Management.Automation.PSCustomObject')]
    [alias("zypfind")]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path,

        [Parameter()]
        [string]$IncludePattern,

        [Parameter()]
        [string]$ExcludePattern,

        [Parameter()]
        [string[]]$ExcludeExtension,

        [Parameter()]
        [System.DateTime]$OlderThan,

        [Parameter()]
        [switch]$SearchFolders,

        [Parameter()]
        [switch]$SearchFiles,

        [Parameter()]
        [switch]$Recurse,

        [Parameter()]
        [switch]$UseRegex,

        [Parameter()]
        [switch]$JSon
    )

    BEGIN {

        # global hashtable functions
        $kvinc = $global:__zypline.kvinc
        $logname = $global:__zypline.utility.logName
        $sublog = $global:__zypline.utility.sublog

        [Console]::Write("$(csole -s " 🔍 Initiating Zypline Search... 🔍 " -c Green)`n")

        # Load configuration if no explicit paths are provided
        if (-not $PSBoundParameters.ContainsKey('Path')) {
            $Config = Get-ZyplineConfiguration
            $SearchPaths = $Config.SearchPaths
            if (-not $SearchPaths) {
                [Console]::Write("$logname ❌ $(csole -s "No search paths configured or provided. Exiting." -c Red)`n")
                return
            }
            [Console]::Write("$logname 🗃️ $(csole -s "Using configured search paths: $($SearchPaths -join ', ') " -c Cyan)`n")
        }
        else {
            $SearchPaths = $Path
            [Console]::Write("$logname 📂 $(csole -s "Using explicit search paths: $($SearchPaths -join ', ') " -c Cyan)`n")
        }

        # Validate search paths
        $ValidSearchPaths = @()
        foreach ($p in $SearchPaths) {
            if (Test-Path -Path $p -PathType Container) {
                $ValidSearchPaths += $p
            }
            else {
                [Console]::Write("$logname ⚠️ $(csole -s "Warning: Search path not found or invalid: '$p'. Skipping." -c Yellow)`n")
            }
        }
        $SearchPaths = $ValidSearchPaths
        if (-not $SearchPaths) {
            [Console]::Write("$logname ❌ $(csole -s "No valid search paths available. Exiting." -c Red)`n")
            return
        }

        # Normalize ExcludeExtension to lowercase for case-insensitive comparison
        $NormalizedExcludeExtension = @()
        if ($ExcludeExtension) {
            $NormalizedExcludeExtension = $ExcludeExtension | ForEach-Object { $_.TrimStart('.').ToLowerInvariant() }
            [Console]::Write("$logname ❌ $(csole -s "Excluding extensions: $($NormalizedExcludeExtension -join ', ') " -c Magenta)`n")
        }

        # Determine what to search for (files, folders, or both)
        $SearchFilesOnly = $true
        $SearchFoldersOnly = $false

        if ($SearchFiles.IsPresent -and $SearchFolders.IsPresent) {
            $SearchFilesOnly = $false # Search both
            $SearchFoldersOnly = $false
            [Console]::Write("$logname 📂 $(csole -s "Searching for both files and folders. " -c DarkCyan)`n")
        }
        elseif ($SearchFolders.IsPresent) {
            $SearchFilesOnly = $false
            $SearchFoldersOnly = $true
            [Console]::Write("$logname 📁 $(csole -s "Searching for folders only. " -c DarkCyan)`n")
        }
        elseif ($SearchFiles.IsPresent) {
            $SearchFilesOnly = $true
            $SearchFoldersOnly = $false
            [Console]::Write("$logname 📄 $(csole -s "Searching for files only. " -c DarkCyan)`n")
        }
        else {
            # Default behavior: search files only if neither switch is specified
            $SearchFilesOnly = $true
            $SearchFoldersOnly = $false
            [Console]::Write("$logname 📄 $(csole -s "Defaulting to search for files only. " -c DarkCyan)`n")
        }
        $FoundItems = @()
        $FoundItemsCount = 0
        $StartTime = Get-Date
    }
    PROCESS {
        foreach ($CurrentPath in $SearchPaths) {
            [Console]::Write("$logname 🔎 $(csole -s "Searching in: $($kvinc.invoke('path', $CurrentPath)) " -c Yellow)`n")

            try {
                # Get-ChildItem parameters
                $GciParams = @{
                    Path        = $CurrentPath
                    ErrorAction = 'SilentlyContinue'
                }
                if ($Recurse) { $GciParams.Recurse = $true }
                if ($SearchFilesOnly -and -not $SearchFoldersOnly) { $GciParams.File = $true }
                if ($SearchFoldersOnly -and -not $SearchFilesOnly) { $GciParams.Directory = $true }

                # Get items, then filter based on type if both files and folders are allowed
                $Items = Get-ChildItem @GciParams | Where-Object {
                    # Filter by type if both files and folders are allowed
                    if ($SearchFiles.IsPresent -and $SearchFolders.IsPresent) {
                        $true # All types allowed
                    }
                    elseif ($SearchFiles.IsPresent) {
                        -not $_.PSIsContainer # Only files
                    }
                    elseif ($SearchFolders.IsPresent) {
                        $_.PSIsContainer # Only folders
                    }
                    else {
                        -not $_.PSIsContainer # Default: only files
                    }
                }

                foreach ($Item in $Items) {
                    # Apply ExcludeExtension filter (only for files)
                    if (-not $Item.PSIsContainer -and $NormalizedExcludeExtension.Count -gt 0) {
                        $ItemExtension = $Item.Extension.TrimStart('.').ToLowerInvariant()
                        if ($NormalizedExcludeExtension -contains $ItemExtension) {
                            continue # Skip this item
                        }
                    }

                    # Apply OlderThan filter
                    if ($PSBoundParameters.ContainsKey('OlderThan') -and $Item.LastWriteTime -ge $OlderThan) {
                        continue # Skip this item
                    }

                    # Apply IncludePattern filter
                    if ($PSBoundParameters.ContainsKey('IncludePattern')) {
                        if ($UseRegex) {
                            if ($Item.Name -notmatch $IncludePattern) {
                                continue # Skip if name doesn't match regex
                            }
                        }
                        else {
                            if ($Item.Name -notlike $IncludePattern) {
                                continue # Skip if name doesn't match wildcard
                            }
                        }
                    }

                    # Apply ExcludePattern filter
                    if ($PSBoundParameters.ContainsKey('ExcludePattern')) {
                        if ($UseRegex) {
                            if ($Item.Name -match $ExcludePattern) {
                                continue # Skip if name matches regex
                            }
                        }
                        else {
                            if ($Item.Name -like $ExcludePattern) {
                                continue # Skip if name matches wildcard
                            }
                        }
                    }

                    # If all filters pass, create and output the PSCustomObject
                    $SizeInBytes = if ($Item.PSIsContainer) { 0 } else { $Item.Length }
                    $ReadableSize = Convert-BytesToReadableSize -Bytes $SizeInBytes

                    $FoundItems += [PSCustomObject]@{
                        Name          = $Item.Name
                        Path          = $Item.FullName
                        Type          = if ($Item.PSIsContainer) { "Folder" } else { "File" }
                        LastWriteTime = $Item.LastWriteTime
                        Size          = $SizeInBytes
                        ReadableSize  = $ReadableSize
                    }
                    $FoundItemsCount++
                }
            }
            catch {
                [Console]::Write("$logname ❌ $(csole -s "Error accessing path '$CurrentPath': $($_.Exception.Message)" -c Red)`n")
            }
        }
        $EndTime = Get-Date
        $ElapsedTime = ($EndTime - $StartTime).TotalSeconds
        [Console]::Write("$logname ✅ $(csole -s "Zypline Search Complete! Found $FoundItemsCount items in $($ElapsedTime.ToString('N2')) seconds. " -c Green)`n")
        return $FoundItems
    }
}

$cmdlet_config = @{
    function = @('Find-ZyplineItem')
    alias    = @('zypfind')
}

Export-ModuleMember @cmdlet_config