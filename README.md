# FailedBuildAnalyzer

## Overview

The purpose of this script is to quickly analyze build logs for text hints which we use to guide uses to known useful content. Ideally, only solutions which can be determined by text analysis only will be part of this effort in the initial stage.

[FailedBuildAnalyzer.ps](/FailedBuildAnalyzer.ps1) is the starting point of the analyzer. To use this script, you need to supply the following parameter:
* `BuildLogPath` - the complete path to an existing build log which needs analysis. This can be the complete build log or a partial log. If a partial log is used, some scripts may be useless. Try to use the full log file as a general recommendation. 

The master script assumes the working directory will contain a file "Solutions.xml". The script is designed to scan build logs for a set of text conditions found within that file. If all the conditions are met, then we reflect that in a log file which is generated from executing the script. You should have the following information read to update the solutions.xml file:

```        
<add name="Solution1" solutionUrl="https://github.com/tdevere/AppCenterSupportDocs/blob/main/Build/Repository_Over_Data_Quota.md" 
            condition1 = "##[error]Git lfs fetch failed with exit code: 2. Git lfs logs returned with exit code: 0." 
            condition2="This repository is over its data quota." />`
```
- name = simply keep the formatting and add an integer next in line
- solutionUrl = we need to use the full path to the document.
- condition(n) = each text condition you need to validate your have a hit

## Example: Demo Usage
From PowerShell prompt, run the following command:

     & "C:\Users\Tony\source\repos\FailedBuildGuide.tony.devere\PowerShellScripts\FailedBuildAnalyzer.ps1" "C:\BuildLogFolder\logs_322\1_Build.txt" 

* & indicates that you wish to execute the PS1 script
* "C:\Users\Tony\source\repos\FailedBuildGuide.tony.devere\PowerShellScripts\FailedBuildAnalyzer.ps1" is the full path the FailedBuildAnalyzer script
* "C:\BuildLogFolder\logs_322\1_Build.txt" is the full path to the build log file you wish to analyze 

After the script has executed, locate the file "FailedBuildScriptReport.log" which will contain the output of the script. This is an example output from the script

```
Build Log Analyzer Initialized @ 
 Date:6/10/2020 4:28:08 PM Message: Build Log Analyzer Initialized @ 
 Date:6/10/2020 4:28:08 PM Message: Current Working Directory C:\repro\FailedBuildGuide\BuildAnalysisScripts\PowerShellScripts
 Date:6/10/2020 4:28:08 PM Message: Loading Build Log Start C:\BuildLogFolder\Sample_Data\02_Checkout_Git lfs fetch failed with exit code_2.txt
 Date:6/10/2020 4:28:08 PM Message: Opening Solutions.xml from C:\repro\FailedBuildGuide\BuildAnalysisScripts\PowerShellScripts\Solutions.xml
 Date:6/10/2020 4:28:08 PM Message: Issue Found!!! Please visit the following article to examine possible solutions:https://dev.azure.com/tdevere/FailedBuildGuide/_wiki/wikis/VS%20App%20Center%20Failed%20Build%20WIKI/35/Checkout?anchor=%60%23%23%5Berror%5Dgit-lfs-fetch-failed-with-exit-code%3A-2.-git-lfs-logs-returned-with-exit-code%3A-0.%60
 Date:6/10/2020 4:28:08 PM Message: Build Log Analyzer Completed @ 
```

## Notes

* If your case isn't met from conditional text matching but nevertheless can be detected from script analysis, propose a standalone script for review
* We can extend our current script design to include a new attribute "executeScript" and point to these scenarios with little impact to the existing script process
* Last note, please try to do the script update if you are also added new Wiki content to keep the two in sync