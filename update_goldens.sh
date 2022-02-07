docker build -t pup .
docker run --rm -it -v "${PWD}":/dest pup sh update_goldens_inside_docker.sh