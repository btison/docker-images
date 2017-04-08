MongoDB Docker image
====================

This repository contains Dockerfiles for MongoDB images for general usage and OpenShift.
Users can choose between RHEL and CentOS based images.

Environment variables
---------------------------------

The image recognizes the following environment variables that you can set during
initialization by passing `-e VAR=VALUE` to the Docker run command.

|    Variable name          |    Description                              |
| :------------------------ | -----------------------------------------   |
|  `MONGODB_USER`       | User name for MONGODB account to be created |
|  `MONGODB_PASSWORD`       | Password for the user account               |
|  `MONGODB_DATABASE`       | Database name                               |
|  `MONGODB_ADMIN_PASSWORD` | Password for the admin user                 |


The following environment variables influence the MongoDB configuration file. They are all optional.

|    Variable name      |    Description                                                            |    Default
| :-------------------- | ------------------------------------------------------------------------- | ----------------
|  `MONGODB_QUIET`      | Runs MongoDB in a quiet mode that attempts to limit the amount of output. |  true


You can also set the following mount points by passing the `-v /host:/container` flag to Docker.

|  Volume mount point         | Description            |
| :-------------------------- | ---------------------- |
|  `/var/lib/mongodb/data`   | MongoDB data directory |

**Notice: When mouting a directory from the host into the container, ensure that the mounted
directory has the appropriate permissions and that the owner and group of the directory
matches the user UID or name which is running inside the container.**


Usage
---------------------------------

For this, we will assume that you are using the `centos/mongodb-32-centos7` image.
If you want to set only the mandatory environment variables and store the database
in the `/home/user/database` directory on the host filesystem, execute the following command:

```
$ docker run -d -e MONGODB_USER=<user> -e MONGODB_PASSWORD=<password> -e MONGODB_DATABASE=<database> -e MONGODB_ADMIN_PASSWORD=<admin_password> -v /home/user/database:/var/lib/mongodb/data centos/mongodb-32-centos7
```

If you are initializing the database and it's the first time you are using the
specified shared volume, the database will be created with two users: `admin` and `MONGODB_USER`. After that the MongoDB daemon
will be started. If you are re-attaching the volume to another container, the
creation of the database user and admin user will be skipped and only the
MongoDB daemon will be started.

Custom configuration file
---------------------------------

It is allowed to use custom configuration file for mongod server. Providing a custom configuration file supercedes the individual configuration environment variable values.

To use custom configuration file in container it has to be mounted into `/etc/mongod.conf`. For example to use configuration file stored in `/home/user` directory use this option for `docker run` command: `-v /home/user/mongod.conf:/etc/mongod.conf:Z`.

**Notice: Custom config file does not affect name of replica set. It has to be set in `MONGODB_REPLICA_NAME` environment variable.**

MongoDB admin user
---------------------------------

The admin user name is set to `admin` and you have to to specify the password by
setting the `MONGODB_ADMIN_PASSWORD` environment variable. This process is done
upon database initialization.


Changing passwords
------------------

Since passwords are part of the image configuration, the only supported method
to change passwords for the database user (`MONGODB_USER`) and admin user is by
changing the environment variables `MONGODB_PASSWORD` and
`MONGODB_ADMIN_PASSWORD`, respectively.

Changing database passwords directly in MongoDB will cause a mismatch between
the values stored in the variables and the actual passwords. Whenever a database
container starts it will reset the passwords to the values stored in the
environment variables.

