#Clear-Host

$global:AllSolutions = @()
$global:MatchedSolutions = @()
$global:WorkingBuildLog
$global:FailedBuildScriptReport
$global:ScriptLog
$global:VerboseLogging = $false

#Function to write to log file outputing with time and time taken information

$global:ScriptLog

Function WriteToResultsLog($message)
{
    $date = Get-Date    
    $msg = [string]::Format(" Date:{0} Message: {1}", $date, $message)
    #Add-Content $global:FailedBuildScriptReport $msg 
	$msg | Out-File -Append $global:FailedBuildScriptReport
}

Function IsConditionMet
{
	Param ($searchTerm ) 

	$WasFound = $false
	
	$conditionMetStatus = $global:WorkingBuildLog | Select-String -SimpleMatch $searchTerm | Measure
	
	if ($conditionMetStatus.Count -gt 0)
	{
		$WasFound = $true
		$global:WorkingBuildLog | Select-String -SimpleMatch $searchTerm | Measure
	}

	$WasFound
}

Function StartWork
{
	if ($global:VerboseLogging)
	{
		$msg = [string]::Format("Start Work")
		WriteToResultsLog $msg
	}

	$appConfigFile = $currentWorkingDirectory + "/Solutions.xml"

	$msg = [string]::Format("Opening Solutions.xml from {0}", $appConfigFile)
	WriteToResultsLog $msg

	# initialize the xml object
	$appConfig = New-Object XML
	# load the config file as an xml object
	$appConfig.Load($appConfigFile)

	
	foreach ($check in $appConfig.configuration.SolutionChecks.add)
	{
		#$check
		$solutionURL = ""
		$SolutionsFoundCounter = 0
		$SolutionCounter = 0		
		$attributeName = "" 
		
		#Quickly get the number of solutions
		$check.attributes | ForEach { 
		
			if ($_.Name -ne "solutionUrl" -and $_.Name -ne "name")
			{
				$SolutionCounter = $SolutionCounter+1
			}

		}

		#Evaluate those solutions
		$check.attributes | ForEach { 

			if($_.Name -eq "solutionUrl")
			{
				if ($SolutionCounter -gt 0)
				{
					if ($solutionURL -ne $_."#text")
					{
						if ($global:VerboseLogging)
						{
							$msg = [string]::Format("New Solution Set Entered")
							WriteToResultsLog $msg						
						}
					}
				}			
			}

			if ($_.Name -eq "name")
			{
				$attributeName = $_."#text"
				#$attributeName 
			}
			elseif($_.Name -eq "solutionUrl")
			{
				$solutionURL = $_."#text"
				#$solutionURL
			}			
			else
			{	
				#These are the conditions
				$retunCheck = IsConditionMet -searchTerm $_."#text"				
				
				if ($retunCheck)
				{
					if ($global:VerboseLogging)
					{
						$msg = [string]::Format("Condition Found {0}", $_."#text")
						WriteToResultsLog $msg
					}
					
					#Incremement Counter
					$SolutionsFoundCounter = $SolutionsFoundCounter+1					
				}
				else
				{
					if ($global:VerboseLogging)
					{
						$msg = [string]::Format("Condition Not Found {0}", $_."#text")
						WriteToResultsLog $msg
					}
				}

				#If we match to the number of found solutions, we're game
				if ($SolutionCounter -eq $SolutionsFoundCounter)
				{
					$msg = [string]::Format("##[error]Error: Issue Found!!! Please visit the following article to examine possible solutions:{0}", $solutionURL)
					WriteToResultsLog $msg					
				}
				
			}
		}
	}
}


Function MasterEntryPoint($BuildLog)
{
	#Get current working directory 
	$currentWorkingDirectory = $PSScriptRoot

	$global:FailedBuildScriptReport = $currentWorkingDirectory + "/FailedBuildScriptReport.log"

	$msg = [string]::Format("Build Log Analyzer Initialized @ ")
	$msg | Out-File -Append $global:FailedBuildScriptReport
	
	#The build log which we will analyze
	$BuildLog

	#$global:ScriptLog = New-Item $global:FailedBuildScriptReport #-Force
		
	WriteToResultsLog $msg

	$msg = [string]::Format("Current Working Directory {0}", $currentWorkingDirectory)
	WriteToResultsLog $msg

	$msg = [string]::Format("Loading Build Log Start {0}", $BuildLog)
	WriteToResultsLog $msg

	# #Once and Fast
	$global:WorkingBuildLog = Get-Content $BuildLog	

	StartWork

	WriteToResultsLog "Build Log Analyzer Completed @ "

	Get-Content $global:FailedBuildScriptReport
}

#Uncomment this out if you want to test locally and comment out the section checking for command line argumments
#MasterEntryPoint "C:\BuildLogFolder\02_Checkout_Git lfs fetch failed with exit code_2.txt"

#Comment this section out to test locally 
 if ($args.Count -ne 1)
 {
 	"You must supply the full path to the Built Log to be analyzed. "
 }
 else
 {
 	if ([System.IO.File]::Exists($args[0]))
 	{
 		MasterEntryPoint($args[0])
 	}
 	else
 	{
 		"You must supply the full path to the Built Log to be analyzed. The Path provided did not have the build log. "
 		$args[0]
 	}
 }
