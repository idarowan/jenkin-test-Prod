#!/bin/bash

# Update and install necessary packages
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor
# Add MongoDB GPG key and repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Install MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Ensure MongoDB binaries are in the PATH
sudo apt-get update
sudo apt-get install -y mongodb-org

# Create directories for data and logs
sudo mkdir -p /var/lib/mongo1 /var/lib/mongo2 /var/lib/mongo3
sudo mkdir -p /var/log/mongodb
sudo chown -R $(id -u) /var/lib/mongo1 /var/lib/mongo2 /var/lib/mongo3
sudo chown -R $(id -u) /var/log/mongodb

# Generate keyfile for internal authentication
openssl rand -base64 756 > /var/lib/mongo1/keyfile
sudo cp /var/lib/mongo1/keyfile /var/lib/mongo2/keyfile
sudo cp /var/lib/mongo1/keyfile /var/lib/mongo3/keyfile
sudo chmod 400 /var/lib/mongo1/keyfile
sudo chmod 400 /var/lib/mongo2/keyfile
sudo chmod 400 /var/lib/mongo3/keyfile
sudo chown $(id -u) /var/lib/mongo1/keyfile
sudo chown $(id -u) /var/lib/mongo2/keyfile
sudo chown $(id -u) /var/lib/mongo3/keyfile

# Create configuration files for each MongoDB instance
cat <<EOF | sudo tee /etc/mongod1.conf
storage:
  dbPath: /var/lib/mongo1
systemLog:
  destination: file
  path: /var/log/mongodb/mongod1.log
  logAppend: true
net:
  bindIp: localhost
  port: 27017
replication:
  replSetName: rs0
security:
  authorization: enabled
  keyFile: /var/lib/mongo1/keyfile
processManagement:
  fork: true
EOF

cat <<EOF | sudo tee /etc/mongod2.conf
storage:
  dbPath: /var/lib/mongo2
systemLog:
  destination: file
  path: /var/log/mongodb/mongod2.log
  logAppend: true
net:
  bindIp: localhost
  port: 27018
replication:
  replSetName: rs0
security:
  authorization: enabled
  keyFile: /var/lib/mongo2/keyfile
processManagement:
  fork: true
EOF

cat <<EOF | sudo tee /etc/mongod3.conf
storage:
  dbPath: /var/lib/mongo3
systemLog:
  destination: file
  path: /var/log/mongodb/mongod3.log
  logAppend: true
net:
  bindIp: localhost
  port: 27019
replication:
  replSetName: rs0
security:
  authorization: enabled
  keyFile: /var/lib/mongo3/keyfile
processManagement:
  fork: true
EOF

# Start MongoDB instances
sudo mongod --config /etc/mongod1.conf
sudo mongod --config /etc/mongod2.conf
sudo mongod --config /etc/mongod3.conf

# Initialize the replica set
sudo mongosh --eval 'rs.initiate({_id: "rs0", members: [{ _id: 0, host: "localhost:27017" }, { _id: 1, host: "localhost:27018" }, { _id: 2, host: "localhost:27019" }]})' --port 27017

sudo mongosh --eval 'use admin
db.createUser({
  user: "admin",
  pwd: "password", // Replace with a strong password
  roles: [{ role: "root", db: "admin" }]
})' --port 27017




------
cat <<EOF | sudo tee kill_mongod.sh
#!/bin/bash

# Find and kill all mongod processes
pids=$(ps aux | grep '[m]ongod' | awk '{print $2}')
if [ -n "$pids" ]; then
  echo "Stopping mongod processes..."
  sudo kill $pids
fi
echo "mongod stooped."
EOF

chmod +x kill_mongod.sh