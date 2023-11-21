# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

New-Item -Path ..\bento\packer_templates\ubuntu\http\preseed.cfg -ItemType SymbolicLink -Value .\http\preseed.cfg -Force
New-Item -Path ..\bento\packer_templates\ubuntu\http\preseed-hyperv.cfg -ItemType SymbolicLink -Value .\http\preseed-hyperv.cfg -Force