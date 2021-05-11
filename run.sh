# run fuseki
cd fuseki && apache-jena-fuseki-4.0.0/fuseki-server --loc DB /ds &
# run frontend
nginx -g "daemon off;"

