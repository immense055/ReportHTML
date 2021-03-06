
cls
Remove-Module ReportHTML
Import-Module C:\Users\matt.quickenden\Documents\GitHub\AzureFieldNotes\ReportHTML\ReportHTML\ReportHTML.psd1 -verbose
#Get-Module reportHTML
#Get-Command -Module reporthtml

$MyPath = 'c:\temp\new'
New-HTMLReportOptions -SaveOptionsPath $MyPath 


$rpt=@()
$rpt += Get-HtmlOpenPage -TitleText "Azure VM Sizing" -LeftLogoString $Script:SAMPLE_LOGO_SOURCE # -logoPath C:\temp\new -LeftLogoName ChartJS -RightLogoName ChartJSWord
$rpt += get-HTMLClosePage

Save-HTMLReport -reportpath c:\temp -reportcontent $rpt -ReportName testit


#
#
#Login-AzureRmAccount;
$VMs = get-azurermvm 
$AzurePortal = "https://portal.azure.com/#resource"
$VMBreakdowns = @()
foreach ($vm in $vms) {
	$VMBreakdown = '' | select ResourceGroup, ID, VMName, OSType, URL, Size, location, StorageAccount
	$VMBreakdown.ResourceGroup = $vm.ResourceGroupName
	$VMBreakdown.ID = $vm.Id
	$VMBreakdown.VMName = $vm.Name
	$VMBreakdown.URL =  ('URL01' + $AzurePortal + $vm.Id + 'URL02' + $vm.Name + 'URL03')
	$VMBreakdown.location = $vm.location 
	$VMBreakdown.Size = $vm.HardwareProfile.VmSize
	#$VMBreakdown.OSType = $vm.OSProfile.WindowsConfiguration 
	$VMBreakdown.StorageAccount = ($vm.StorageProfile.OsDisk.Vhd.Uri.Split('.')[0]).split('//')[2]
	$VMBreakdowns += $VMBreakdown
}

$VMSize = $VMBreakdowns | group size

$VMLocation = $VMBreakdowns | group location

$VMResourceGroup = $VMBreakdowns | group ResourceGroup

$VMStorage = $VMBreakdowns | group StorageAccount

$rpt = @()
$rpt += Get-HtmlOpenpage -TitleText "Azure VM Sizing"  -csspath 'c:\temp\new' -colorschemepath 'c:\temp\new' -LeftLogoString 'http://www.dhl.com/img/meta/dhl_logo.gif' -RightLogoString 'http://www.dhl.com/content/dam/General%20DHL%20pictures/Logos/IA_Refresh/careers_129px.png'
	$rpt += Get-HtmlContentOpen -HeaderText "Azure VM Report"
		$rpt += Get-HTMLColumn1of2
			$PieObject = Get-HTMLPieChartobject -charttype doughnut
			$PieObject.ChartStyle.ColorSchemeName= 'ColorScheme4'
			$PieObject.Title = 'VMs by Location'
			$rpt += Get-HTMLPieChart -DataSet $VMLocation -chartobject $PieObject
			$rpt += get-htmlcontenttable ($VMLocation | select Name, count)
		$rpt += Get-HTMLColumnClose
		$rpt += Get-HTMLColumn2of2
			$VMSizeBarObject = Get-HTMLBarChartobject
			$VMSizeBarObject.Title = 'VMs by Size'
			$rpt += Get-HTMLBarChart -DataSet $VMSize -chartobject $VMSizeBarObject 
			$rpt += get-htmlcontenttable ($VMSize | select Name, count)
		$rpt += Get-HTMLColumnClose

		$rpt += Get-HTMLColumn1of2
			$OSPieObject = Get-HTMLPieChartobject 
			$OSPieObject.ChartStyle.ColorSchemeName= 'ColorScheme4'
			$OSPieObject.Title = "VMs by Storage Account Type"
			$rpt += Get-HTMLPieChart -DataSet $VMStorage -chartobject $OSPieObject
			$rpt += get-htmlcontenttable ($VMStorage | select Name, count)
		$rpt += Get-HTMLColumnClose
		$rpt += Get-HTMLColumn2of2
			$VMRGBarObject = Get-HTMLBarChartobject
			$VMRGBarObject.Title = 'VMs Count by Resource Group'
			$rpt += Get-HTMLBarChart -DataSet $VMResourceGroup -chartobject $VMRGBarObject 
			$rpt += get-htmlcontenttable ($VMResourceGroup | select Name, count)
		$rpt += Get-HTMLColumnClose

	$rpt += Get-HtmlContentClose
	
	$rpt += Get-HtmlContentOpen -HeaderText "Azure VM Data Set" -IsHidden
		$rpt += get-htmlcontenttable ($VMBreakdowns | select ResourceGroup,	URL ,Size	,location	,StorageAccount) -GroupBy ResourceGroup
	$rpt += Get-HtmlContentClose
$rpt += Get-HtmlClosePage

save-htmlreport -reportpath c:\temp -reportcontent $rpt -ReportName testit



