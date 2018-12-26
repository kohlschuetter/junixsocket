# How to release junixsocket

NOTE: This is probably not interesting unless you're the project admin or going to fork it.

## Prerequisites

### github.com credentials

1. On github.com, create an OAuth token with write permissions to the repo.
2. Add the credentials to your keychain
    
### GPG keys

Instructions for macOS

 * Install gpg and helper tools    

    brew install gpg gpg2 gpg-agent pinentry-mac


 * Enable pinentry-mac
 
   This gives a nice GUI for the passphrase, and allows us to store the GPG key passphrase in the macOS keychain)

    # open or create ~/.gnupg/gpg-agent.conf 
    # then add the following line if it doesn't exist yet:
    pinentry-program /usr/local/bin/pinentry-mac
    
 * Generate GPG key
 
    gpg2 --generate-key 
    # Follow on-screen instructions. Use a long, memorable passphrase.
    # Remember the GPG key ID. Publish the corresponding GPG public key on the GPG keyservers:
    gpg2 --send-keys THEKEYID
    
### Build environment for other platforms

Currently, the easiest way to build for other platforms is to have a working Java 9 (or later)
environment, Maven 3+ and the junixsocket project ready. Just spin up a virtual machine (or emulator),
install Java, Maven and junixosocket, and you should be good to go.
    
## Common tasks

### Ensure the code is properly formatted and licenses are in place

    cd junixsocket
    # review LICENSE file and verify that it's up-to-date
    mvn java-formatter:format
    mvn license:format
    # git add / commit here...

### Bump project version

    cd junixsocket
    mvn versions:set -DnewVersion=2.1.0
    # git add / commit here...
    
### Build native libraries on other supported, common platforms

This currently means amd64-Linux-gpp in addition to our default x86_64-MacOSX-gpp environment. 

On the target machine, install junixsocket. Make sure you use the very same version as on your
development machine from where you do the release!

    cd junixsocket
    mvn clean install -Pstrict

The platform-dependent nar files should now be available in the local maven repository cache.

Use the provided script to copy the corresponding nar to a project folder:

    cd junixsocket
    # replace 2.1.0 with the desired version number
    junixsocket-native-prebuilt/bin/copy-nar-from-m2repo.sh 2.1.0

Now copy the nar files from the target machine to your development computer (from where you do the release).
By convention, copy the files to the same folder as on the target machine (*junixsocket/junixsocket-native-prebuilt/bin*)

On the development computer, install the nar files in the local Maven repository cache:

    cd junixsocket
    junixsocket-native-prebuilt/bin/install-to-m2repo.sh junixsocket-native-prebuilt/nar/*nar

### Create binary distribution

This will create a directory, a .tar.gz and a .zip archive, containing the project jars and
a script to run the demo classes from the command-line.

    cd junixsocket
    mvn clean install -Pstrict -Prelease
    ( cd junixsocket-dist ; mvn assembly:single )

The files can be found in

   * `junixsocket/junixsocket-dist/target/junixsocket-dist-2.1.0-bin`
   * `junixsocket/junixsocket-dist/target/junixsocket-dist-2.1.0-bin.tar.gz`
   * `junixsocket/junixsocket-dist/target/junixsocket-dist-2.1.0-bin.zip`

### Deploy code to Maven central

#### 1. Deploy to staging
  
    cd junixsocket
    mvn clean install -Pstrict -Prelease
    mvn deploy -Psigned
    
##### Notes

`-Pstrict` enforces code quality checks to succeed (e.g., *spotbugs*, *checkstyle*). 

`-Prelease` makes sure we include all common native binaries in junixsocket-native-common.

`-Psigned` enables signing the artifacts with our GPG key. 

##### In case of failures while staging:

If the deployment fails with `Remote staging failed: Staging rules failure!` and due to
`No public key: Key with id: (...) was not able to be located on ...`,
then that means that the GPG key you created above has not been fully distributed among the GPG key
servers. Try to manually push to the ones mentioned in the error message, and try again.

For example:

    gpg2 --keyserver http://keyserver.ubuntu.com:11371 --send-keys THEKEYID
    
#### 2. Review the deployed artifacts
  
    The URL of the staging repository is `https://oss.sonatype.org/content/groups/staging`.
    The artifacts can be found [here](https://oss.sonatype.org/content/groups/staging/com/kohlschutter/junixsocket/).

#### 3. Release artifact to Maven Central
  
    mvn nexus-staging:release     

### Tag the release, push to upstream (i.e., GitHub)

    mvn scm:tag
    git push

### Publish website 

This builds the Maven site and publishes it to [https://kohlschutter.github.io/junixsocket/](https://kohlschutter.github.io/junixsocket/).

    cd junixsocket 
    mvn clean install
    mvn site site:stage scm-publish:publish-scm

NOTE: There can be a 10-minute delay until the pages get updated automatically in your browser cache.
Hit refresh to expedite.

### Prepare next version

    mvn versions:set -DnewVersion=2.1.1-SNAPSHOT
    # git add / commit here...
    
