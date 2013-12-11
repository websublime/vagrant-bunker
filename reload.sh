if [[ ! -d "/home/vagrant/.system-ready" ]]; then
	mkdir "/home/vagrant/.system-ready"
	echo "Created directory .system-ready"
else
	echo "Updating system"
	sudo apt-get update
	sudo apt-get upgrade

	echo "Updating Composer"
	sudo composer self-update
fi