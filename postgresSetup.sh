# launch the postgres image called 'post_setup',
# attach it to the local volume
docker run --rm --name post_setup \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=docker \
  -d \
  -p 5432:5432 \
  -v $HOME/Library/CloudStorage/OneDrive-q²methodsGmbH\&Co.KG/Docker/DB/postgres:/var/lib/postgresql/data \
  postgres:13.3

# create a new role, and two databases
echo "CREATE ROLE rahul WITH PASSWORD 'pass' CREATEDB LOGIN;
CREATE DATABASE work; CREATE DATABASE anomaly;" | \
 docker exec -i post_setup \
 psql -U postgres

# stop the docker container
docker stop post_setup