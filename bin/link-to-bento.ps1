New-Item -Path ..\bento\packer_templates\ubuntu\scripts\homestead.sh -ItemType SymbolicLink -Value .\scripts\provision.sh -Force
New-Item -Path ..\bento\packer_templates\ubuntu\http\preseed.cfg -ItemType SymbolicLink -Value .\http\preseed.cfg -Force
New-Item -Path ..\bento\packer_templates\ubuntu\http\preseed-hyperv.cfg -ItemType SymbolicLink -Value .\http\preseed-hyperv.cfg -Force

$Template = "..\bento\packer_templates\ubuntu\ubuntu-18.04-amd64.json"
$TextReplacements = @(,
    @('scripts/cleanup.sh', 'scripts/homestead.sh'),
    @('"cpus": "1"', '"cpus": "4"'),
    @('"memory": "1024"', '"memory": "4096"')
    @('"disk_size": "65536"', '"disk_size": "131072"')
)

# Set the configuration_version for Hyper-V
$config = Get-Content -Encoding UTF8 $Template | ConvertFrom-Json
$config.builders | %{if($_.type -eq 'hyperv-iso'){
    Add-Member -InputObject $_ -Name 'configuration_version' -MemberType NoteProperty -Value '{{ user `hyperv_version` }}' -Force
    if ($_.PSobject.Properties.name -match "cpu") {
        Add-Member -InputObject $_ -Name 'cpus' -MemberType NoteProperty -Value $_.cpu
        $_.PSObject.Properties.remove('cpu')
    }
    if ($_.PSobject.Properties.name -match "ram_size") {
        Add-Member -InputObject $_ -Name 'memory' -MemberType NoteProperty -Value $_.ram_size
        $_.PSObject.Properties.remove('ram_size')
    }
}}
$config.variables | Add-Member -Name 'hyperv_version' -MemberType NoteProperty -Value '8.0' -Force
$config | ConvertTo-Json -Depth 100 | %{
    [Regex]::Replace($_, 
        "\\u(?<Value>[a-zA-Z0-9]{4})", {
            param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
                [System.Globalization.NumberStyles]::HexNumber))).ToString() } )} | Set-Content -Encoding UTF8 $Template 

# Replace text in the template using a tempfile since in-place editing won't work
function ReplaceTextInTemplate([string] $originalText, [string] $replacementText)
{
    $TempFile = New-TemporaryFile

    Get-Content $Template -Encoding UTF8 | %{ $_ -replace $originalText, $replacementText} | Set-Content -Path $TempFile
    Get-Content $TempFile -Encoding UTF8 | Set-Content $Template
    Remove-Item $TempFile
}

ForEach ($replacement In $TextReplacements) { ReplaceTextInTemplate -originalText $replacement[0] -replacementText $replacement[1] }