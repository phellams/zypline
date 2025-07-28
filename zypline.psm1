#using module libs\core-functions.psm1
using module ..\shelldock\shelldock.psm1
using module cmdlets\Add-ZyplineSearchPath.psm1
using module cmdlets\Remove-ZyplineSearchPath.psm1
using module cmdlets\Set-ZyplineConfiguration.psm1
using module cmdlets\Get-ZyplineConfiguration.psm1
using module cmdlets\Find-ZyplineItem.psm1



$global:__zypline = @{                                                                        
    utility                = @{
        logName = "$(csole -s 'Zypline' -c gray) $(csole -s '▣≈' -c darkmagenta)"
        sublog  = "$(" "*12) + "
    }
    DefaultSearchPaths = @(
            "$env:USERPROFILE\Documents",
            "$env:USERPROFILE\Downloads"
    )
    kvtinc                 = {
        <#
            Hashtable function
            ------------------
            Key Value in color with value type
            Returns a string representation of a key value pair wrapped in ASCII color codes denoting the key and valuetype.
        #>
        param([string]$keyName, [string]$KeyValue, [string]$valueType)
        [string]$kvtStringRep = ''
        $kvtStringRep += "$(csole -s '{' -c magenta) "
        $kvtStringRep += "key-($(csole -s $keyName -c cyan)) : "
        $kvtStringRep += "value-(type-($(csole -s $valueType -c yellow))[$(csole -s $KeyValue -c gray)]) "
        $kvtStringRep += "$(csole -s '}' -c magenta)"   
        return $kvtStringRep
    }
    kvinc                  = {
        <#
            Hashtable function
            ------------------
            Key Value in color
            Returns a string representation of a key value pair wrapped in ASCII color codes
        #>
        param([string]$keyName, [string]$KeyValue)
        return "$(csole -s '{' -c magenta) $(csole -s $keyName -c cyan) : $(csole -s $KeyValue -c gray) $(csole -s '}' -c magenta)"
    }
    kvoinc                 = {
        <#
            Hashtable function
            ------------------
            Key Value object in color
            Returns a string representation of a key value pair ordered array 
            from pscustomobject wrapped in ASCII color codes
            PSCustomObject is used to retain ordering.
        #>
        param([PSCustomObject]$object)
        [string]$kvaToStringRep = ""
        $kvaToStringRep += "$(csole -s '{' -c magenta) "
        
        foreach ($key in $object.psobject.properties.where({ $_.MemberType -eq 'NoteProperty' })) {
            $kvaToStringRep += "$(csole -s $key.name -c cyan) : $(csole -s $key.value -c gray); "
        }
        
        $kvaToStringRep += "$(csole -s '}' -c magenta)"
        return $kvaToStringRep
    }
}

$cmdlet_config = @{
    function = @(
        'Add-ZyplineSearchPath',
        'Remove-ZyplineSearchPath',
        'Set-ZyplineConfiguration',
        'Get-ZyplineConfiguration',
        'Find-ZyplineItem'
    )
    alias    = @(
        'azsp',  # Add-ZyplineSearchPath
        'zyprm', # Remove-ZyplineSearchPath
        'zypset',# Set-ZyplineConfiguration
        'zypget', # Get-ZyplineConfiguration
        'zypfind' # Find-ZyplineItem
    )
}

Export-ModuleMember @cmdlet_config