#Requires -PSEdition Desktop -RunAsAdministrator
<#PSScriptInfo

.VERSION 1.0.0
.GUID f55bad79-3996-4d3b-ba2e-5997b413ce90
.AUTHOR Hudson M
.COMPANYNAME ziroAU
.COPYRIGHT (c) 2024 Hudson M | MIT License
.TAGS Windows software removal hp wolf
.LICENSEURI https://github.com/hudsonm62/Remove-HPWolf/blob/master/license
.PROJECTURI https://github.com/hudsonm62/Remove-HPWolf

.ICONURI
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
[1.0.0] Initial Release

.PRIVATEDATA
#>

<#
.SYNOPSIS
Removes HP Wolf Security.

.DESCRIPTION
Searches for, and removes HP Wolf Security from the machine using WMI.

.LINK
https://enterprisesecurity.hp.com/cloud-login/s/article/How-to-uninstall-HP-Wolf-Pro-Security
#>
[CmdletBinding(SupportsShouldProcess)]
param ()
begin {
    function Remove-WmiProgram {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [String]$Title
    )
    try {
        Write-Verbose "Checking for '$Title' to remove.."
        $Obj = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq $Title}
        if($null -eq $Obj){
            Write-Warning "$Title not found.."
            return;
        }
        $Obj | ForEach-Object {
            Write-Verbose "Running Uninstall() on '$($_.Name)'"
            if($PSCmdlet.ShouldProcess($_.Name, "Uninstall()")){
                $_.Uninstall()
            }
            Write-Verbose "Ran without error"
        };
    }
    catch {
        throw $_
    }
  }
}
  
process {
    $Apps = @(
        "HP Wolf Security",           # 1
        "HP Wolf Security - Console", # 2
        "HP Security Update Service"  # 3
    )
    foreach ($App in $Apps) {
        Remove-WmiProgram -Title $App -ErrorAction Continue
        Start-Sleep 1
    }
}

end {
    Write-Verbose "Checking again for any remaining remnants.."
    $check1 = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "HP Wolf*"}
    $check2 = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "HP Security*"}
    if($check1 -or $check2){ 
        throw "HP Wolf Remnants Remaining:`n$check1`n$check2" 
    }
}
