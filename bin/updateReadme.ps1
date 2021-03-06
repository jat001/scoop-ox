param(
    [Switch] $Append,
    [Switch] $Push
)

. "$PSScriptRoot\NaturalSort.ps1"

$dir = Resolve-Path "$PSScriptRoot\.."
$url = 'https://github.com/jat001/scoop-ox/tree/master/bucket'

$search = '<!-- Generated by bin\updateReadme.ps1, do not edid it manually. -->'
$text = "$search
Name | Description | Version | License
--- | --- | --- | ---
"

Sort-Naturally (Get-ChildItem "$dir\bucket") | ForEach-Object -Process {
    $name = ($_.Name -Split '.', -2, 'SimpleMatch')[0]
    $data = Get-Content $_.FullName | ConvertFrom-Json
    $text += "[$name]($($data.homepage)) | $($data.description) | [$($data.version)]($url/$($_.Name)) | [$($data.license.identifier)]($($data.license.url))`r`n"
}

$text += "$search"
$search = [Regex]::Escape($search)

$orig = Get-Content "$dir\README.md" -Raw
$text = ($Append) ? "$orig$text`r`n" : $orig -Replace "(?s)$search.*?$search", $text
$text | Out-File "$dir\README.md" -NoNewline

if ($Push) {
    git -C "$dir" add "$dir\README.md"
    git -C "$dir" commit -m 'Update apps list on readme'
    git -C "$dir" push origin master
}
