# powershell-JsonExpressions
A very simple implementation of powershell expressions invoked from within json file as keywords.

## Sample usage

1) Create a new object which will be our parser
`$Parser = [JsonExpressions]::new()`

2) Run Parse() function which .json file path as paramter and assign the output to variable
`$ParsedString = $Parser.Parse("example.json")`

3) Create new PSCustomObject from parsed .json string
`ConvertFrom-Json $ParssedString`

Example output:
```
hostname        whoami
--------        ------
DESKTOP-SVAS23 desktop-SVAS23\powa458
```
