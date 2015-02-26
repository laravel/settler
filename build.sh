rm -rf builds/*.box

packer build settler.json

ls -lh builds/
