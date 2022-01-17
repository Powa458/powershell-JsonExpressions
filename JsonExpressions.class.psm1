class JsonExpressions {
    [System.Collections.Generic.List[PSCustomObject]]$Expressions

    JsonExpressions() {
        $this.Expressions = @(
            [PSCustomObject]@{
                Keyword     = "hostname"
                Expression  = {
                    hostname.exe
                }
            },
            [PSCustomObject]@{
                Keyword     = "whoami"
                Expression  = {
                    whoami.exe
                }
            }
        )
    }

    [string] Parse([string]$JsonFile) {
        try {
            if (Test-Path $JsonFile) {
                if ([System.IO.Path]::GetFileName($JsonFile) -notmatch '(\.json)$') {
                    $Message = "The specified file isn't a .JSON file."
                    throw $Message
                }
            }
            else {
                $Message = "The specified file dosen't exist. Please check provided path."
                throw $Message
            }

            $CurrentContent = Get-Content -Path $JsonFile
            $UpdatedContent = ""

            foreach ($Line in $CurrentContent) {
                if ($Line -match '(?<=\{\{)[^\}\}]*(?=\}\})') { # Check each line if match the pattern of expression.
                    $MatchedKeywords = ([regex]::Matches($Line, '(?<=\{\{)[^\}\}]*(?=\}\})').Value) # Get evry occurence of epression with match {{[string]/[int]}} pattern.
                    foreach ($Keyword in $MatchedKeywords) {
                        if (-not($this.Expressions.Keyword.Contains($Keyword))) { # Validate if found keyword exist in schema.
                            $Message = "Expression keyword: $Keyword, do not exist in schema and can not be used."
                            throw $Message
                        }
                        else {
                            $Line = $Line -replace "{{$Keyword}}", (Invoke-Command -ScriptBlock ($this.Expressions | Where-Object {$_.Keyword -match $Keyword}).Expression) # Replace the instance of keyword with associated expression.
                            $Line = [regex]::Replace($Line, '([\\]+)', "\\") # Replace any instance of one "\" with "\\" (Some commands my return "\" in output) as .JSON my brakes.
                        }
                    }
                    $UpdatedContent += $Line # Append the new content with modified line.
                }
                else {
                    $UpdatedContent += $Line # Append new content with unchanged line.
                }
            }

            return $UpdatedContent # Final return of new string.
        }
        catch {
            $Message = "{0}: '{1}': Line {2}" -f ($_.Exception.GetType().FullName), ($_.Exception.Message), ($_.InvocationInfo.ScriptLineNumber) # In the catch statement $_ or $PSItem refers to error record which triger the catch.
            throw $Message # If we want to use $PSCmdlet.ThrowTerminatingError() then we need to create error record.
        }
    }
}