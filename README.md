### Ubuntu repo builder with Docker

##### Prerequisities

1. Docker installed. 

##### Prepare to build

1. Packages in the repository are signed with the GPG key. If you already have a pair of keys,
export it to ASCII and put it in **pgp_keys** directory. Keys will be imported. 
If an **email** field of a key matches **maintainer_email**, the key will be used. 
Otherwise a new key will be generated.

2. A self-signed certificate for nginx will be generated when building. Further.
it can be replaced

3. Key generation requires a fair amount of entropy. Docker uses host machine
entropy source. Therefore, to speed up the build it is recommended to install
haveged
```
sudo apt-get install haveged
sudo service haveged start 
```

##### Repo building

```
git clone https://github.com/shadowlamer/docker_repo_builder.git
cd docker_repo_builder
docker build [<parameters>] -t ubuntu_packages .
```

For each parameter you need to specify:

```
--build-arg <parameter_name>=<value>
```

| Параметр               | Описание                                          |
| ---------------------- |:--------------------------------------------------|
| repo                   | Ubuntu distro name, e.g. 'xenial'                 |
| repo_url               | Repo deploying URL                                |
| repo_user, repo_passwd | Login and password to protect the repo            |
| repo_label             | Repo description                                  |
| maintainer_name        | Name to generate GPG key                          |
| maintainer_email       | Email to generate GPG key                         |
| git_user, git_passwd   | Will be passed to scripts as ${BBUSER}, ${BBPASS} |

To facilitate the build, there is a **config.sh** script that asks for parameters and then 
generates **build.sh** script, which you can run to build. Parameters are saved in the **.settings** 
file. It also generates **.yml** file to run the container using docker-compose.

##### Prepare to run

1. Generate signed openssl certificates for nginx. Use Let’s Encrypt, for example.

2. If you are going to use docker-compose, edit paths to certificates in ubuntu-packages.yml.

##### Run repo

###### With docker
```
docker run -p 80:90 -p 443:443 -v <cert_path>:sslcerts/certificate.pem -v <privkey_path>:sslcerts/privkey.pem ubuntu-packages --detach
```

###### With docker-compose
```
docker-compose -f ubuntu-packages.yml up -d
```

##### Add package

If the package has its own build system, put the script that builds the package 
in **scripts/src-packages**. *.sh* extension is required. Don't forget to give it permission to run.
Packages built must have *.deb* extension and placed in /output

**Do not store package source codes in this repo!!!** 

If the package does not have its own build system, create *<package_name>* subdirectory 
in *packages* directory. create a necessary file structure inside the directory.
Create a *DEBIAN* directory inside, fill in *DEBIAN/control*. Use existing packages as example.
Put the aprpopriate script in the *scripts/src-packages* to compile and install the necessary 
files to *packages/<package name>*.

If the package does not require compilation, simply create the necessary file structure in packages/<package_name>

##### What can be improved?

- Use something better in place of dpkg-deb.
