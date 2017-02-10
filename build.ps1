$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

# install required vagrant plugin to handle reloads during provisioning
vagrant plugin install vagrant-reload

# start with no machines
vagrant destroy -f
Remove-Item -Path .vagrant -Recurse

vagrant up --provider hyperv
vagrant halt

Remove-Item -Path C:\WindowsSettlerExport\* -Recurse
Export-VM -Name ubuntu-xenial-64 -Path "C:\WindowsSettlerExport"
Remove-Item -Path "C:\WindowsSettlerExport\ubuntu-xenial-64\Snapshots" -Recurse
#Copy-Item -Path $scriptPath\templates\metadata.json -Destination C:\WindowsSettlerExport\ubuntu-xenial-64\metadata.json
Copy-Item -Path c:\Users\halo\PhpStormProjects\settler\templates\metadata.json -Destination C:\WindowsSettlerExport\ubuntu-xenial-64\metadata.json
Resize-VHD -Path "C:\WindowsSettlerExport\ubuntu-xenial-64\Virtual Hard Disks\ubuntu-xenial-64.vhdx" -ToMinimumSize

Add-Type -Assembly "System.IO.Compression.FileSystem";
[System.IO.Compression.ZipFile]::CreateFromDirectory("C:\WindowsSettlerExport\ubuntu-xenial-64", "C:\WindowsSettlerExport\hyperv.box");
