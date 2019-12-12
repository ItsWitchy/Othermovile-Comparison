######################################################################################
### Script for comparing User's "othermobile" tag to their current office location ###
######################################################################################


### Gathers all FH Users and their "othermobile" property and combines them together ###
$OmAF  = Get-ADUser -filter * -properties othermobile,otherFacsimileTelephoneNumber -SearchBase "OU=AF,DC=corp,DC=fleishman,DC=com"
$OmAP  = Get-ADUser -filter * -properties othermobile,otherFacsimileTelephoneNumber -SearchBase "OU=AP,DC=corp,DC=fleishman,DC=com"
$OmC   = Get-ADUser -filter * -properties othermobile,otherFacsimileTelephoneNumber -SearchBase "OU=Companies,DC=corp,DC=fleishman,DC=com"
$OmEU  = Get-ADUser -filter * -properties othermobile,otherFacsimileTelephoneNumber -SearchBase "OU=EU,DC=corp,DC=fleishman,DC=com"
$OmNA  = Get-ADUser -filter * -properties othermobile,otherFacsimileTelephoneNumber -SearchBase "OU=NA,DC=corp,DC=fleishman,DC=com"
$OmSA  = Get-ADUser -filter * -properties othermobile,otherFacsimileTelephoneNumber -SearchBase "OU=SA,DC=corp,DC=fleishman,DC=com"
$OmAll = $OmAF + $OmAP + $OmC + $OmEU + $OmNA + $OmSA

### Gets FH office location descriptions ###
$OfficeOU = Get-ADOrganizationalUnit -Filter {(Name -like "*Users*") -and (Description -gt 1)} -Properties Description

### Loop compares User's "othermobile" tag to parent folder description tag ###
foreach ($User in $OmALL)
{
    $ParentOUDN = $user.DistinguishedName.Substring($user.DistinguishedName.IndexOf("OU="))
    #$ParentOUDN = (([adsi]"LDAP://$($User.DistinguishedName)").Parent).Substring(7)
    $ParentOUObj = (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $ParentOUDN} -Properties Description).description

    if (($User.othermobile -ne $ParentOUObj) -and ($User.otherFacsimileTelephoneNumber -ne 'Secondary') -and ($ParentOUObj))
    {
        Set-ADUser -Identity $User -Replace @{otherMobile=$ParentOUObj} -WhatIf
        Write-Verbose -Message "$($User.SamAccountName) changed to $ParentOUObj" -Verbose
    }
} 