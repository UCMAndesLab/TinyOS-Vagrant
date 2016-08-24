This vagrant configuration files includes everything that is necessary to start an instance of vagrant with tinyos installed.

# Usage

Use ```vagrant up``` to turn on machine. First instance will use puppet to download and compile all of the necessary files.

At the moment, there is a bug with provisioning so the machine will need to be provision twice for it to work.

```
vagrant provision
vagrant provision
```


See https://www.vagrantup.com/ for additional information on how to use vagrant.
