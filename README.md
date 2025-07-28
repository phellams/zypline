# **Zypline PowerShell Module**

 Quickly locate items across configured or specified paths, apply various filters, and receive results in a human-readable format.

## **✨ Features**

* **Configurable Search Paths:** Define and manage your search locations via a JSON configuration file.  
* **Flexible Filtering:** Search by name (wildcard or regex), exclude specific file extensions, and filter by last write time.  
* **Item Type Selection:** Search for files, folders, or both.  
* **Recursive Search:** Dive deep into subdirectories.  
* **Human-Readable Sizes:** Convert file sizes to KB, MB, GB, etc., for easy understanding.  
* **Enhanced Console Output:** Utilizes custom console coloring (via New-ColorConsole) and emojis for a professional and intuitive user experience.

## **📦 Installation**

To install the zypline module, follow these steps:

## **🛠️ Usage**

### **Get-ZyplineConfiguration**

Retrieves the current zypline module's configuration. If no configuration file exists, it will create a default one at `$env:USERPROFILE\Documents\zypline\config.json`.

#### **Syntax**

```powershell
Get-ZyplineConfiguration
```

#### **Examples**

```powershell
# Get the current configuration  
Get-ZyplineConfiguration
```
```powershell
# Store the configuration in a variable  
$Config = Get-ZyplineConfiguration  
$Config.SearchPaths
```

### **Set-ZyplineConfiguration**

Saves a given configuration object to the config.json file, overwriting any existing configuration.

#### **Syntax**

```powershell
Set-ZyplineConfiguration -Configuration <PSCustomObject>
```

#### **Examples**

```powershell
# Create a new configuration object and save it  
$NewConfig = [PSCustomObject]@{  
    SearchPaths = @("C:\Projects", "D:\Data")  
}  
Set-ZyplineConfiguration -Configuration $NewConfig
```

```powershell
# Update an existing configuration  
$CurrentConfig = Get-ZyplineConfiguration  
$CurrentConfig.SearchPaths += "E:\Archives"  
Set-ZyplineConfiguration -Configuration $CurrentConfig
```

### **Add-ZyplineSearchPath**

Adds one or more paths to the zypline search configuration. It ensures that only unique, existing paths are added.

#### **Syntax**

```powershell
Add-ZyplineSearchPath -Path <String[]>
```

#### **Examples**

```powershell
# Add a single search path  
Add-ZyplineSearchPath -Path "C:\MyImportantFolder"
```

```powershell
# Add multiple search paths  
Add-ZyplineSearchPath -Path "C:\Logs", "D:\Backups"
```

### **Remove-ZyplineSearchPath**

Removes one or more paths from the zypline search configuration.

#### **Syntax**

```powershell
Remove-ZyplineSearchPath -Path <String[]>
```

#### **Examples**

```powershell
# Remove a single search path  
Remove-ZyplineSearchPath -Path "$env:USERPROFILE\Downloads"
```

```powershell
# Remove multiple search paths  
Remove-ZyplineSearchPath -Path "C:\OldLogs", "D:\Temp"
```
### **Find-ZyplineItem**

The core search function. It searches configured paths (or explicit paths) for files and folders, applying various filters.

#### **Syntax**

```powershell
Find-ZyplineItem  
    [-Path <String[]>]  
    [-IncludePattern <String>]  
    [-ExcludePattern <String>]  
    [-ExcludeExtension <String[]>]  
    [-OlderThan <DateTime>]  
    [-SearchFolders]  
    [-SearchFiles]  
    [-Recurse]  
    [-UseRegex]  
    [<CommonParameters>]
```

#### **Parameters**

* -**Path** `<String[]>`: One or more root paths to start the search from. If omitted, configured paths are used.  
* -**IncludePattern** `<String>`: A pattern to include items whose names match. Can be wildcard (e.g., *.log) or regex (with `-UseRegex`).  
* -**ExcludePattern** `<String>`: A pattern to exclude items whose names match. Can be wildcard or regex.  
* -**ExcludeExtension** `<String[]>`: An array of file extensions (e.g., "txt", "log") to exclude. Case-insensitive, no dot required.  
* -**OlderThan** `<DateTime>`: Only include items with a LastWriteTime older than this date.  
* -**SearchFolders**: Include folders in the search results.  
* -**SearchFiles**: Include files in the search results. By default, only files are searched if neither `-SearchFolders` nor `-SearchFiles` is specified. If both are specified, both files and folders are searched.  
* -**Recurse**: Include subdirectories recursively.  
* -**UseRegex**: Treat `-IncludePattern` and `-ExcludePattern` as regular expressions.

#### **Examples**

```powershell
# 📄 Find all .log files recursively in configured paths  
Find-ZyplineItem -IncludePattern "*.log" -Recurse

# 🔍 Search a specific path for files older than 30 days, excluding .tmp and .bak  
Find-ZyplineItem -Path "C:\Temp" -ExcludeExtension "tmp", "bak" -OlderThan (Get-Date).AddDays(-30) -Recurse

# 📁 Find folders starting with "Project" recursively  
Find-ZyplineItem -SearchFolders -IncludePattern "Project*" -Recurse

# 📝 Find files matching a specific date pattern using regex  
Find-ZyplineItem -IncludePattern "^\d{4}-\d{2}-\d{2}\_report\.txt$" -UseRegex -Recurse

# 📂📄 Find both files and folders containing "config" in their name  
Find-ZyplineItem -IncludePattern "\*config\*" -SearchFiles -SearchFolders -Recurse  
```

# **Contributing**

If you find a bug or have a suggestion, please [open an issue](https://github.com/your-username/zypline/issues) or [create a pull request](https://github.com/your-username/zypline/pulls).

# **License**

This project is released under the [MIT License](https://opensource.org/licenses/MIT).
