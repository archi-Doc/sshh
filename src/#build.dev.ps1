# Set-ExecutionPolicy RemoteSigned

$localname="sshh"

docker buildx build --pull --no-cache -f ./src/sshhtemp.Dockerfile --platform=linux/amd64 -t ${localname} .
