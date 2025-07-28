@{
    RootModule         = 'zypline.psm1'
    ModuleVersion      = '0.1.0'
    GUID               = 'ccc9be26-17aa-4a86-8d5b-14d6d15def37'
    Author             = 'Garvey k. Snow'
    CompanyName        = 'Phellams'
    Copyright          = '(c) 2025 Garvey k. Snow. All rights reserved.'
    Description        = 'A PowerShell module for advanced file and folder searching with configuration management.'
    FunctionsToExport  = @(
        'Add-ZyplineSearchPath',
        'Remove-ZyplineSearchPath',
        'Set-ZyplineConfiguration',
        'Get-ZyplineConfiguration',
        'Find-ZyplineItem'
    )
    CmdletsToExport    = @()
    VariablesToExport  = @()
    AliasesToExport    = @(
        'azsp',  # Add-ZyplineSearchPath
        'zyprm',  # Remove-ZyplineSearchPath
        'zypset', # Set-ZyplineConfiguration
        'zypget',  # Get-ZyplineConfiguration
        'zypfind' # Find-ZyplineItem
    )
    PrivateData        = @{
        PSData = @{
            Tags         = @('Help', 'Formatting', 'CLI', 'PowerShell', 'Documentation')
            ReleaseNotes = @{
                '1.2.1' = 'Initial release with New-PHWriter cmdlet for custom help formatting and enhanced layout.'
            }
        }        
    }
    RequiredModules    = @()
    RequiredAssemblies = @()
    FormatsToProcess   = @()
    TypesToProcess     = @()
    NestedModules      = @()
    ScriptsToProcess   = @()
}
