# dev-env
Script to setup dev env on a local machine

## Usage
Download the script
```bash
curl -sL https://raw.githubusercontent.com/jnpr-pranav/dev-env/master/dev-env.sh > dev-env.sh
```
Make it executable
```bash
chmod u+x dev-env.sh
```
Run the file
```bash
./dev-env.sh
```

## Notes
In case you get docker already running errors, delete existing dockers via
```bash
docker stop $(docker ps -a | grep contrail | awk '{print $1}')
docker rm $(docker ps -a | grep contrail | awk '{print $1}')
```
Repo sync and fetch / patch third party dependencies takes a long time and does not output anything until the end. Be patient.