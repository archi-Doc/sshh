# Set-ExecutionPolicy RemoteSigned

$reponame="archidoc422/sshh"
$localname="sshh"

docker buildx build --no-cache -f ./sshh.Dockerfile --platform=linux/amd64,linux/arm64 -t ${localname} .
docker tag ${localname} ${reponame}
docker push ${reponame}

$reponame="archidoc422/sshh.mariadb"
$localname="sshh.mariadb"

docker buildx build --no-cache -f ./sshh.mariadb.Dockerfile --platform=linux/amd64,linux/arm64 -t ${localname} .
docker tag ${localname} ${reponame}
docker push ${reponame}

pause

