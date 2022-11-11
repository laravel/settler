# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

New-Item -Path ..\bento\packer_templates\ubuntu\scripts\homestead.sh -ItemType SymbolicLink -Value .\scripts\amd64.sh -Force
New-Item -Path ..\bento\packer_templates\ubuntu\scripts\homestead-arm.sh -ItemType SymbolicLink -Value .\scripts\arm.sh -Force
New-Item -Path ..\bento\packer_templates\ubuntu\http\preseed.cfg -ItemType SymbolicLink -Value .\http\preseed.cfg -Force
New-Item -Path ..\bento\packer_templates\ubuntu\http\preseed-hyperv.cfg -ItemType SymbolicLink -Value .\http\preseed-hyperv.cfg -Force

# AMD64
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json -Raw) -replace 'scripts/cleanup.sh', 'scripts/homestead.sh') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json -Raw) -replace '"memory": "1024"', '"memory": "2084"') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json -Raw) -replace '"disk_size": "65536"', '"disk_size": "131072"') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json -Raw) -replace '"boot_wait": "5s"', '"boot_wait": "3s"') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json -Raw) -replace '"type": "hyperv-iso",', '"type": "hyperv-iso","configuration_version": "9.0",') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-amd64.json

# ARM64
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json -Raw) -replace 'scripts/cleanup.sh', 'scripts/homestead-arm.sh') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json -Raw) -replace '"memory": "1024"', '"memory": "2084"') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json -Raw) -replace '"disk_size": "65536"', '"disk_size": "131072"') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json -Raw) -replace '"boot_wait": "5s"', '"boot_wait": "3s"') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json
((Get-Content -path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json -Raw) -replace '"type": "hyperv-iso",', '"type": "hyperv-iso","configuration_version": "9.0",') | Set-Content -Path ..\bento\packer_templates\ubuntu\ubuntu-20.04-arm64.json
