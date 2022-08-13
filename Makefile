.PHONY: *

gogo: stop-services build truncate-logs start-services

build:
	cd go && make isuports

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isuports.service
	sudo systemctl stop mysql

start-services:
	sudo systemctl start mysql
	sleep 5
	sudo systemctl start isuports.service
	sudo systemctl start nginx

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log
	sudo truncate --size 0 /var/log/mysql/mysql-slow.log
	sudo truncate --size 0 /home/isucon/tmp/logs/go.log
	sudo chmod 777 /var/log/mysql/mysql-slow.log
	sudo journalctl --vacuum-size=1K

kataribe:
	sudo cat /var/log/nginx/access.log | ./kataribe -conf kataribe.toml

sqlite-log:
	cat ~/tmp/logs/go.log | jq .statement | sort | uniq -c | sort -n

bench:
	ssh isucon-bench "cd bench && ./bench -target-addr 172.31.10.233:443"
