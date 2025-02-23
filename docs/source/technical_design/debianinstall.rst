===========================
Production: Debian packages
===========================

OpenKAT has Debian packages available. In the near future we will have an apt
repository that will allow you to keep your installation up-to-date using apt.
An installation of KAT can be done on a single machine or spread out on several
machines for a high availability setup. This guide will take you through the
steps for installing it on a single machine.

Prerequisites
=============

We will be using ``sudo`` in this guide, so make sure you have ``sudo`` installed on
your system.

The packages are built with Ubuntu 22.04 and Debian 11 in mind.
They may or may not work on other versions or distributions.

Downloading and installing
==========================

Download the packages for all the components of KAT from `GitHub
<https://github.com/minvws/nl-kat-coordination/releases/latest>`__. XTDB
multinode package also be downloaded from `GitHub
<https://github.com/dekkers/xtdb-http-multinode/releases/latest>`__.

After downloading they can be installed as follows:

.. code-block:: sh

    tar zvxf kat-*.tar.gz
    apt install --no-install-recommends ./kat-*_amd64.deb ./xtdb-http-multinode_*_all.deb

Set up the databases
====================

OpenKAT needs three databases for its components. One for rocky, KAT-alogus and bytes. The following steps will guide you through the creation of these databases.

If you will be running the database on the same machine as KAT, you can install Postgres:

.. code-block:: sh

    apt install postgresql

Rocky DB
--------

Generate a secure password for the Rocky database user, as an example we'll use /dev/urandom:

.. code-block:: sh

    echo $(tr -dc A-Za-z0-9 < /dev/urandom | head -c 20)

To configure rocky to use this password, open `/etc/kat/rocky.conf` and fill in this password for `ROCKY_DB_PASSWORD`.

Create the database and user for Rocky in Postgres:

.. code-block:: sh

    sudo -u postgres createdb rocky_db
    sudo -u postgres createuser rocky -P
    sudo -u postgres psql -c 'GRANT ALL ON DATABASE rocky_db TO rocky;'

Now use rocky-cli to initialize the database:

.. code-block:: sh

    sudo -u kat rocky-cli migrate
    sudo -u kat rocky-cli loaddata /usr/share/kat-rocky/OOI_database_seed.json

The steps for creating the other databases will be similar, but we'll explain them anyway for completeness.

KAT-alogus DB
-------------

Generate a unique secure password for the KAT-alogus database user. You can use the same method we used for generating the Rocky database user password.

Insert this password into the connection string for the KAT-alogus DB in `/etc/kat/boefjes.conf`. For example:

.. code-block:: sh

    KATALOGUS_DB_URI=postgresql://katalogus:<password>@localhost/katalogus_db

Create a new database and user for KAT-alogus:

.. code-block:: sh

    sudo -u postgres createdb katalogus_db
    sudo -u postgres createuser katalogus -P
    sudo -u postgres psql -c 'GRANT ALL ON DATABASE katalogus_db TO katalogus;'

Initialize the database using the update-katalogus-db tool:

.. code-block:: sh

    sudo -u kat update-katalogus-db

Bytes DB
--------

Generate a unique password for the Bytes database user. Insert it into the connection string for the Bytes database.
Insert this password into the connection string for the Bytes DB in `/etc/kat/bytes.conf`. For example:

.. code-block:: sh

    BYTES_DB_URI=postgresql://bytes:<password>@localhost/bytes_db

Create a new database and user for Bytes:

.. code-block:: sh

    sudo -u postgres createdb bytes_db
    sudo -u postgres createuser bytes -P
    sudo -u postgres psql -c 'GRANT ALL ON DATABASE bytes_db TO bytes;'

Initialize the Bytes database:

.. code-block:: sh

    sudo -u kat update-bytes-db

Create Rocky superuser and set up default groups and permissions
================================================================

Create an admin user for OpenKAT

.. code-block:: sh

    sudo -u kat rocky-cli createsuperuser

Create the default groups and permissions for KAT:

.. code-block:: sh

    sudo -u kat rocky-cli setup_dev_account

Set up RabbitMQ
===============

Installation
------------

Use the following steps to set up RabbitMQ and allow kat to use it.

Start by installing RabbitMQ:

.. code-block:: sh

    sudo apt install rabbitmq-server

By default RabbitMQ will listen on all interfaces. For a single node setup this is not what we want. To prevent RabbitMQ from being accessed from the internet add the following lines to `/etc/rabbitmq/rabbitmq-env.conf`:

.. code-block:: sh

    export ERL_EPMD_ADDRESS=127.0.0.1
    export NODENAME=rabbit@localhost

Stop RabbitMQ and epmd:

.. code-block:: sh

    sudo systemctl stop rabbitmq-server
    sudo epmd -kill

Create a new file `/etc/rabbitmq/rabbitmq.conf` and add the following lines:

.. code-block:: unixconfig

    listeners.tcp.local = 127.0.0.1:5672

Create a new file `/etc/rabbitmq/advanced.config` and add the following lines:

.. code-block:: erlang

    [
        {kernel,[
            {inet_dist_use_interface,{127,0,0,1}}
        ]}
    ].

Now start RabbitMQ again with `systemctl start rabbitmq-server` and check if it only listens on localhost for ports 5672 and 25672.

Add the 'kat' vhost
-------------------

Generate a safe password for the KAT user in rabbitmq. You can use the /dev/urandom method again and put it in a shell variable to use it later:

.. code-block:: sh

    rabbitmq_pass=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 20)

Now create a KAT user for RabbitMQ, create the virtual host and set the permissions:

.. code-block:: sh

    rabbitmqctl add_user kat ${rabbitmq_pass}
    rabbitmqctl add_vhost kat
    rabbitmqctl set_permissions -p "kat" "kat" ".*" ".*" ".*"

Now configure KAT to use the vhost we created and with the kat user. To do this, update the following settings for `/etc/kat/mula.conf`:

.. code-block:: sh

    SCHEDULER_RABBITMQ_DSN=amqp://kat:<password>@localhost:5672/kat
    SCHEDULER_DSP_BROKER_URL=amqp://kat:<password>@localhost:5672/kat

And update the `QUEUE_URI` setting to the same value for the following files:

 * `/etc/kat/rocky.conf`
 * `/etc/kat/bytes.conf`
 * `/etc/kat/boefjes.conf`
 * `/etc/kat/octopoes.conf`

Or use this command to do it for you:

.. code-block:: sh

    sed -i "s|QUEUE_URI= *\$|QUEUE_URI=amqp://kat:${rabbitmq_pass}@localhost:5672/kat|" /etc/kat/*.conf

Configure Bytes credentials
===========================

copy the value of `BYTES_PASSWORD` in `/etc/kat/bytes.conf` to the setting with the same name in the following files:

- `/etc/kat/rocky.conf`
- `/etc/kat/boefjes.conf`
- `/etc/kat/mula.conf`

This oneliner will do it for you:

.. code-block:: sh

    sed -i "s/BYTES_PASSWORD= *\$/BYTES_PASSWORD=$(grep BYTES_PASSWORD /etc/kat/bytes.conf | awk -F'=' '{ print $2 }')/" /etc/kat/*.conf

Restart KAT
===========

After finishing these steps, you should restart KAT to load the new configuration:

.. code-block:: sh

    sudo systemctl restart kat-rocky kat-mula kat-bytes kat-boefjes kat-normalizers kat-katalogus kat-keiko kat-octopoes kat-octopoes-worker

Start KAT on system boot
========================

To start KAT when the system boots, enable all KAT services:

.. code-block:: sh

    sudo systemctl enable kat-rocky kat-mula kat-bytes kat-boefjes kat-normalizers kat-katalogus kat-keiko kat-octopoes kat-octopoes-worker

Start using OpenKAT
===================

By default OpenKAT will be accessible in your browser through `https://<server IP>:8000`. There, Rocky will take you through the steps of setting up your account and running your first boefjes.

Upgrading OpenKAT
=================

You can upgrade OpenKAT by installing the newer packages:

.. code-block:: sh

    tar zvxf kat-debian-packages.tar.gz -C /opt && cd /opt/kat-debian-packages
    apt install --no-install-recommends ./kat-*_all.deb

After installation you need to run the database migrations and load fixture again. For Rocky DB:

.. code-block:: sh

    sudo -u kat rocky-cli migrate
    sudo -u kat rocky-cli loaddata /usr/share/kat-rocky/OOI_database_seed.json

For KAT-alogus DB

.. code-block:: sh

    sudo -u kat update-katalogus-db

For Bytes DB:

.. code-block:: sh

    sudo -u kat update-bytes-db
