
# disable shard allocation

curl -X PUT "100.100.100.111:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": "none"
  }
}
'

# stop indexing and perform a synced flush

curl -X POST "100.100.100.111:9200/_flush/synced"

# shutdown all nodes

cd ../ansible

ansible-playbook stop_elasticsearch.yml -i hosts


# upgrade all nodes


# start each upgraded node

ansible-playbook start_elasticsearch_master.yml -i hosts

sleep 30s

ansible-playbook start_elasticsearch_data.yml -i hosts

# wait

cd ../shell

# sleep 30s

curl -X GET "100.100.100.111:9200/_cat/health"
# curl -X GET "localhost:9200/_cat/recovery"

# reenable allocation

curl -X PUT "100.100.100.111:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}
'

