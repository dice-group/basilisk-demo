# run fuseki
/prod/fuseki/apache-jena-fuseki-4.0.0/fuseki-server --loc "/prod/fuseki/DB" /ds &
# run frontend
nginx -g "daemon off;"

