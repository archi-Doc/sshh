# Set-ExecutionPolicy RemoteSigned

$localname="sshh"

docker buildx build --no-cache -f ./sshhtemp.Dockerfile --platform=linux/amd64 -t ${localname} .
