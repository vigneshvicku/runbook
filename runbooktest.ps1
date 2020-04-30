param (
    [Parameter(Mandatory=$false)] 
    [String]  $AzureCredentialAssetName = 'AzureCredential',
        
    [Parameter(Mandatory=$false)]
    [String] $AzureSubscriptionIdAssetName = 'AzureSubscriptionId',

    [Parameter(Mandatory=$false)] 
    [String] $ResourceGroupName
)


[OutputType([String])]


$Cred = Get-AutomationPSCredential -Name $AzureCredentialAssetName -ErrorAction Stop

$null = Add-AzureRmAccount -Credential $Cred -ErrorAction Stop -ErrorVariable err
if($err) {
	throw $err
}

$SubId = Get-AutomationVariable -Name $AzureSubscriptionIdAssetName -ErrorAction Stop


if ($ResourceGroupName) 
{ 
	$VMs = Get-AzureRmVM -ResourceGroupName $ResourceGroupName
}
else 
{ 
	$VMs = Get-AzureRmVM
}


foreach ($VM in $VMs)
{
	$StartRtn = $VM | Start-AzureRmVM -ErrorAction Continue

	if ($StartRtn.Status -ne 'Succeeded')
	{
	
        Write-Output ($VM.Name + " failed to start")
        Write-Error ($VM.Name + " failed to start. Error was:") -ErrorAction Continue
		Write-Error (ConvertTo-Json $StartRtn.Error) -ErrorAction Continue
	}
	else
	{
	
		Write-Output ($VM.Name + " has been started")
	}
}
